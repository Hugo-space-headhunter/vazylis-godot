class_name Joueur
extends CharacterBody3D
## Le personnage du joueur : il se déplace selon le joystick, se tourne dans sa
## direction et joue les animations de repos, de marche et de course.
## En mode combat, il frappe tout seul le monstre le plus proche à sa portée.

signal mode_change(mode: Mode)
signal pv_change(pv: float, pv_max: float)
signal xp_change(xp: int, xp_requise: int, niveau: int)
signal niveau_gagne(niveau: int)
signal mort
signal retour

const GROUPE := "joueur"
## Altitude en dessous de laquelle le personnage, tombé du terrain, revient au départ.
const ALTITUDE_CHUTE := -20.0
## Part de l'animation d'attaque à laquelle le coup touche (0,4 = un peu avant le milieu).
const MOMENT_DU_COUP := 0.4

enum Mode { DEPLACEMENT, COMBAT }

## Personnage affiché au démarrage (identifiant du catalogue).
@export var personnage_depart := IdentifiantsAssets.HEROS_HOMME

## Direction du joystick (longueur 0 à 1) et angle de la caméra, fournis par la scène.
var joystick := Vector2.ZERO
var angle_camera := 0.0

var personnage := ""
var mode := Mode.DEPLACEMENT
var experience: Experience
var pv := 1.0
var pv_max := 1.0

var _modele: ModeleAsset
var _arme: ModeleAsset
var _allure := Deplacement.Allure.ARRET
var _depart := Vector3.ZERO
var _vivant := true
var _recharge_attaque := 0.0
var _verrou_animation := 0.0
var _coup_en_attente := -1.0
var _cible: Monstre
var _hasard := RandomNumberGenerator.new()
var _gravite: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	add_to_group(GROUPE)
	_hasard.randomize()
	_depart = global_position
	experience = Experience.new(Config.jeu)
	experience.niveau_gagne.connect(_sur_niveau_gagne)
	pv_max = Combat.pv_joueur(experience.niveau, Config.jeu)
	pv = pv_max
	_arme = CatalogueAssets.creer(IdentifiantsAssets.EPEE_DEPART)
	changer_personnage(personnage_depart)
	_annoncer.call_deferred()


func niveau() -> int:
	return experience.niveau


func est_vivant() -> bool:
	return _vivant


func modele() -> ModeleAsset:
	return _modele


## Remplace le modèle affiché (ex. homme ↔ femme), sans toucher au reste.
func changer_personnage(id: String) -> void:
	var rotation_actuelle := 0.0
	if _modele != null:
		rotation_actuelle = _modele.rotation.y
		_arme.get_parent().remove_child(_arme)
		_modele.queue_free()
	personnage = id
	_modele = CatalogueAssets.creer(id)
	_modele.rotation.y = rotation_actuelle
	add_child(_modele)
	_modele.jouer(Deplacement.animation(_allure), 0.0)
	_ranger_arme()


## Mode combat (arme sortie, attaque automatique) ou déplacement (arme rangée dans le dos).
func changer_mode(nouveau: Mode) -> void:
	mode = nouveau
	_cible = null
	_coup_en_attente = -1.0
	_ranger_arme()
	mode_change.emit(mode)


func recevoir_degats(degats: int) -> void:
	if not _vivant:
		return
	pv = maxf(0.0, pv - degats)
	pv_change.emit(pv, pv_max)
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * 2.0, str(degats),
		ChiffreFlottant.COULEUR_DEGATS_SUBIS, 52)
	if pv <= 0.0:
		_mourir()


func gagner_xp(quantite: int) -> void:
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * 1.6, "+%d XP" % quantite,
		Color(0.55, 0.8, 1.0), 44, 1.2, 0.6)
	experience.ajouter_xp(quantite)
	xp_change.emit(experience.xp, experience.xp_pour_niveau_suivant(), experience.niveau)


func _physics_process(delta: float) -> void:
	var config := Config.jeu
	_recharge_attaque -= delta
	_verrou_animation -= delta
	var poussee := joystick.length() if _vivant else 0.0
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

	if not _vivant:
		return
	if mode == Mode.COMBAT:
		_combattre(delta)
	if direction != Vector3.ZERO and _verrou_animation <= 0.0:
		_tourner_vers(global_position + direction, 1.0 - exp(-config.lissage_rotation() * delta))
	if _verrou_animation <= 0.0:
		_modele.jouer(Deplacement.animation(_allure), config.fondu_animation())
		_modele.regler_vitesse_animation(Deplacement.vitesse_animation(_allure, horizontale.length(), config))


func _combattre(delta: float) -> void:
	if _coup_en_attente >= 0.0:
		_coup_en_attente -= delta
		if _coup_en_attente < 0.0:
			_frapper()
		return
	if _recharge_attaque > 0.0:
		return
	_cible = _monstre_a_portee()
	if _cible == null:
		return
	var intervalle := Combat.intervalle_attaque_joueur(Config.jeu)
	_recharge_attaque = intervalle
	_tourner_vers(_cible.global_position, 1.0)
	var duree := _modele.duree("attack")
	var vitesse := maxf(1.0, duree / intervalle)
	_modele.jouer("attack", 0.08, false, true)
	_modele.regler_vitesse_animation(vitesse)
	_verrou_animation = duree / vitesse
	_coup_en_attente = _verrou_animation * MOMENT_DU_COUP


func _frapper() -> void:
	if not is_instance_valid(_cible) or not _cible.est_vivant():
		return
	var coup := Combat.coup_joueur(experience.niveau, Config.jeu, _hasard)
	var niveau_cible := _cible.niveau
	if _cible.recevoir_coup(coup["degats"], coup["critique"]):
		gagner_xp(Experience.xp_gagnee(experience.niveau, niveau_cible, Config.jeu))


func _monstre_a_portee() -> Monstre:
	var portee := Config.jeu.combat("joueur", "portee_attaque")
	var plus_proche: Monstre = null
	var meilleure := INF
	for noeud in get_tree().get_nodes_in_group(Monstre.GROUPE):
		var monstre := noeud as Monstre
		var distance := Vector2(monstre.global_position.x - global_position.x,
			monstre.global_position.z - global_position.z).length()
		if monstre.est_vivant() and distance <= portee and distance < meilleure:
			plus_proche = monstre
			meilleure = distance
	return plus_proche


func _tourner_vers(point: Vector3, poids: float) -> void:
	var direction := point - global_position
	if Vector2(direction.x, direction.z).length() > 0.01:
		_modele.rotation.y = lerp_angle(_modele.rotation.y, atan2(direction.x, direction.z), poids)


func _ranger_arme() -> void:
	_arme.accrocher_a(_modele, "main_droite" if mode == Mode.COMBAT else "dos")


func _sur_niveau_gagne(nouveau_niveau: int) -> void:
	pv_max = Combat.pv_joueur(nouveau_niveau, Config.jeu)
	pv = pv_max
	pv_change.emit(pv, pv_max)
	EffetNiveau.jouer(self)
	niveau_gagne.emit(nouveau_niveau)


func _mourir() -> void:
	_vivant = false
	_coup_en_attente = -1.0
	_modele.jouer("die", 0.1, false)
	mort.emit()
	await get_tree().create_timer(Config.jeu.combat("joueur", "delai_reapparition"), false).timeout
	global_position = _depart
	velocity = Vector3.ZERO
	pv = pv_max
	_vivant = true
	_verrou_animation = 0.0
	_modele.jouer("idle", 0.0, true, true)
	pv_change.emit(pv, pv_max)
	retour.emit()


func _annoncer() -> void:
	pv_change.emit(pv, pv_max)
	xp_change.emit(experience.xp, experience.xp_pour_niveau_suivant(), experience.niveau)
	mode_change.emit(mode)
