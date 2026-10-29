extends Button
## Mini-bouton « Statistiques » (icône des 4 éléments), avec une pastille
## qui indique les points à répartir.

@onready var _pastille: Label = $Pastille


func _ready() -> void:
	add_to_group(CommandesTactiles.GROUPE_UI)
	afficher_points(0)


func afficher_points(points: int) -> void:
	_pastille.text = "+%d" % points
	_pastille.visible = points > 0
