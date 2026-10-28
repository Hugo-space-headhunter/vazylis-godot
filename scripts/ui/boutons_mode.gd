extends HBoxContainer
## Les deux gros boutons en bas à droite : « Arme » (mode combat) et « Pied » (mode déplacement).

signal mode_choisi(mode: Joueur.Mode)

const COULEUR_ACTIF := Color(1.0, 0.85, 0.4)
const COULEUR_INACTIF := Color(1, 1, 1, 0.75)

@onready var _arme: Button = $Arme
@onready var _pied: Button = $Pied


func _ready() -> void:
	for bouton in [_arme, _pied]:
		bouton.add_to_group(CommandesTactiles.GROUPE_UI)
	_arme.pressed.connect(mode_choisi.emit.bind(Joueur.Mode.COMBAT))
	_pied.pressed.connect(mode_choisi.emit.bind(Joueur.Mode.DEPLACEMENT))


## Met en valeur le bouton du mode actif.
func afficher_mode(mode: Joueur.Mode) -> void:
	_arme.modulate = COULEUR_ACTIF if mode == Joueur.Mode.COMBAT else COULEUR_INACTIF
	_pied.modulate = COULEUR_ACTIF if mode == Joueur.Mode.DEPLACEMENT else COULEUR_INACTIF
