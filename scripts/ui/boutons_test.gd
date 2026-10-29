extends VBoxContainer
## Boutons de test provisoires (en haut à droite) : homme ou femme, +1 niveau, butin, nouvelle partie.
## Ils disparaîtront avec l'écran de création du personnage.

signal niveau_demande
signal butin_demande
signal nouvelle_partie_demandee

@onready var _niveau: Button = $Niveau
@onready var _butin: Button = $Butin
@onready var _nouvelle_partie: Button = $NouvellePartie


func _ready() -> void:
	for bouton in get_children():
		bouton.add_to_group(CommandesTactiles.GROUPE_UI)
	_niveau.pressed.connect(niveau_demande.emit)
	_butin.pressed.connect(butin_demande.emit)
	_nouvelle_partie.pressed.connect(nouvelle_partie_demandee.emit)

