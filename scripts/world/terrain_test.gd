extends Node3D
## Terrain de test : relie les commandes tactiles, le personnage, la caméra et l'interface.

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
	$Reperes/Cristal.add_child(CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST))


func _physics_process(_delta: float) -> void:
	_joueur.joystick = _commandes.direction
	_joueur.angle_camera = _camera.angle()


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
