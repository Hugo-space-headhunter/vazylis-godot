class_name TirArc
extends Node3D
## Le tir à l'arc : la main droite saisit la corde, la tire jusqu'à la joue pendant que le bras
## gauche tend l'arc, puis la lâche au moment où la flèche part. La corde est dessinée en deux
## segments qui suivent la main (la corde fixe du modèle est cachée pendant le tir).
## Où sont les bouts de la corde sur l'arc : réglage « corde » du catalogue {"haut": …, "bas": …}.

## Où la main droite ramène la corde, par rapport à la tête (repère du personnage, droite = -X).
const POINT_JOUE := Vector3(-0.07, -0.06, -0.08)
const COUDE_DROIT := Vector3(-0.7, 1.45, -0.7)
const EPAISSEUR_CORDE := 0.007
const DUREE_LACHER := 0.06

## Tension de la corde : 0 = au repos, 1 = bandée jusqu'à la joue.
var tension := 0.0

var _porteur: ModeleAsset
var _bout_haut: Marker3D
var _bout_bas: Marker3D
var _main_corde: Marker3D
var _coude: Marker3D
var _ik: TwoBoneIK3D
var _segments: Array[MeshInstance3D] = []
var _corde_fixe: Node3D
var _tween: Tween


func installer(porteur: ModeleAsset, arc: ModeleAsset, corde: Dictionary) -> void:
	retirer()
	var squelette := porteur.squelette()
	if squelette == null or corde.is_empty() or arc.provisoire:
		return
	_porteur = porteur
	_bout_haut = Marker3D.new()
	_bout_haut.position = corde["haut"]
	arc.ajouter_au_modele(_bout_haut)
	_bout_bas = Marker3D.new()
	_bout_bas.position = corde["bas"]
	arc.ajouter_au_modele(_bout_bas)
	_corde_fixe = arc.find_child(str(corde.get("maillage", "Corde")), true, false) as Node3D
	_main_corde = Marker3D.new()
	_main_corde.top_level = true
	add_child(_main_corde)
	_coude = Marker3D.new()
	_coude.position = COUDE_DROIT
	porteur.add_child(_coude)
	_ik = TwoBoneIK3D.new()
	_ik.name = "Tir_main_droite"
	squelette.add_child(_ik)
	_ik.setting_count = 1
	_ik.set_root_bone_name(0, "upperarm_r")
	_ik.set_middle_bone_name(0, "lowerarm_r")
	_ik.set_end_bone_name(0, "hand_r")
	_ik.influence = 0.0
	for i in 2:
		var cylindre := CylinderMesh.new()
		cylindre.top_radius = EPAISSEUR_CORDE
		cylindre.bottom_radius = EPAISSEUR_CORDE
		cylindre.height = 1.0
		cylindre.radial_segments = 4
		cylindre.rings = 1
		var matiere := StandardMaterial3D.new()
		matiere.albedo_color = Color(0.9, 0.86, 0.75)
		matiere.roughness = 1.0
		cylindre.material = matiere
		var segment := MeshInstance3D.new()
		segment.mesh = cylindre
		segment.top_level = true
		segment.visible = false
		segment.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(segment)
		_segments.append(segment)
	relier.call_deferred()


func relier() -> void:
	if _ik != null and is_instance_valid(_ik) and _ik.is_inside_tree():
		_ik.set_target_node(0, _ik.get_path_to(_main_corde))
		_ik.set_pole_node(0, _ik.get_path_to(_coude))


func retirer() -> void:
	for noeud in [_bout_haut, _bout_bas, _main_corde, _coude, _ik]:
		if noeud != null and is_instance_valid(noeud):
			noeud.queue_free()
	for segment in _segments:
		if is_instance_valid(segment):
			segment.queue_free()
	_segments.clear()
	if _corde_fixe != null and is_instance_valid(_corde_fixe):
		_corde_fixe.visible = true
	_porteur = null
	_ik = null
	tension = 0.0


func est_installe() -> bool:
	return _ik != null and is_instance_valid(_ik)


## La main droite saisit la corde et la tire jusqu'à la joue en « duree » secondes.
func bander(duree: float) -> void:
	if not est_installe():
		return
	_lancer_tension(1.0, maxf(0.05, duree), Tween.EASE_OUT)


## La corde part : la main la lâche d'un coup.
func lacher() -> void:
	if not est_installe():
		return
	_lancer_tension(0.0, DUREE_LACHER, Tween.EASE_IN)


func _lancer_tension(cible: float, duree: float, adoucissement: Tween.EaseType) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "tension", cible, duree).set_ease(adoucissement).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	if not est_installe() or not is_instance_valid(_porteur):
		return
	var haut := _bout_haut.global_position
	var bas := _bout_bas.global_position
	var repos := (haut + bas) / 2.0
	var squelette := _porteur.squelette()
	var tete := squelette.global_transform * squelette.get_bone_global_pose(squelette.find_bone("Head"))
	var joue := tete.origin + _porteur.global_basis * POINT_JOUE
	var encoche := repos.lerp(joue, tension)
	_main_corde.global_position = encoche
	_ik.influence = clampf(tension * 4.0, 0.0, 1.0)
	var tendue := tension > 0.02
	if _corde_fixe != null and is_instance_valid(_corde_fixe):
		_corde_fixe.visible = not tendue
	_placer_segment(_segments[0], haut, encoche, tendue)
	_placer_segment(_segments[1], encoche, bas, tendue)


func _placer_segment(segment: MeshInstance3D, a: Vector3, b: Vector3, visible_: bool) -> void:
	segment.visible = visible_
	if not visible_ or a.distance_to(b) < 0.001:
		return
	var axe := (b - a).normalized()
	var cote := axe.cross(Vector3.UP if absf(axe.y) < 0.95 else Vector3.RIGHT).normalized()
	var base := Basis(cote, axe, cote.cross(axe)).scaled(Vector3(1, a.distance_to(b), 1))
	segment.global_transform = Transform3D(base, (a + b) / 2.0)
