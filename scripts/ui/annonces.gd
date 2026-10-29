extends VBoxContainer
## Petits messages en haut de l'écran, qui s'effacent tout seuls (« Sac plein… »).

const DUREE := 2.5
const MAXIMUM := 3


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = BoxContainer.ALIGNMENT_BEGIN


func annoncer(texte: String, couleur: Color = Color.WHITE) -> void:
	var message := Label.new()
	message.text = texte
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 24)
	message.add_theme_color_override("font_color", couleur)
	message.add_theme_color_override("font_outline_color", Color.BLACK)
	message.add_theme_constant_override("outline_size", 6)
	add_child(message)
	while get_child_count() > MAXIMUM:
		get_child(0).free()
	var disparition := message.create_tween()
	disparition.tween_interval(DUREE)
	disparition.tween_property(message, "modulate:a", 0.0, 0.5)
	disparition.tween_callback(message.queue_free)
