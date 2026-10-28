class_name CameraSuiveuse
extends Node3D
## Caméra qui suit le personnage en douceur, et qu'on peut faire tourner autour de lui.
## Ce nœud se place sur le personnage ; la caméra (enfant) se tient derrière, en hauteur.

## Le nœud suivi (le personnage).
@export var cible: Node3D

@onready var _camera: Camera3D = $Camera


func _ready() -> void:
	var config := Config.jeu
	var inclinaison := deg_to_rad(config.inclinaison_camera_degres())
	var distance := config.distance_camera()
	var visee := Vector3(0, config.hauteur_visee_camera(), 0)
	_camera.position = visee + Vector3(0, sin(inclinaison), cos(inclinaison)) * distance
	_camera.rotation = Vector3(-inclinaison, 0, 0)
	_camera.fov = config.champ_vision_camera()
	get_viewport().size_changed.connect(_adapter_orientation)
	_adapter_orientation()
	if cible != null:
		global_position = cible.global_position


func _process(delta: float) -> void:
	if cible == null:
		return
	var poids := 1.0 - exp(-Config.jeu.lissage_suivi_camera() * delta)
	global_position = global_position.lerp(cible.global_position, poids)


## Tourne la caméra autour du personnage (pixels glissés à l'écran).
func tourner(pixels: float) -> void:
	rotation.y -= deg_to_rad(pixels * Config.jeu.sensibilite_rotation_camera())


## Angle de la caméra autour du personnage, utilisé pour orienter le joystick.
func angle() -> float:
	return rotation.y


## En portrait, garder la même largeur de vue pour que la scène ne soit pas coupée sur les côtés.
func _adapter_orientation() -> void:
	var taille := get_viewport().get_visible_rect().size
	_camera.keep_aspect = Camera3D.KEEP_WIDTH if taille.y > taille.x else Camera3D.KEEP_HEIGHT
