class_name EffetNiveau
extends Node3D
## Effet « Level Up » : le texte, un cercle lumineux au sol et une aura d'énergie
## autour du personnage pendant 1 seconde.

const COULEUR := Color(1.0, 0.85, 0.35)
const DUREE_AURA := 1.0


static func jouer(personnage: Node3D) -> void:
	var effet := EffetNiveau.new()
	personnage.add_child(effet)
	effet._lancer()
	ChiffreFlottant.afficher(personnage.get_parent(), personnage.global_position + Vector3.UP * 2.3,
		"Level Up !", COULEUR, 96, 1.6, 0.7)


func _lancer() -> void:
	var cercle := _creer_maillage(_anneau(), 0.9)
	cercle.position.y = 0.03
	cercle.scale = Vector3.ONE * 0.4
	var aura := _creer_maillage(_cylindre(), 0.35)
	aura.position.y = 1.0

	var animation := create_tween().set_parallel()
	animation.tween_property(cercle, "scale", Vector3(2.2, 1, 2.2), DUREE_AURA).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	animation.tween_property(cercle.material_override, "albedo_color:a", 0.0, DUREE_AURA).set_ease(Tween.EASE_IN)
	animation.tween_property(aura, "scale", Vector3(1.3, 1.1, 1.3), DUREE_AURA)
	animation.tween_property(aura.material_override, "albedo_color:a", 0.0, DUREE_AURA).set_ease(Tween.EASE_IN)
	animation.chain().tween_callback(queue_free)


func _creer_maillage(maillage: Mesh, opacite: float) -> MeshInstance3D:
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	matiere.albedo_color = Color(COULEUR, opacite)
	var instance := MeshInstance3D.new()
	instance.mesh = maillage
	instance.material_override = matiere
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)
	return instance


func _anneau() -> Mesh:
	var anneau := TorusMesh.new()
	anneau.inner_radius = 0.45
	anneau.outer_radius = 0.6
	anneau.rings = 32
	anneau.ring_segments = 4
	return anneau


func _cylindre() -> Mesh:
	var cylindre := CylinderMesh.new()
	cylindre.top_radius = 0.5
	cylindre.bottom_radius = 0.6
	cylindre.height = 2.0
	cylindre.cap_top = false
	cylindre.cap_bottom = false
	cylindre.radial_segments = 16
	cylindre.rings = 1
	return cylindre
