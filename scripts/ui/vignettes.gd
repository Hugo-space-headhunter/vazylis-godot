class_name Vignettes
extends Node
## Fabrique les petites images (vignettes) des objets à partir de leur modèle 3D :
## un modèle ajouté au catalogue a donc automatiquement sa vignette dans le sac.
## Les vignettes sont gardées en mémoire et fabriquées une par une.

signal vignette_prete(modele_id: String, texture: Texture2D)

const TAILLE := 128
const DIRECTION_CAMERA := Vector3(0.55, 0.45, 1.0)

var _cache := {}
var _file: PackedStringArray = []
var _en_cours := false


## Renvoie la vignette si elle existe déjà, sinon null (elle arrivera par « vignette_prete »).
func demander(modele_id: String) -> Texture2D:
	if _cache.has(modele_id):
		return _cache[modele_id]
	if not modele_id in _file:
		_file.append(modele_id)
		_suivante.call_deferred()
	return null


func _suivante() -> void:
	if _en_cours or _file.is_empty():
		return
	_en_cours = true
	var modele_id := _file[0]
	_file.remove_at(0)
	var texture := await _fabriquer(modele_id)
	_cache[modele_id] = texture
	vignette_prete.emit(modele_id, texture)
	_en_cours = false
	_suivante()


func _fabriquer(modele_id: String) -> Texture2D:
	var vue := SubViewport.new()
	vue.size = Vector2i(TAILLE, TAILLE)
	vue.transparent_bg = true
	vue.own_world_3d = true
	vue.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(vue)

	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_CLEAR_COLOR
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color(0.85, 0.85, 0.9)
	environnement.environment.ambient_light_energy = 0.8
	vue.add_child(environnement)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-40, 35, 0)
	vue.add_child(lumiere)

	var modele := CatalogueAssets.creer(modele_id)
	vue.add_child(modele)
	var boite := modele.boite_englobante()
	var camera := Camera3D.new()
	camera.fov = 30.0
	vue.add_child(camera)
	var rayon := maxf(boite.size.length() / 2.0, 0.05)
	var distance := rayon / sin(deg_to_rad(camera.fov / 2.0))
	camera.look_at_from_position(boite.get_center() + DIRECTION_CAMERA.normalized() * distance, boite.get_center())

	await RenderingServer.frame_post_draw
	var image := vue.get_texture().get_image()
	vue.queue_free()
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)
