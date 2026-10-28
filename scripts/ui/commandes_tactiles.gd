class_name CommandesTactiles
extends Control
## Commandes au doigt, sur tout l'écran :
## - premier doigt : joystick flottant, qui apparaît là où le pouce touche l'écran ;
## - deuxième doigt : glisser pour tourner la caméra.
## Sur le PC : clic gauche = premier doigt, glisser avec le clic droit = tourner la caméra.
##
## Les boutons de l'interface placés dans le groupe « ui_tactile » ne déclenchent pas le joystick.

signal rotation_camera(pixels: float)

const GROUPE_UI := "ui_tactile"
const COULEUR_FOND := Color(1, 1, 1, 0.18)
const COULEUR_BORD := Color(1, 1, 1, 0.45)
const COULEUR_BOUTON := Color(1, 1, 1, 0.6)

## Direction et force du joystick : longueur de 0 (relâché) à 1 (poussé à fond),
## x vers la droite, y vers le bas de l'écran.
var direction := Vector2.ZERO

var _rayon := 110.0
var _doigt_joystick := -1
var _doigt_camera := -1
var _centre := Vector2.ZERO
var _decalage := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rayon = Config.jeu.rayon_joystick()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_toucher(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_glisser(event as InputEventScreenDrag)
	elif event is InputEventMouseMotion and (event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_RIGHT:
		rotation_camera.emit((event as InputEventMouseMotion).relative.x)


func _toucher(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _doigt_joystick == -1 and not _sur_bouton(event.position):
			_doigt_joystick = event.index
			_centre = event.position
			_decalage = Vector2.ZERO
			direction = Vector2.ZERO
		elif _doigt_camera == -1 and event.index != _doigt_joystick:
			_doigt_camera = event.index
	else:
		if event.index == _doigt_joystick:
			_doigt_joystick = -1
			_decalage = Vector2.ZERO
			direction = Vector2.ZERO
		elif event.index == _doigt_camera:
			_doigt_camera = -1
	queue_redraw()


func _glisser(event: InputEventScreenDrag) -> void:
	if event.index == _doigt_joystick:
		_decalage = (event.position - _centre).limit_length(_rayon)
		direction = _decalage / _rayon
		queue_redraw()
	elif event.index == _doigt_camera:
		rotation_camera.emit(event.relative.x)


func _sur_bouton(position_ecran: Vector2) -> bool:
	for noeud in get_tree().get_nodes_in_group(GROUPE_UI):
		var controle := noeud as Control
		if controle != null and controle.is_visible_in_tree() and controle.get_global_rect().has_point(position_ecran):
			return true
	return false


func _draw() -> void:
	if _doigt_joystick == -1:
		return
	draw_circle(_centre, _rayon, COULEUR_FOND)
	draw_arc(_centre, _rayon, 0.0, TAU, 48, COULEUR_BORD, 3.0, true)
	draw_circle(_centre + _decalage, _rayon * 0.42, COULEUR_BOUTON)
