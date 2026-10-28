extends Node3D
## Terrain de test : relie les commandes tactiles, le personnage, la caméra et l'interface.

@onready var _joueur: Joueur = $Joueur
@onready var _camera: CameraSuiveuse = $CameraSuiveuse
@onready var _commandes: CommandesTactiles = $Interface/CommandesTactiles
@onready var _bouton_personnage: Button = $Interface/BoutonPersonnage
@onready var _boutons_mode: HBoxContainer = $Interface/BoutonsMode
@onready var _infos: VBoxContainer = $Interface/InfosProvisoires


func _ready() -> void:
	_commandes.rotation_camera.connect(_camera.tourner)
	_bouton_personnage.personnage_choisi.connect(_joueur.changer_personnage)
	_boutons_mode.mode_choisi.connect(_joueur.changer_mode)
	_joueur.mode_change.connect(_boutons_mode.afficher_mode)
	_joueur.pv_change.connect(_infos.afficher_pv)
	_joueur.xp_change.connect(_infos.afficher_xp)
	_joueur.mort.connect(_infos.afficher_mort)
	_joueur.retour.connect(_infos.cacher_message)
	$Reperes/Cristal.add_child(CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST))


func _physics_process(_delta: float) -> void:
	_joueur.joystick = _commandes.direction
	_joueur.angle_camera = _camera.angle()
