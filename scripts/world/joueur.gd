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
signal equipement_change
## Un objet vient d'arriver dans le sac (case), ou a été recyclé : case = CASE_SAC_PLEIN si le sac
## était plein, CASE_RECYCLAGE_AUTO s'il correspondait aux filtres du recyclage automatique.
signal objet_obtenu(objet: Objet, case_numero: int, or_gagne: int)
signal mort
signal retour
## Quelque chose qui doit être sauvegardé a changé (niveau, points, sac, équipement…).
signal partie_change
## Le mode AFK est activé ou désactivé.
signal afk_change(actif: bool)

const GROUPE := "joueur"
## Altitude en dessous de laquelle le personnage, tombé du terrain, revient au départ.
const ALTITUDE_CHUTE := -20.0
## Position des armes en main quand on n'attaque pas (voir « placements » du catalogue).
const VARIANTE_REPOS := "repos"
## Zone du monde où l'on joue (le butin prend le style de la zone).
const ZONE := 1
const POINTS_ATTACHE := {"modele_main_droite": "main_droite", "modele_main_gauche": "main_gauche"}
const CASE_SAC_PLEIN := -1
const CASE_RECYCLAGE_AUTO := -2

enum Mode { DEPLACEMENT, COMBAT }

## Personnage affiché au démarrage (identifiant du catalogue).
@export var personnage_depart := IdentifiantsAssets.HEROS_HOMME

## Direction du joystick (longueur 0 à 1) et angle de la caméra, fournis par la scène.
var joystick := Vector2.ZERO
var angle_camera := 0.0

var personnage := ""
var mode := Mode.DEPLACEMENT
var experience: Experience
## Points de statistiques répartis par le joueur (sans les objets portés).
var statistiques := Statistiques.new()
var inventaire: Inventaire
var butin: Butin
var equipement := Equipement.new()
var recyclage_auto := RecyclageAuto.new()
## Type de l'arme portée (section de config/armes.cfg) et ses réglages.
var id_arme := ""
var arme := {}
var pv := 1.0
var pv_max := 1.0
var mana := 0.0
var mana_max := 0.0
## Mode AFK : le personnage cible et enchaîne seul les monstres autour de son point d'activation.
var afk := false

var _modele: ModeleAsset
var _armes := {}
var _habillage := Habillage.new()
var _allure := Deplacement.Allure.ARRET
var _depart := Vector3.ZERO
var _vivant := true
var _recharge_attaque := 0.0
var _verrou_animation := 0.0
var _coup_en_attente := -1.0
var _cible: Monstre
var _point_afk := Vector3.ZERO
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
	equiper_objet(butin.creer_objet(Config.jeu.objet_depart(), 1, "standard", _hasard))
	_recalculer(true)
	_surveiller_la_partie()
	_annoncer.call_deferred()


## Endroit où le personnage revient après sa mort (Vazylis).
func definir_point_de_retour(point: Vector3) -> void:
	_depart = point


## Active ou coupe le mode AFK. Il sort les armes et vise les monstres autour de l'endroit
## où il est activé. Toucher le joystick reprend la main : le mode AFK reprend là où on lâche.
func activer_afk(actif: bool) -> void:
	if afk == actif:
		return
	afk = actif
	_point_afk = global_position
	if afk and mode != Mode.COMBAT:
		changer_mode(Mode.COMBAT)
	afk_change.emit(afk)


func niveau() -> int:
	return experience.niveau


func est_vivant() -> bool:
	return _vivant


func modele() -> ModeleAsset:
	return _modele


## Statistiques avec les points des objets portés.
func statistiques_effectives(points: Statistiques = null) -> Statistiques:
	return (points if points != null else statistiques).avec_bonus(equipement.statistiques_totales())


func defense() -> float:
	return Combat.defense_joueur(experience.niveau, statistiques_effectives(), arme, Config.jeu, equipement.armure_totale())


## Caractéristiques de combat, avec des points de statistiques donnés (pour l'aperçu de la fenêtre).
func caracteristiques(points: Statistiques = null) -> Dictionary:
	var config := Config.jeu
	var stats := statistiques_effectives(points)
	var bonus := equipement.bonus_totaux()
	var niveau_actuel := experience.niveau
	return {
		"degats": Combat.degats_coup(niveau_actuel, stats, arme, config, _degats_arme(), bonus),
		"vitesse": Combat.vitesse_attaque(stats, arme, config, bonus),
		"critique": Combat.chance_critique(stats, arme, config, bonus),
		"pv": Combat.pv_joueur(niveau_actuel, stats, config, bonus),
		"defense": Combat.defense_joueur(niveau_actuel, stats, arme, config, equipement.armure_totale()),
		"mana": Combat.mana(stats, config),
		"statistiques": stats,
	}


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
	_habillage.habiller(_modele, equipement, est_une_femme())


func est_une_femme() -> bool:
	return personnage == IdentifiantsAssets.HEROS_FEMME


## Porte un objet (sans passer par le sac). Renvoie l'objet qui était porté à cet endroit, ou null.
func equiper_objet(objet: Objet, emplacement: String = "") -> Objet:
	var ancien := equipement.equiper(objet, emplacement)
	if ancien == objet:
		return null
	if objet.est_arme():
		_appliquer_arme()
	else:
		_habillage.habiller(_modele, equipement, est_une_femme())
	_recalculer(false)
	equipement_change.emit()
	return ancien


## Porte l'objet d'une case du sac ; l'objet qui était porté prend sa place dans le sac.
func equiper_depuis_sac(case_numero: int, emplacement: String = "") -> bool:
	var objet := inventaire.objet(case_numero)
	if objet == null:
		return false
	if emplacement.is_empty():
		emplacement = equipement.emplacement_pour(objet)
	if not equipement.accepte(emplacement, objet):
		return false
	inventaire.retirer(case_numero)
	var ancien := equiper_objet(objet, emplacement)
	if ancien != null:
		inventaire.cases[case_numero] = ancien
		inventaire.change.emit()
	return true


## Retire un objet porté et le range dans le sac. L'arme ne se retire pas : on la remplace.
func retirer_vers_sac(emplacement: String) -> bool:
	if emplacement == "arme" or equipement.objet(emplacement) == null or inventaire.est_plein():
		return false
	inventaire.ajouter(equipement.retirer(emplacement))
	_habillage.habiller(_modele, equipement, est_une_femme())
	_recalculer(false)
	equipement_change.emit()
	return true


func _degats_arme() -> float:
	var objet := equipement.arme()
	return objet.degats if objet != null else -1.0


## Affiche les modèles de l'arme portée et règle son type (vitesse, portée, affinité…).
func _appliquer_arme() -> void:
	for objet: ModeleAsset in _armes.values():
		objet.queue_free()
	_armes.clear()
	var objet := equipement.arme()
	var famille := Config.jeu.famille_objet(objet.famille)
	id_arme = objet.type_arme
	arme = Config.jeu.arme(id_arme)
	for cle in POINTS_ATTACHE:
		var modele_id := str(famille.get(cle, arme.get(cle, "")))
		if not modele_id.is_empty():
			var modele_arme := CatalogueAssets.creer(modele_id)
			ApparenceRarete.appliquer(modele_arme, objet.rarete)
			ApparenceRarete.ajouter_etincelles(modele_arme, objet.rarete, modele_arme.boite_englobante())
			_armes[POINTS_ATTACHE[cle]] = modele_arme
	_ranger_armes()
	_coup_en_attente = -1.0
	arme_change.emit(id_arme)


## Mode combat (armes sorties, attaque automatique) ou déplacement (armes rangées dans le dos).
func changer_mode(nouveau: Mode) -> void:
	mode = nouveau
	if nouveau == Mode.DEPLACEMENT:
		activer_afk(false)
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
	if afk and _vivant:
		if _allure != Deplacement.Allure.ARRET:
			_point_afk = global_position
		else:
			direction = _direction_afk()
			if direction != Vector3.ZERO:
				poussee = config.poussee_afk()
				_allure = Deplacement.allure(poussee, config)

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
	var intervalle := 1.0 / Combat.vitesse_attaque(statistiques_effectives(), arme, Config.jeu, equipement.bonus_totaux())
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
	var coup := Combat.coup_joueur(experience.niveau, statistiques_effectives(), arme, 0.0, cible.niveau, Config.jeu,
		_hasard, _degats_arme(), equipement.bonus_totaux())
	var niveau_cible := cible.niveau
	var position_cible := cible.global_position
	if cible.recevoir_coup(coup["degats"], coup["critique"]):
		var multiplicateur := Combat.multiplicateur_xp(cible.rang, Config.jeu)
		gagner_xp(Experience.xp_gagnee(experience.niveau, niveau_cible, Config.jeu, multiplicateur))
		var gains := butin.tirer(cible.rang, niveau_cible, ZONE, _hasard, cible.ressource, cible.id_monstre)
		for objet: Objet in gains["objets"]:
			recevoir_objet(objet, position_cible)
		recevoir_ressources(gains["ressources"])


## Des ressources sont gagnées : elles vont dans le sac, sans prendre de case.
func recevoir_ressources(gains: Dictionary) -> void:
	if gains.is_empty():
		return
	inventaire.ajouter_ressources(gains)
	if not is_inside_tree():
		return
	var hauteur := 2.2
	for id: String in gains:
		var ressource := Config.jeu.ressource(id)
		ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * hauteur,
			"+%d %s" % [gains[id], ressource.get("nom", id)], ressource.get("couleur", Color.WHITE), 34, 1.1, 0.5)
		hauteur += 0.3


## Un objet est gagné : il va dans le sac, ou il est recyclé (filtres du recyclage automatique,
## ou sac plein).
func recevoir_objet(objet: Objet, position_depart: Vector3 = Vector3.INF) -> void:
	if position_depart != Vector3.INF and is_inside_tree():
		EffetButin.jouer(get_parent(), position_depart, objet, self, est_une_femme())
	if recyclage_auto.doit_recycler(objet, Config.jeu):
		var gain := inventaire.recycler_objet(objet)
		if is_inside_tree():
			ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * 1.9, "+%d or" % gain,
				Color(1, 0.85, 0.35), 36, 1.0, 0.5)
		objet_obtenu.emit(objet, CASE_RECYCLAGE_AUTO, gain)
		return
	var case_numero := inventaire.ajouter(objet)
	var or_gagne := inventaire.recycler_objet(objet) if case_numero == CASE_SAC_PLEIN else 0
	objet_obtenu.emit(objet, case_numero, or_gagne)


## Recycle tous les objets du sac qui correspondent aux filtres (même si le recyclage auto est éteint).
## Renvoie l'or gagné.
func recycler_le_sac_selon_les_filtres() -> int:
	var actif := recyclage_auto.actif
	recyclage_auto.actif = true
	var gain := 0
	for case_numero in inventaire.nombre_cases():
		var objet := inventaire.objet(case_numero)
		if objet != null and recyclage_auto.doit_recycler(objet, Config.jeu):
			gain += inventaire.recycler(case_numero)
	recyclage_auto.actif = actif
	return gain


## Pour tester les builds : une arme standard de niveau 1 de chaque type dans le sac.
func _remplir_sac_de_depart() -> void:
	for famille in Config.jeu.ids_familles_objets():
		if str(Config.jeu.famille_objet(famille).get("emplacement", "")) == "arme":
			inventaire.ajouter(butin.creer_objet(famille, 1, "standard", _hasard))


## La partie du joueur, mise en forme pour la sauvegarde.
func exporter_partie() -> Dictionary:
	var partie := Partie.new()
	partie.personnage = personnage
	partie.niveau = experience.niveau
	partie.xp = experience.xp
	partie.statistiques = statistiques
	partie.inventaire = inventaire
	partie.equipement = equipement
	partie.recyclage_auto = recyclage_auto
	partie.monstres_sans_dore = butin.monstres_sans_dore
	partie.monstres_sans_epique = butin.monstres_sans_epique
	partie.victoires_sans_epique = butin.victoires_sans_epique
	return partie.vers_dictionnaire()


## Reprend une partie sauvegardée.
func importer_partie(partie: Partie) -> void:
	experience.niveau = partie.niveau
	experience.xp = partie.xp
	statistiques.valeurs = partie.statistiques.valeurs
	statistiques.points_libres = partie.statistiques.points_libres
	statistiques.annuler()
	inventaire.cases = partie.inventaire.cases
	inventaire.or_possede = partie.inventaire.or_possede
	inventaire.ressources = partie.inventaire.ressources
	inventaire.change.emit()
	recyclage_auto.actif = partie.recyclage_auto.actif
	recyclage_auto.rarete_limite = partie.recyclage_auto.rarete_limite
	recyclage_auto.types = partie.recyclage_auto.types
	butin.monstres_sans_dore = partie.monstres_sans_dore
	butin.monstres_sans_epique = partie.monstres_sans_epique
	butin.victoires_sans_epique = partie.victoires_sans_epique
	equipement.objets = partie.equipement.objets
	if equipement.arme() == null:
		equipement.objets["arme"] = butin.creer_objet(Config.jeu.objet_depart(), 1, "standard", _hasard)
	if partie.personnage in [IdentifiantsAssets.HEROS_HOMME, IdentifiantsAssets.HEROS_FEMME]:
		changer_personnage(partie.personnage)
	_appliquer_arme()
	_habillage.habiller(_modele, equipement, est_une_femme())
	_recalculer(true)
	_annoncer()


## Relie les changements à sauvegarder au signal « partie_change ».
func _surveiller_la_partie() -> void:
	var signaler := func(_a = null, _b = null, _c = null) -> void: partie_change.emit()
	for source: Signal in [xp_change, equipement_change, inventaire.change, statistiques.change, recyclage_auto.change]:
		source.connect(signaler)


## Mode AFK : direction vers le monstre le plus proche du personnage (dans le rayon autour du point
## d'activation, hors sous-boss), ou vers le point d'activation s'il n'y en a pas. Zéro quand il est
## arrivé (assez près pour frapper, ou revenu à son point).
func _direction_afk() -> Vector3:
	if _verrou_animation > 0.0 or _coup_en_attente >= 0.0:
		return Vector3.ZERO
	var rayon := Config.jeu.rayon_afk()
	var cible: Monstre = null
	var meilleure := INF
	for noeud in get_tree().get_nodes_in_group(Monstre.GROUPE):
		var monstre := noeud as Monstre
		if not monstre.est_vivant() or monstre.rang == Combat.RANG_SOUS_BOSS:
			continue
		if _distance_sol(monstre.global_position, _point_afk) > rayon:
			continue
		var distance := _distance_sol(monstre.global_position, global_position)
		if distance < meilleure:
			cible = monstre
			meilleure = distance
	var arret := float(arme.get("portee", 1.6)) * Config.jeu.part_portee_afk()
	var destination := _point_afk
	if cible != null:
		destination = cible.global_position
	else:
		arret = 0.5
	var vers := destination - global_position
	vers.y = 0.0
	if vers.length() <= arret:
		return Vector3.ZERO
	return vers.normalized()


func _distance_sol(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


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


## Recalcule vie, mana et défense après un changement de niveau, de statistiques ou d'objet porté.
## « soigner » remet la vie au maximum ; sinon la vie gagnée s'ajoute à la vie actuelle.
func _recalculer(soigner: bool) -> void:
	var ancien_max := pv_max
	var stats := statistiques_effectives()
	pv_max = Combat.pv_joueur(experience.niveau, stats, Config.jeu, equipement.bonus_totaux())
	pv = pv_max if soigner else clampf(pv + maxf(0.0, pv_max - ancien_max), 0.0, pv_max)
	mana_max = Combat.mana(stats, Config.jeu)
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
	activer_afk(false)
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
	equipement_change.emit()
	caracteristiques_change.emit()
