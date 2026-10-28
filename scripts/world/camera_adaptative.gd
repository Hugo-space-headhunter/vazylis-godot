extends Camera3D
## Caméra qui garde la même largeur de vue en portrait,
## pour que la scène ne soit pas coupée sur les côtés quand on tourne le téléphone.


func _ready() -> void:
	get_viewport().size_changed.connect(_adapter)
	_adapter()


func _adapter() -> void:
	var taille := get_viewport().get_visible_rect().size
	keep_aspect = Camera3D.KEEP_WIDTH if taille.y > taille.x else Camera3D.KEEP_HEIGHT
