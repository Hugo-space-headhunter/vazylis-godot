class_name CameraSuiveuse
extends Node3D
## Caméra qui suit le personnage en douceur, et qu'on peut faire tourner autour de lui.
## Ce nœud se place sur le personnage ; la caméra (enfant) se tient derrière, en hauteur.

## Le nœud suivi (le personnage).
@export var cible: Node3D

## Groupe pour retrouver la caméra (par exemple pour la secouer quand un coup porte).
const GROUPE := "camera_suiveuse"

@onready var _camera: Camera3D = $Camera
var _secousse := 0.0
var _duree_secousse := 0.0
var _reste_secousse := 0.0


func _ready() -> void:
	add_to_group(GROUPE)
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
	_secouer_la_vue(delta)


## Secoue la caméra : « amplitude » en mètres, qui s'éteint en « duree » secondes.
func secouer(amplitude: float, duree: float) -> void:
	if amplitude < _secousse * (_reste_secousse / maxf(_duree_secousse, 0.001)):
		return
	_secousse = amplitude
	_duree_secousse = duree
	_reste_secousse = duree


func _secouer_la_vue(delta: float) -> void:
	if _reste_secousse <= 0.0:
		return
	# Temps réel : la secousse continue pendant un arrêt sur image.
	_reste_secousse -= delta / maxf(Engine.time_scale, 0.01)
	var force := _secousse * maxf(0.0, _reste_secousse / _duree_secousse)
	_camera.h_offset = randf_range(-force, force)
	_camera.v_offset = randf_range(-force, force)
	if _reste_secousse <= 0.0:
		_camera.h_offset = 0.0
		_camera.v_offset = 0.0


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
