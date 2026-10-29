extends VBoxContainer
## Boutons de test provisoires (en haut à droite) : homme ou femme, +1 niveau, butin.
## Ils disparaîtront avec l'écran de création du personnage.

signal niveau_demande
signal butin_demande

@onready var _niveau: Button = $Niveau
@onready var _butin: Button = $Butin


func _ready() -> void:
	for bouton in get_children():
		bouton.add_to_group(CommandesTactiles.GROUPE_UI)
	_niveau.pressed.connect(niveau_demande.emit)
	_butin.pressed.connect(butin_demande.emit)

