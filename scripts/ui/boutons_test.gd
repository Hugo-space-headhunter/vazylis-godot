extends VBoxContainer
## Boutons de test provisoires (en haut à droite) : homme ou femme, type d'arme, +1 niveau, butin.
## Ils disparaîtront avec l'écran de création du personnage et le butin.

signal arme_choisie(id: String)
signal niveau_demande
signal butin_demande

@onready var _arme: Button = $Arme
@onready var _niveau: Button = $Niveau
@onready var _butin: Button = $Butin

var _armes: PackedStringArray
var _actuelle := ""


func _ready() -> void:
	for bouton in get_children():
		bouton.add_to_group(CommandesTactiles.GROUPE_UI)
	_armes = Config.jeu.ids_armes()
	_arme.pressed.connect(_arme_suivante)
	_niveau.pressed.connect(niveau_demande.emit)
	_butin.pressed.connect(butin_demande.emit)


func afficher_arme(id: String) -> void:
	_actuelle = id
	_arme.text = str(Config.jeu.arme(id).get("nom", id))


func _arme_suivante() -> void:
	var index := _armes.find(_actuelle)
	arme_choisie.emit(_armes[(index + 1) % _armes.size()])
