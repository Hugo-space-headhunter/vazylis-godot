extends Label
## Panneau de mesure : les images par seconde, la taille de l'écran et l'orientation.
## Toucher le texte affiche le détail, pour mesurer le jeu sur le téléphone :
## temps d'une image, temps des scripts et de la physique, dessin, mémoire et monstres éveillés.

const INTERVALLE_SECONDES := 0.25

var detaille := false
var _attente := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Fond sombre, pour rester lisible par-dessus le bandeau quand le détail est ouvert.
	var fond := StyleBoxFlat.new()
	fond.bg_color = Color(0, 0, 0, 0.6)
	fond.set_corner_radius_all(8)
	fond.set_content_margin_all(6)
	add_theme_stylebox_override("normal", fond)
	add_to_group(CommandesTactiles.GROUPE_UI)
	gui_input.connect(_sur_toucher)


## Godot transforme chaque toucher en clic (et chaque clic en toucher) : on ne réagit qu'au clic,
## sinon le détail s'ouvrirait et se refermerait aussitôt.
func _sur_toucher(evenement: InputEvent) -> void:
	var clic := evenement as InputEventMouseButton
	if clic != null and clic.pressed and clic.button_index == MOUSE_BUTTON_LEFT:
		detaille = not detaille
		_attente = 0.0
		accept_event()


func _process(delta: float) -> void:
	_attente -= delta
	if _attente > 0.0:
		return
	_attente = INTERVALLE_SECONDES
	text = texte_mesures()


func texte_mesures() -> String:
	var taille := DisplayServer.window_get_size()
	var orientation := "portrait" if taille.y > taille.x else "paysage"
	var ips := Engine.get_frames_per_second()
	var lignes := PackedStringArray(["%d i/s · %d×%d · %s" % [ips, taille.x, taille.y, orientation]])
	if not detaille:
		return lignes[0]
	var image_ms := 1000.0 / maxf(1.0, ips)
	lignes.append("Image %s ms · scripts %s ms · physique %s ms" % [_ms(image_ms),
		_ms(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0),
		_ms(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)])
	lignes.append("Dessin : %d appels · %d k triangles · %d objets" % [
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)])
	var video := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0
	var jeu := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	lignes.append("Mémoire : vidéo %s · jeu %s" % [_mo(video), _mo(jeu)])
	lignes.append("Monstres éveillés : %d / %d" % [VeilleMonstres.monstres_eveilles(get_tree()),
		get_tree().get_nodes_in_group(Monstre.GROUPE).size()])
	return "\n".join(lignes)


## « 53 Mo », ou « ? » quand la plateforme ne donne pas la valeur (le web, pour la mémoire du jeu).
func _mo(valeur: float) -> String:
	return "%d Mo" % roundi(valeur) if valeur > 0.0 else "?"


func _ms(valeur: float) -> String:
	return ("%.1f" % valeur).replace(".", ",")
