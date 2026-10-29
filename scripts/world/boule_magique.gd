class_name BouleMagique
extends Node3D
## Boule lumineuse lancée par un monstre à distance (le Gobelin chaman) : elle file vers sa cible,
## puis appelle « a_l_arrivee ».

const VITESSE := 9.0
const HAUTEUR_VISEE := 1.0
const DUREE_MAX := 3.0

var _cible: Node3D
var _a_l_arrivee: Callable
var _temps := 0.0


static func lancer(parent: Node, depart: Vector3, cible: Node3D, couleur: Color, a_l_arrivee: Callable) -> BouleMagique:
	var boule := BouleMagique.new()
	boule._cible = cible
	boule._a_l_arrivee = a_l_arrivee
	var sphere := SphereMesh.new()
	sphere.radius = 0.16
	sphere.height = 0.32
	sphere.radial_segments = 10
	sphere.rings = 5
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.albedo_color = couleur
	sphere.material = matiere
	var forme := MeshInstance3D.new()
	forme.mesh = sphere
	forme.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	boule.add_child(forme)
	var halo := ApparenceRarete.ajouter_etincelles(boule, "standard", AABB(Vector3(-0.1, -0.1, -0.1), Vector3(0.2, 0.2, 0.2)), 10)
	for i in halo.color_ramp.get_point_count():
		halo.color_ramp.set_color(i, Color(couleur, halo.color_ramp.get_color(i).a))
	parent.add_child(boule)
	boule.global_position = depart
	return boule


func _physics_process(delta: float) -> void:
	_temps += delta
	if not is_instance_valid(_cible) or _temps > DUREE_MAX:
		queue_free()
		return
	var visee := _cible.global_position + Vector3.UP * HAUTEUR_VISEE
	if global_position.distance_to(visee) <= VITESSE * delta:
		_a_l_arrivee.call()
		queue_free()
		return
	global_position = global_position.move_toward(visee, VITESSE * delta)
