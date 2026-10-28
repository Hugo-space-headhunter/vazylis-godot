class_name Joueur
extends CharacterBody3D
## Le personnage du joueur : il se déplace selon le joystick, se tourne dans sa
## direction et joue les animations de repos, de marche et de course.

## Altitude en dessous de laquelle le personnage, tombé du terrain, revient au départ.
const ALTITUDE_CHUTE := -20.0

## Personnage affiché au démarrage (identifiant du catalogue).
@export var personnage_depart := IdentifiantsAssets.HEROS_HOMME

## Direction du joystick (longueur 0 à 1) et angle de la caméra, fournis par la scène.
var joystick := Vector2.ZERO
var angle_camera := 0.0

var personnage := ""
var _modele: ModeleAsset
var _allure := Deplacement.Allure.ARRET
var _depart := Vector3.ZERO
var _gravite: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	_depart = global_position
	changer_personnage(personnage_depart)


## Remplace le modèle affiché (ex. homme ↔ femme), sans toucher au reste.
func changer_personnage(id: String) -> void:
	if _modele != null:
		var rotation_actuelle := _modele.rotation.y
		_modele.queue_free()
		_modele = null
		_creer_modele(id, rotation_actuelle)
	else:
		_creer_modele(id, 0.0)


func modele() -> ModeleAsset:
	return _modele


func _creer_modele(id: String, rotation_y: float) -> void:
	personnage = id
	_modele = CatalogueAssets.creer(id)
	_modele.rotation.y = rotation_y
	add_child(_modele)
	_modele.jouer(Deplacement.animation(_allure), 0.0)


func _physics_process(delta: float) -> void:
	var config := Config.jeu
	var poussee := joystick.length()
	_allure = Deplacement.allure(poussee, config)
	var direction := Deplacement.direction_au_sol(joystick, angle_camera) if _allure != Deplacement.Allure.ARRET else Vector3.ZERO

	var horizontale := Vector3(velocity.x, 0.0, velocity.z)
	horizontale = horizontale.move_toward(direction * Deplacement.vitesse(poussee, config), config.acceleration() * delta)
	velocity.x = horizontale.x
	velocity.z = horizontale.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravite * delta
	move_and_slide()

	if global_position.y < ALTITUDE_CHUTE:
		global_position = _depart
		velocity = Vector3.ZERO

	if direction != Vector3.ZERO:
		var poids := 1.0 - exp(-config.lissage_rotation() * delta)
		_modele.rotation.y = lerp_angle(_modele.rotation.y, atan2(direction.x, direction.z), poids)
	_modele.jouer(Deplacement.animation(_allure), config.fondu_animation())
	_modele.regler_vitesse_animation(Deplacement.vitesse_animation(_allure, horizontale.length(), config))
