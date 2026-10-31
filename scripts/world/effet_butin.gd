class_name EffetButin
extends Node3D
## Un objet tombe : il apparaît brièvement au-dessus du monstre, dans la couleur de sa rareté,
## avec une colonne de lumière, puis il file vers le personnage (dans le sac).
## Une belle trouvaille (doré et au-delà) reste plus longtemps en l'air, et une onde lumineuse
## de sa couleur s'étale au sol.

const TAILLE := 0.55
const DUREE_APPARITION := 0.75
## Temps d'apparition ajouté par rang de rareté au-delà de l'argenté (secondes).
const DUREE_PAR_RANG := 0.25
## Rang de rareté (0 = standard) à partir duquel une trouvaille est mise en valeur.
const RANG_BELLE_TROUVAILLE := 2
const DUREE_VOL := 0.35
const VITESSE_ROTATION := 3.0

var _modele: ModeleAsset
var _cible: Node3D


static func jouer(parent: Node, position_depart: Vector3, objet: Objet, cible: Node3D, femme: bool) -> EffetButin:
	var effet := EffetButin.new()
	effet._cible = cible
	parent.add_child(effet)
	effet.global_position = position_depart
	effet._lancer(objet, femme)
	return effet


func _lancer(objet: Objet, femme: bool) -> void:
	var config := Config.jeu
	var couleur := config.couleur_rarete(objet.rarete)
	var rang := config.ids_raretes().find(objet.rarete)

	_modele = CatalogueAssets.creer(objet.modele(config, femme))
	ApparenceRarete.appliquer(_modele, objet.rarete)
	add_child(_modele)
	var boite := _modele.boite_englobante()
	var plus_grand := maxf(boite.size.x, maxf(boite.size.y, boite.size.z))
	if plus_grand > 0.001:
		_modele.scale = Vector3.ONE * (TAILLE / plus_grand)
		_modele.position = -(boite.get_center() * _modele.scale) + Vector3.UP * 0.6

	var colonne := MeshInstance3D.new()
	var cylindre := CylinderMesh.new()
	cylindre.top_radius = 0.12 + 0.03 * rang
	cylindre.bottom_radius = 0.25 + 0.05 * rang
	cylindre.height = 1.2 + 0.5 * rang
	cylindre.cap_top = false
	cylindre.cap_bottom = false
	cylindre.radial_segments = 12
	colonne.mesh = cylindre
	colonne.position.y = cylindre.height / 2.0
	colonne.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	matiere.albedo_color = Color(couleur, 0.35)
	colonne.material_override = matiere
	add_child(colonne)

	var texte := objet.nom if rang < 2 else "%s !" % objet.nom
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * 1.3, texte, couleur, 30 + 5 * rang, 1.2, 0.4)

	var duree := DUREE_APPARITION + DUREE_PAR_RANG * maxi(0, rang - 1)
	if rang >= RANG_BELLE_TROUVAILLE:
		_onde_au_sol(couleur, rang)
	var animation := create_tween()
	animation.tween_property(_modele, "position:y", _modele.position.y + 0.35, duree) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	animation.parallel().tween_property(matiere, "albedo_color:a", 0.0, duree + DUREE_VOL)
	animation.tween_method(_voler, 0.0, 1.0, DUREE_VOL).set_ease(Tween.EASE_IN)
	animation.tween_callback(queue_free)


## Onde de lumière qui s'étale au sol depuis l'objet, deux fois pour les plus rares.
func _onde_au_sol(couleur: Color, rang: int) -> void:
	for i in (2 if rang >= RANG_BELLE_TROUVAILLE + 2 else 1):
		var onde := CercleAuSol.creer(self, "Onde", 1.0, Color(couleur, 0.9), 0.04)
		onde.scale = Vector3.ONE * 0.2
		var matiere := CercleAuSol.matiere(onde)
		var vague := onde.create_tween()
		vague.tween_interval(0.25 * i)
		vague.tween_property(onde, "scale", Vector3.ONE * (1.6 + 0.3 * rang), 0.9).set_ease(Tween.EASE_OUT)
		vague.parallel().tween_property(matiere, "albedo_color:a", 0.0, 0.9)


func _process(delta: float) -> void:
	if is_instance_valid(_modele):
		_modele.rotate_y(VITESSE_ROTATION * delta)


## Le modèle file vers le personnage en rapetissant.
func _voler(avancement: float) -> void:
	if not is_instance_valid(_cible):
		return
	var depart := global_position + Vector3.UP * 0.9
	var arrivee := _cible.global_position + Vector3.UP * 1.0
	_modele.global_position = depart.lerp(arrivee, avancement)
	_modele.scale = _modele.scale.lerp(Vector3.ONE * 0.05, avancement * 0.5)
