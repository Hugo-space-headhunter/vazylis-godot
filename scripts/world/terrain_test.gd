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


func _ready() -> void:
	_commandes.rotation_camera.connect(_camera.tourner)
	_bouton_personnage.personnage_choisi.connect(_changer_personnage)
	_boutons_mode.mode_choisi.connect(_joueur.changer_mode)
	_outils_test.arme_choisie.connect(_joueur.changer_arme)
	_outils_test.niveau_demande.connect(_gagner_un_niveau)
	_bouton_statistiques.pressed.connect(_fenetre.basculer)
	_fenetre.relier(_joueur)

	_joueur.mode_change.connect(_boutons_mode.afficher_mode)
	_joueur.arme_change.connect(_outils_test.afficher_arme)
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


func _afficher_points() -> void:
	_bouton_statistiques.afficher_points(_joueur.statistiques.points_restants())
