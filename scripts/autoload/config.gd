extends Node
## Autoload « Config » : donne accès partout aux valeurs d'équilibrage.
## Exemple : Config.jeu.multiplicateur_rarete("dore")

var jeu: ConfigJeu


func _init() -> void:
	jeu = ConfigJeu.charger()
