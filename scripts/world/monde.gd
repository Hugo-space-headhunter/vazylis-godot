extends Node3D
## Le monde : Vazylis au centre et les zones autour. Relie les commandes tactiles, le personnage,
## la caméra et l'interface, et annonce le nom de la zone où l'on entre.

const NOMS := {
	IdentifiantsAssets.HEROS_HOMME: "Vazylien",
	IdentifiantsAssets.HEROS_FEMME: "Vazylienne",
}

@onready var _joueur: Joueur = $Joueur
@onready var _camera: CameraSuiveuse = $CameraSuiveuse
@onready var _commandes: CommandesTactiles = $Interface/CommandesTactiles
@onready var _outils_test: VBoxContainer = $Interface/OutilsTest
@onready var _bouton_personnage: Button = $Interface/OutilsTest/BoutonPersonnage
@onready var _boutons_mode: HBoxContainer = $Interface/BoutonsMode
@onready var _bandeau: PanelContainer = $Interface/Bandeau
@onready var _bouton_statistiques: Button = $Interface/BoutonStatistiques
@onready var _fenetre: PanelContainer = $Interface/FenetreStatistiques
@onready var _bouton_sac: Button = $Interface/BoutonSac
@onready var _fenetre_sac: PanelContainer = $Interface/FenetreSac
@onready var _vignettes: Vignettes = $Interface/Vignettes
@onready var _annonces: VBoxContainer = $Interface/Annonces
@onready var _bouton_afk: Button = $Interface/BoutonAFK
@onready var _zones: Node3D = $Zones

var _zone_actuelle: Zone
var _verification_zone := 0.0
var _ciel_depart := Color.WHITE
var _ambiance_depart := 1.0
var _soleil_depart := 1.0


func _ready() -> void:
	_commandes.rotation_camera.connect(_camera.tourner)
	_bouton_personnage.personnage_choisi.connect(_changer_personnage)
	_boutons_mode.mode_choisi.connect(_joueur.changer_mode)
	_outils_test.niveau_demande.connect(_gagner_un_niveau)
	_bouton_statistiques.pressed.connect(_fenetre.basculer)
	_fenetre.relier(_joueur)
	_bouton_sac.add_to_group(CommandesTactiles.GROUPE_UI)
	_bouton_sac.pressed.connect(_fenetre_sac.basculer)
	_fenetre_sac.relier(_joueur, _vignettes)
	_fenetre_sac.or_gagne.connect(func(quantite: int, raison: String) -> void:
		_annonces.annoncer("Recyclé : %s (+%d or)" % [raison, quantite], Color(1, 0.85, 0.35)))
	_outils_test.butin_demande.connect(_butin_de_test)
	_joueur.objet_obtenu.connect(_sur_objet_obtenu)

	_joueur.mode_change.connect(_boutons_mode.afficher_mode)
	_joueur.pv_change.connect(_bandeau.afficher_pv)
	_joueur.mana_change.connect(_bandeau.afficher_mana)
	_joueur.xp_change.connect(_bandeau.afficher_xp)
	_joueur.mort.connect(_bandeau.afficher_mort)
	_joueur.retour.connect(_bandeau.cacher_message)
	_joueur.statistiques.change.connect(_afficher_points)
	_bandeau.afficher_nom(NOMS[_joueur.personnage])
	_outils_test.nouvelle_partie_demandee.connect(_demander_nouvelle_partie)
	Sauvegarde.etat_change.connect(_bandeau.afficher_sauvegarde)
	Sauvegarde.sauvegarde_en_ligne_plus_recente.connect(func() -> void:
		_annonces.annoncer("Une sauvegarde en ligne plus récente existe : relance l'app pour la reprendre.",
			Color(1, 0.7, 0.4)))
	_bandeau.afficher_sauvegarde(Sauvegarde.etat)
	$Zones/Vazylis/Cristal.add_child(CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST))
	_joueur.definir_point_de_retour(($Zones/Vazylis/PointDeRetour as Node3D).global_position)
	_bouton_afk.add_to_group(CommandesTactiles.GROUPE_UI)
	_bouton_afk.toggled.connect(_joueur.activer_afk)
	_joueur.afk_change.connect(_bouton_afk.set_pressed_no_signal)
	_joueur.afk_change.connect(func(actif: bool) -> void:
		_bouton_afk.modulate = _boutons_mode.COULEUR_ACTIF if actif else Color(1, 1, 1, 0.75))
	_bouton_afk.modulate = Color(1, 1, 1, 0.75)
	# Une copie, pour que les changements d'ambiance ne modifient pas la scène d'origine.
	$Environnement.environment = ($Environnement.environment as Environment).duplicate()
	var environnement: Environment = $Environnement.environment
	_ciel_depart = environnement.background_color
	_ambiance_depart = environnement.ambient_light_energy
	_soleil_depart = ($Soleil as DirectionalLight3D).light_energy
	_reprendre_la_partie()


## Charge la partie sauvegardée (s'il y en a une), puis sauvegarde à chaque changement.
func _reprendre_la_partie() -> void:
	var partie := Partie.depuis_dictionnaire(await Sauvegarde.charger(), Config.jeu)
	if partie != null:
		_joueur.importer_partie(partie)
		_bouton_personnage.choisir(_joueur.personnage)
		_bandeau.afficher_nom(NOMS[_joueur.personnage])
	_joueur.partie_change.connect(func() -> void: Sauvegarde.enregistrer(_joueur.exporter_partie()))


## Pour tester un autre build : efface la sauvegarde et recommence (après confirmation).
func _demander_nouvelle_partie() -> void:
	var confirmation := ConfirmationDialog.new()
	confirmation.title = "Nouvelle partie"
	confirmation.dialog_text = "Effacer la partie (niveau, points, sac, équipement)\net recommencer de zéro ?"
	confirmation.ok_button_text = "Effacer"
	confirmation.cancel_button_text = "Annuler"
	confirmation.get_label().add_theme_font_size_override("font_size", 24)
	for bouton: Button in [confirmation.get_ok_button(), confirmation.get_cancel_button()]:
		bouton.add_theme_font_size_override("font_size", 24)
		bouton.custom_minimum_size = Vector2(160, 60)
	confirmation.confirmed.connect(_nouvelle_partie)
	confirmation.canceled.connect(confirmation.queue_free)
	$Interface.add_child(confirmation)
	confirmation.popup_centered(Vector2i(580, 260))


func _nouvelle_partie() -> void:
	await Sauvegarde.effacer()
	get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	_joueur.joystick = _commandes.direction
	_joueur.angle_camera = _camera.angle()
	_verification_zone -= delta
	if _verification_zone <= 0.0:
		_verification_zone = 0.5
		_surveiller_la_zone()


## Annonce le nom de la zone quand on en change (la première zone qui contient le joueur gagne :
## Vazylis passe avant les Prés qui l'entourent).
func _surveiller_la_zone() -> void:
	for enfant in _zones.get_children():
		var zone := enfant as Zone
		if zone != null and zone.contient(_joueur.global_position):
			if zone != _zone_actuelle:
				_zone_actuelle = zone
				_annonces.annoncer(zone.titre(), Color(0.95, 0.92, 0.8))
				_changer_d_ambiance(zone)
			return


## Le ciel et la lumière changent doucement selon la zone (le Bois des Lucioles est plus sombre).
func _changer_d_ambiance(zone: Zone) -> void:
	var environnement: Environment = $Environnement.environment
	var ciel := zone.couleur_ciel if zone.couleur_ciel.a > 0.0 else _ciel_depart
	var transition := create_tween().set_parallel()
	transition.tween_property(environnement, "background_color", ciel, 1.5)
	transition.tween_property(environnement, "ambient_light_energy", _ambiance_depart * zone.lumiere, 1.5)
	transition.tween_property($Soleil, "light_energy", _soleil_depart * zone.lumiere, 1.5)


func zone_actuelle() -> Zone:
	return _zone_actuelle


func _changer_personnage(id: String) -> void:
	_joueur.changer_personnage(id)
	_bandeau.afficher_nom(NOMS[id])


func _gagner_un_niveau() -> void:
	var experience := _joueur.experience
	_joueur.gagner_xp(experience.xp_pour_niveau_suivant() - experience.xp)


## Pour tester : un objet de chaque rareté, du niveau du joueur, qui tombe devant lui.
func _butin_de_test() -> void:
	var hasard := RandomNumberGenerator.new()
	hasard.randomize()
	var devant := _joueur.global_position + _joueur.modele().global_basis.z * 1.5
	for rarete in Config.jeu.ids_raretes():
		var objet := _joueur.butin.creer_objet(_joueur.butin.tirer_famille(Joueur.ZONE, hasard), _joueur.niveau(), rarete, hasard)
		_joueur.recevoir_objet(objet, devant + Vector3(hasard.randf_range(-1.2, 1.2), 0, hasard.randf_range(-0.5, 0.5)))


func _sur_objet_obtenu(objet: Objet, case_numero: int, or_gagne: int) -> void:
	if case_numero == Joueur.CASE_SAC_PLEIN:
		_annonces.annoncer("Sac plein : %s recyclé (+%d or)" % [objet.nom, or_gagne], Color(1, 0.75, 0.4))


func _afficher_points() -> void:
	_bouton_statistiques.afficher_points(_joueur.statistiques.points_restants())
