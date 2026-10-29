class_name Joueur
extends CharacterBody3D
## Le personnage du joueur : il se déplace selon le joystick, se tourne dans sa
## direction et joue les animations de repos, de marche et de course.
## En mode combat, il frappe tout seul le monstre le plus proche à la portée de son arme.

signal mode_change(mode: Mode)
signal pv_change(pv: float, pv_max: float)
signal mana_change(mana: float, mana_max: float)
signal xp_change(xp: int, xp_requise: int, niveau: int)
signal niveau_gagne(niveau: int)
signal caracteristiques_change
signal arme_change(id_arme: String)
## Un objet vient d'arriver dans le sac (case), ou a été recyclé car le sac était plein (case = -1).
signal objet_obtenu(objet: Objet, case_numero: int, or_gagne: int)
signal mort
signal retour

const GROUPE := "joueur"
## Altitude en dessous de laquelle le personnage, tombé du terrain, revient au départ.
const ALTITUDE_CHUTE := -20.0
## Position des armes en main quand on n'attaque pas (voir « placements » du catalogue).
const VARIANTE_REPOS := "repos"
## Zone du monde où l'on joue (le butin prend le style de la zone).
const ZONE := 1
const POINTS_ATTACHE := {"modele_main_droite": "main_droite", "modele_main_gauche": "main_gauche"}

enum Mode { DEPLACEMENT, COMBAT }

## Personnage affiché au démarrage (identifiant du catalogue).
@export var personnage_depart := IdentifiantsAssets.HEROS_HOMME

## Direction du joystick (longueur 0 à 1) et angle de la caméra, fournis par la scène.
var joystick := Vector2.ZERO
var angle_camera := 0.0

var personnage := ""
var mode := Mode.DEPLACEMENT
var experience: Experience
var statistiques := Statistiques.new()
var inventaire: Inventaire
var butin: Butin
var id_arme := ""
var arme := {}
var pv := 1.0
var pv_max := 1.0
var mana := 0.0
var mana_max := 0.0

var _modele: ModeleAsset
var _armes := {}
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
	inventaire = Inventaire.new(Config.jeu)
	butin = Butin.new(Config.jeu)
	_remplir_sac_de_depart()
	experience.niveau_gagne.connect(_sur_niveau_gagne)
	statistiques.change.connect(_sur_statistiques)
	changer_personnage(personnage_depart)
	changer_arme(Config.jeu.arme_depart())
	_recalculer(true)
	_annoncer.call_deferred()


func niveau() -> int:
	return experience.niveau


func est_vivant() -> bool:
	return _vivant


func modele() -> ModeleAsset:
	return _modele


func defense() -> float:
	return Combat.defense_joueur(experience.niveau, statistiques, arme, Config.jeu)


## Remplace le modèle affiché (ex. homme ↔ femme), sans toucher au reste.
func changer_personnage(id: String) -> void:
	var rotation_actuelle := 0.0
	if _modele != null:
		rotation_actuelle = _modele.rotation.y
		for objet: ModeleAsset in _armes.values():
			objet.get_parent().remove_child(objet)
		_modele.queue_free()
	personnage = id
	_modele = CatalogueAssets.creer(id)
	_modele.rotation.y = rotation_actuelle
	add_child(_modele)
	_modele.jouer(Deplacement.animation(_allure), 0.0)
	_ranger_armes()


## Change de type d'arme (section de config/armes.cfg) et affiche ses modèles.
func changer_arme(id: String) -> void:
	for objet: ModeleAsset in _armes.values():
		objet.queue_free()
	_armes.clear()
	id_arme = id
	arme = Config.jeu.arme(id)
	for cle in POINTS_ATTACHE:
		var modele_id := str(arme.get(cle, ""))
		if not modele_id.is_empty():
			_armes[POINTS_ATTACHE[cle]] = CatalogueAssets.creer(modele_id)
	_ranger_armes()
	_coup_en_attente = -1.0
	if experience != null:
		_recalculer(false)
	arme_change.emit(id)


## Mode combat (armes sorties, attaque automatique) ou déplacement (armes rangées dans le dos).
func changer_mode(nouveau: Mode) -> void:
	mode = nouveau
	_cible = null
	_coup_en_attente = -1.0
	_ranger_armes()
	mode_change.emit(mode)


## Un monstre attaque : le bouclier peut bloquer, sinon la défense réduit les dégâts.
func recevoir_degats(degats_bruts: float, niveau_attaquant: int) -> void:
	if not _vivant:
		return
	var tete := global_position + Vector3.UP * 2.0
	if Combat.bloque(arme, _hasard):
		ChiffreFlottant.afficher(get_parent(), tete, "Bloqué", Color(0.75, 0.85, 1.0), 48)
		return
	var degats := Combat.degats_subis(degats_bruts, niveau_attaquant, defense(), Config.jeu)
	pv = maxf(0.0, pv - degats)
	pv_change.emit(pv, pv_max)
	ChiffreFlottant.afficher(get_parent(), tete, str(degats), ChiffreFlottant.COULEUR_DEGATS_SUBIS, 52)
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
		if mode == Mode.COMBAT:
			_varier_armes(VARIANTE_REPOS)
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
	var intervalle := 1.0 / Combat.vitesse_attaque(statistiques, arme, Config.jeu)
	_recharge_attaque = intervalle
	_tourner_vers(_cible.global_position, 1.0)
	var animation := str(arme.get("animation", "attack"))
	var duree := _modele.duree(animation)
	var vitesse := maxf(1.0, duree / intervalle)
	_varier_armes("")
	_modele.jouer(animation, 0.08, false, true)
	_modele.regler_vitesse_animation(vitesse)
	_verrou_animation = duree / vitesse
	_coup_en_attente = _verrou_animation * float(arme.get("moment_du_coup", 0.4))


func _frapper() -> void:
	if not is_instance_valid(_cible) or not _cible.est_vivant():
		return
	var cible := _cible
	if bool(arme.get("a_distance", false)):
		var depart := global_position + Vector3.UP * 1.4
		Fleche.tirer(get_parent(), depart, cible, _toucher.bind(cible))
	else:
		_toucher(cible)


func _toucher(cible: Monstre) -> void:
	if not is_instance_valid(cible) or not cible.est_vivant():
		return
	var coup := Combat.coup_joueur(experience.niveau, statistiques, arme, 0.0, cible.niveau, Config.jeu, _hasard)
	var niveau_cible := cible.niveau
	var position_cible := cible.global_position
	if cible.recevoir_coup(coup["degats"], coup["critique"]):
		gagner_xp(Experience.xp_gagnee(experience.niveau, niveau_cible, Config.jeu))
		for objet in butin.tirer_monstre(niveau_cible, ZONE, _hasard):
			recevoir_objet(objet, position_cible)


## Un objet est gagné : il va dans le sac, ou il est recyclé si le sac est plein.
func recevoir_objet(objet: Objet, position_depart: Vector3 = Vector3.INF) -> void:
	if position_depart != Vector3.INF and is_inside_tree():
		EffetButin.jouer(get_parent(), position_depart, objet, self, personnage == IdentifiantsAssets.HEROS_FEMME)
	var case_numero := inventaire.ajouter(objet)
	var or_gagne := inventaire.recycler_objet(objet) if case_numero == -1 else 0
	objet_obtenu.emit(objet, case_numero, or_gagne)


## Pour tester les builds : une arme standard de niveau 1 de chaque type dans le sac.
func _remplir_sac_de_depart() -> void:
	for famille in Config.jeu.ids_familles_objets():
		if str(Config.jeu.famille_objet(famille).get("emplacement", "")) == "arme":
			inventaire.ajouter(butin.creer_objet(famille, 1, "standard", _hasard))


func _monstre_a_portee() -> Monstre:
	var portee := float(arme.get("portee", 1.6))
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


func _ranger_armes() -> void:
	if _modele == null:
		return
	for point: String in _armes:
		if mode == Mode.COMBAT:
			_armes[point].accrocher_a(_modele, point, VARIANTE_REPOS)
		else:
			_armes[point].accrocher_a(_modele, "dos")


func _varier_armes(variante: String) -> void:
	for objet: ModeleAsset in _armes.values():
		objet.varier(variante)


## Recalcule vie, mana et défense après un changement de niveau, de statistiques ou d'arme.
## « soigner » remet la vie au maximum ; sinon la vie gagnée s'ajoute à la vie actuelle.
func _recalculer(soigner: bool) -> void:
	var ancien_max := pv_max
	pv_max = Combat.pv_joueur(experience.niveau, statistiques, Config.jeu)
	pv = pv_max if soigner else clampf(pv + maxf(0.0, pv_max - ancien_max), 0.0, pv_max)
	mana_max = Combat.mana(statistiques, Config.jeu)
	mana = mana_max
	pv_change.emit(pv, pv_max)
	mana_change.emit(mana, mana_max)
	caracteristiques_change.emit()


func _sur_statistiques() -> void:
	if not statistiques.a_des_points_en_attente():
		_recalculer(false)
	caracteristiques_change.emit()


func _sur_niveau_gagne(nouveau_niveau: int) -> void:
	statistiques.gagner_points(int(Config.jeu.statistique("points", "par_niveau")))
	_recalculer(true)
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
	_vivant = true
	_verrou_animation = 0.0
	_modele.jouer("idle", 0.0, true, true)
	_recalculer(true)
	retour.emit()


func _annoncer() -> void:
	pv_change.emit(pv, pv_max)
	mana_change.emit(mana, mana_max)
	xp_change.emit(experience.xp, experience.xp_pour_niveau_suivant(), experience.niveau)
	mode_change.emit(mode)
	arme_change.emit(id_arme)
	caracteristiques_change.emit()
