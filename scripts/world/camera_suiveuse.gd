class_name CameraSuiveuse
extends Node3D
## Caméra qui suit le personnage en douceur, et qu'on peut faire tourner autour de lui.
## Ce nœud se place sur le personnage ; la caméra (enfant) se tient derrière, en hauteur.
## Elle se règle selon l'orientation de l'écran (portrait : un peu plus loin et plus haut),
## regarde un peu devant le personnage quand il avance, et se rapproche si un mur ou une maison
## passe entre elle et lui. Réglages : section [camera] de config/commandes.cfg.

## Groupe pour retrouver la caméra (par exemple pour la secouer quand un coup porte).
const GROUPE := "camera_suiveuse"
## Couche de collision des grands décors (murs, maisons, gros rochers) qui gênent la vue (voir Decor).
const COUCHE_MASQUE := 8
## Vitesse à laquelle la caméra se rapproche d'un obstacle, puis reprend sa place (plus grand = plus vif).
const LISSAGE_OBSTACLE := 12.0

## Le nœud suivi (le personnage).
@export var cible: Node3D

@onready var _camera: Camera3D = $Camera
var portrait := false
var _secousse := 0.0
var _duree_secousse := 0.0
var _reste_secousse := 0.0
var _distance := 6.0
var _distance_actuelle := 6.0
var _visee := Vector3.ZERO
var _direction := Vector3.BACK
var _avance := Vector3.ZERO
var _position_precedente := Vector3.ZERO


func _ready() -> void:
	add_to_group(GROUPE)
	get_viewport().size_changed.connect(_adapter_orientation)
	_adapter_orientation()
	_distance_actuelle = _distance
	_placer_la_camera(_distance)
	if cible != null:
		global_position = cible.global_position
		_position_precedente = cible.global_position


func _process(delta: float) -> void:
	if cible == null:
		return
	var config := Config.jeu
	# Regard un peu devant : la vitesse du personnage (lissée) décale le point suivi.
	if delta > 0.0:
		var vitesse := (cible.global_position - _position_precedente) / delta
		vitesse.y = 0.0
		var voulue := (vitesse * config.reglage_camera("avance_regard", 0.35)).limit_length(2.5)
		_avance = _avance.lerp(voulue, 1.0 - exp(-3.0 * delta))
	_position_precedente = cible.global_position
	var poids := 1.0 - exp(-config.lissage_suivi_camera() * delta)
	global_position = global_position.lerp(cible.global_position + _avance, poids)
	_eviter_les_obstacles(delta)
	_secouer_la_vue(delta)


## Tourne la caméra autour du personnage (pixels glissés à l'écran).
func tourner(pixels: float) -> void:
	rotation.y -= deg_to_rad(pixels * Config.jeu.sensibilite_rotation_camera())


## Angle de la caméra autour du personnage, utilisé pour orienter le joystick.
func angle() -> float:
	return rotation.y


## Secoue la caméra : « amplitude » en mètres, qui s'éteint en « duree » secondes.
func secouer(amplitude: float, duree: float) -> void:
	if amplitude < _secousse * (_reste_secousse / maxf(_duree_secousse, 0.001)):
		return
	_secousse = amplitude
	_duree_secousse = duree
	_reste_secousse = duree


## Distance actuelle entre la caméra et le point regardé (plus courte si un mur gêne).
func distance_actuelle() -> float:
	return _distance_actuelle


## Portrait : l'écran est étroit, on garde la largeur de vue (sinon les côtés seraient coupés),
## la caméra recule et monte un peu. Paysage : on garde la hauteur de vue.
func _adapter_orientation() -> void:
	var config := Config.jeu
	var taille := get_viewport().get_visible_rect().size
	portrait = taille.y > taille.x
	var inclinaison := deg_to_rad(config.reglage_camera("inclinaison_portrait_degres", 40.0) if portrait
		else config.inclinaison_camera_degres())
	_distance = config.reglage_camera("distance_portrait", 6.2) if portrait else config.distance_camera()
	_camera.keep_aspect = Camera3D.KEEP_WIDTH if portrait else Camera3D.KEEP_HEIGHT
	_camera.fov = config.reglage_camera("champ_vision_portrait", 58.0) if portrait else config.champ_vision_camera()
	_visee = Vector3(0, config.hauteur_visee_camera(), 0)
	_direction = Vector3(0, sin(inclinaison), cos(inclinaison))
	_camera.rotation = Vector3(-inclinaison, 0, 0)
	_placer_la_camera(minf(_distance_actuelle, _distance))


## Si un grand décor coupe la vue entre le personnage et la caméra, la caméra se rapproche.
func _eviter_les_obstacles(delta: float) -> void:
	var voulue := _distance
	if is_inside_tree():
		var depart := global_transform * _visee
		var arrivee := global_transform * (_visee + _direction * _distance)
		var requete := PhysicsRayQueryParameters3D.create(depart, arrivee, COUCHE_MASQUE)
		var touche := get_world_3d().direct_space_state.intersect_ray(requete)
		if not touche.is_empty():
			var minimum := Config.jeu.reglage_camera("distance_minimale", 2.0)
			voulue = clampf(depart.distance_to(touche["position"]) - 0.4, minimum, _distance)
	_distance_actuelle = lerpf(_distance_actuelle, voulue, 1.0 - exp(-LISSAGE_OBSTACLE * delta))
	_placer_la_camera(_distance_actuelle)


func _placer_la_camera(distance: float) -> void:
	_camera.position = _visee + _direction * distance


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
