extends Label
## Affiche les images par seconde, la taille de l'écran et l'orientation.

const INTERVALLE_SECONDES := 0.25

var _attente := 0.0


func _process(delta: float) -> void:
	_attente -= delta
	if _attente > 0.0:
		return
	_attente = INTERVALLE_SECONDES
	var taille := DisplayServer.window_get_size()
	var orientation := "portrait" if taille.y > taille.x else "paysage"
	text = "%d i/s · %d×%d · %s" % [Engine.get_frames_per_second(), taille.x, taille.y, orientation]
