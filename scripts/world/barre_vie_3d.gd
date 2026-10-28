class_name BarreVie3D
extends Node3D
## Petite barre de vie au-dessus d'un monstre, toujours tournée vers la caméra.

const LARGEUR := 64
const PIXEL := 0.012

static var _texture: ImageTexture

var _fond: Sprite3D
var _jauge: Sprite3D


func _init() -> void:
	if _texture == null:
		var image := Image.create(LARGEUR, 8, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		_texture = ImageTexture.create_from_image(image)
	_fond = _creer_sprite(Color(0, 0, 0, 0.6), 0)
	_jauge = _creer_sprite(Color(0.9, 0.2, 0.2), 1)
	visible = false


## ratio : de 0 (mort) à 1 (pleine vie).
func regler(ratio: float) -> void:
	_jauge.region_rect = Rect2(0, 0, maxf(1.0, LARGEUR * clampf(ratio, 0.0, 1.0)), 8)


func _creer_sprite(couleur: Color, priorite: int) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.texture = _texture
	sprite.modulate = couleur
	sprite.pixel_size = PIXEL
	sprite.centered = false
	sprite.offset = Vector2(-LARGEUR / 2.0, -4)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, LARGEUR, 8)
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.no_depth_test = true
	sprite.render_priority = priorite
	sprite.shaded = false
	add_child(sprite)
	return sprite
