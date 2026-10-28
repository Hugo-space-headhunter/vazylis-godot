extends Node3D
## Terrain de test de l'étape 1 : relie les commandes tactiles, le personnage et la caméra.

@onready var _joueur: Joueur = $Joueur
@onready var _camera: CameraSuiveuse = $CameraSuiveuse
@onready var _commandes: CommandesTactiles = $Interface/CommandesTactiles
@onready var _bouton_personnage: Button = $Interface/BoutonPersonnage


func _ready() -> void:
	_commandes.rotation_camera.connect(_camera.tourner)
	_bouton_personnage.personnage_choisi.connect(_joueur.changer_personnage)
	$Reperes/Cristal.add_child(CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST))


func _physics_process(_delta: float) -> void:
	_joueur.joystick = _commandes.direction
	_joueur.angle_camera = _camera.angle()
