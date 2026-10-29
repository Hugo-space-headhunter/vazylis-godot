class_name Fleche
extends Node3D
## Flèche tirée à l'arc : elle file vers sa cible, puis appelle « a_l_arrivee ».

const VITESSE := 22.0
const HAUTEUR_VISEE := 0.4
const DUREE_MAX := 2.0

var _cible: Node3D
var _a_l_arrivee: Callable
var _temps := 0.0


static func tirer(parent: Node, depart: Vector3, cible: Node3D, a_l_arrivee: Callable) -> Fleche:
	var fleche := Fleche.new()
	fleche._cible = cible
	fleche._a_l_arrivee = a_l_arrivee
	fleche.add_child(CatalogueAssets.creer(IdentifiantsAssets.FLECHE))
	parent.add_child(fleche)
	fleche.global_position = depart
	return fleche


func _physics_process(delta: float) -> void:
	_temps += delta
	if not is_instance_valid(_cible) or _temps > DUREE_MAX:
		queue_free()
		return
	var visee := _cible.global_position + Vector3.UP * HAUTEUR_VISEE
	var distance := global_position.distance_to(visee)
	if distance <= VITESSE * delta:
		_a_l_arrivee.call()
		queue_free()
		return
	look_at(visee, Vector3.UP, true)
	global_position = global_position.move_toward(visee, VITESSE * delta)
