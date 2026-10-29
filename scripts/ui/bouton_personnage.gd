extends Button
## Bouton provisoire pour passer du personnage homme au personnage femme.
## Il disparaîtra avec l'écran de création du personnage.

signal personnage_choisi(id: String)

const PERSONNAGES := {
	IdentifiantsAssets.HEROS_HOMME: "Homme",
	IdentifiantsAssets.HEROS_FEMME: "Femme",
}

var _actuel := IdentifiantsAssets.HEROS_HOMME


func _ready() -> void:
	add_to_group(CommandesTactiles.GROUPE_UI)
	pressed.connect(_suivant)
	_afficher()


## Affiche le personnage choisi (par exemple après le chargement d'une partie).
func choisir(id: String) -> void:
	if PERSONNAGES.has(id):
		_actuel = id
		_afficher()


func _suivant() -> void:
	var ids := PERSONNAGES.keys()
	_actuel = ids[(ids.find(_actuel) + 1) % ids.size()]
	_afficher()
	personnage_choisi.emit(_actuel)


func _afficher() -> void:
	text = PERSONNAGES[_actuel]
