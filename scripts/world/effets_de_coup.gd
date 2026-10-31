class_name EffetsDeCoup
extends RefCounted
## Petits effets visuels du combat, brefs et sobres :
##   - étincelles à l'endroit où un coup porte (plus nombreuses et dorées sur un critique) ;
##   - nuage de poussière quand un monstre meurt.
## Chaque effet se détruit tout seul une fois joué. Particules calculées par le processeur
## (CPUParticles3D), peu nombreuses : sans coût notable sur téléphone.

const COULEUR_COUP := Color(1.0, 0.92, 0.75)
const COULEUR_CRITIQUE := Color(1.0, 0.75, 0.25)
const COULEUR_POUSSIERE := Color(0.55, 0.5, 0.45, 0.7)

static var _matiere_etincelle: StandardMaterial3D
static var _matiere_poussiere: StandardMaterial3D
static var _texture_tache: Texture2D


## Gerbe d'étincelles qui part du point d'impact.
static func etincelles(parent: Node, position: Vector3, critique: bool) -> void:
	var particules := _creer(parent, position, 18 if critique else 9, 0.35)
	particules.direction = Vector3.UP
	particules.spread = 75.0
	particules.initial_velocity_min = 2.5
	particules.initial_velocity_max = 5.0 if critique else 3.5
	particules.gravity = Vector3(0, -9.0, 0)
	particules.scale_amount_min = 0.5
	particules.scale_amount_max = 1.0
	particules.color = COULEUR_CRITIQUE if critique else COULEUR_COUP
	particules.mesh = _maillage(0.14, _matiere_etincelle_partagee())
	particules.emitting = true


## Nuage de poussière qui s'étale au sol (mort d'un monstre).
static func poussiere(parent: Node, position: Vector3, taille: float) -> void:
	var particules := _creer(parent, position + Vector3.UP * 0.2, 14, 0.9)
	particules.direction = Vector3.UP
	particules.spread = 90.0
	particules.initial_velocity_min = 0.6 * taille
	particules.initial_velocity_max = 1.4 * taille
	particules.gravity = Vector3(0, 0.4, 0)
	particules.damping_min = 1.5
	particules.damping_max = 2.5
	particules.scale_amount_min = 0.8 * taille
	particules.scale_amount_max = 1.6 * taille
	var fondu := Curve.new()
	fondu.add_point(Vector2(0, 0.6))
	fondu.add_point(Vector2(0.3, 1.0))
	fondu.add_point(Vector2(1, 0.0))
	particules.scale_amount_curve = fondu
	particules.color = COULEUR_POUSSIERE
	particules.mesh = _maillage(0.35, _matiere_poussiere_partagee())
	particules.emitting = true


static func _creer(parent: Node, position: Vector3, nombre: int, duree: float) -> CPUParticles3D:
	var particules := CPUParticles3D.new()
	particules.one_shot = true
	particules.explosiveness = 0.95
	particules.amount = nombre
	particules.lifetime = duree
	particules.local_coords = false
	particules.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(particules)
	particules.global_position = position
	particules.finished.connect(particules.queue_free)
	return particules


static func _maillage(taille: float, matiere: Material) -> QuadMesh:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * taille
	quad.material = matiere
	return quad


static func _matiere_etincelle_partagee() -> StandardMaterial3D:
	if _matiere_etincelle == null:
		_matiere_etincelle = StandardMaterial3D.new()
		_matiere_etincelle.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere_etincelle.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_matiere_etincelle.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_matiere_etincelle.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_matiere_etincelle.vertex_color_use_as_albedo = true
		_matiere_etincelle.albedo_texture = _tache_douce()
	return _matiere_etincelle


static func _matiere_poussiere_partagee() -> StandardMaterial3D:
	if _matiere_poussiere == null:
		_matiere_poussiere = StandardMaterial3D.new()
		_matiere_poussiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere_poussiere.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_matiere_poussiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_matiere_poussiere.vertex_color_use_as_albedo = true
		_matiere_poussiere.albedo_texture = _tache_douce()
	return _matiere_poussiere


## Tache ronde, pleine au centre et transparente sur le bord (fabriquée une seule fois).
static func _tache_douce() -> Texture2D:
	if _texture_tache == null:
		var taille := 32
		var image := Image.create(taille, taille, false, Image.FORMAT_RGBA8)
		for y in taille:
			for x in taille:
				var distance := Vector2(x + 0.5, y + 0.5).distance_to(Vector2.ONE * taille / 2.0) / (taille / 2.0)
				image.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - distance, 0.0, 1.0)))
		_texture_tache = ImageTexture.create_from_image(image)
	return _texture_tache
