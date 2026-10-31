extends VBoxContainer
## Menu de test provisoire (en haut à droite) : le bouton « Test » ouvre la liste : homme ou femme,
## +1 niveau, butin, nouvelle partie, et le panneau de mesure (images par seconde).
## Il disparaîtra avec l'écran de création du personnage.

signal niveau_demande
signal butin_demande
signal nouvelle_partie_demandee

@onready var _niveau: Button = $Niveau
@onready var _butin: Button = $Butin
@onready var _nouvelle_partie: Button = $NouvellePartie
@onready var _menu: Button = $Menu
@onready var _mesures: Button = $Mesures

## Panneau de mesure à montrer ou cacher (le CompteurFPS).
@export var compteur: CanvasLayer


func _ready() -> void:
	for bouton in get_children():
		bouton.add_to_group(CommandesTactiles.GROUPE_UI)
	_niveau.pressed.connect(niveau_demande.emit)
	_butin.pressed.connect(butin_demande.emit)
	_nouvelle_partie.pressed.connect(nouvelle_partie_demandee.emit)
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

