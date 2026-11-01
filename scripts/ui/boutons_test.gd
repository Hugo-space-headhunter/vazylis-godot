extends VBoxContainer
## Menu de test provisoire (en haut à droite) : le bouton « Test » ouvre la liste : homme ou femme,
## +1 niveau, butin, nouvelle partie, le panneau de mesure (images par seconde) et l'apparence
## (coiffure, barbe, couleur des cheveux).
## Il disparaîtra avec l'écran de création du personnage.

signal niveau_demande
signal butin_demande
signal nouvelle_partie_demandee
## Choix suivant pour l'apparence : « coiffure », « barbe » ou « couleur ».
signal apparence_demandee(champ: String)

@onready var _niveau: Button = $Niveau
@onready var _butin: Button = $Butin
@onready var _nouvelle_partie: Button = $NouvellePartie
@onready var _menu: Button = $Menu
@onready var _mesures: Button = $Mesures

## Panneau de mesure à montrer ou cacher (le CompteurFPS).
@export var compteur: CanvasLayer


func _ready() -> void:
	for bouton: Button in get_children():
		bouton.add_to_group(CommandesTactiles.GROUPE_UI)
		# Bordure rouge : ces outils de développement ne font pas partie de l'interface du joueur.
		bouton.theme_type_variation = "BoutonDev"
	_niveau.pressed.connect(niveau_demande.emit)
	_butin.pressed.connect(butin_demande.emit)
	_nouvelle_partie.pressed.connect(nouvelle_partie_demandee.emit)
	# En attendant un écran de création du personnage : changer d'apparence.
	$Coiffure.pressed.connect(apparence_demandee.emit.bind("coiffure"))
	$Barbe.pressed.connect(apparence_demandee.emit.bind("barbe"))
	$CouleurCheveux.pressed.connect(apparence_demandee.emit.bind("couleur"))
	_menu.pressed.connect(func() -> void: ouvrir(not est_ouvert()))
	_mesures.pressed.connect(func() -> void:
		if compteur != null:
			compteur.visible = not compteur.visible)
	ouvrir(false)


## Ouvre ou referme la liste des boutons de test.
func ouvrir(ouvert: bool) -> void:
	for bouton: Control in get_children():
		if bouton != _menu:
			bouton.visible = ouvert
	_menu.text = "Test ▴" if ouvert else "Test ▾"
	reset_size()


func est_ouvert() -> bool:
	return _niveau.visible

