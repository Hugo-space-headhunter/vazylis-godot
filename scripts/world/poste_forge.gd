class_name PosteForge
extends Node3D
## La forge de Vazylis : une enclume, un foyer et le forgeron. Quand le joueur s'approche,
## le bouton « Forge » apparaît (voir monde.gd). Elle jaillit d'étincelles dorées quand
## une amélioration réussit, et fume quand elle échoue.

const GROUPE := "forge"
const COULEUR_REUSSITE := Color(1.0, 0.82, 0.3)
const COULEUR_ECHEC := Color(0.55, 0.55, 0.58)

## Distance (en mètres) à laquelle le joueur peut utiliser la forge.
@export var rayon := 3.5

@onready var _dessus_enclume: Marker3D = $Enclume/Dessus


func _ready() -> void:
	add_to_group(GROUPE)
	var forgeron := CatalogueAssets.creer(IdentifiantsAssets.FORGERON)
	$Forgeron.add_child(forgeron)
	forgeron.jouer("idle", 0.0)
	var outil := CatalogueAssets.creer(IdentifiantsAssets.HACHE)
	add_child(outil)
	outil.accrocher_a(forgeron, "main_droite")


func joueur_proche(point: Vector3) -> bool:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length() <= rayon


## Une gerbe d'étincelles dorées (réussite) ou un nuage de fumée grise (échec) sur l'enclume.
func jouer_effet(reussite: bool) -> void:
	var particules := CPUParticles3D.new()
	particules.one_shot = true
	particules.explosiveness = 0.9
	particules.amount = 40 if reussite else 24
	particules.lifetime = 0.9 if reussite else 1.6
	particules.direction = Vector3.UP
	particules.spread = 70.0 if reussite else 30.0
	particules.gravity = Vector3(0, -6, 0) if reussite else Vector3(0, 0.8, 0)
	particules.initial_velocity_min = 2.5 if reussite else 0.3
	particules.initial_velocity_max = 5.0 if reussite else 0.8
	particules.scale_amount_min = 0.6 if reussite else 2.5
	particules.scale_amount_max = 1.2 if reussite else 4.0
	var couleur := COULEUR_REUSSITE if reussite else COULEUR_ECHEC
	var degrade := Gradient.new()
	degrade.set_color(0, Color(couleur, 1.0 if reussite else 0.7))
	degrade.set_color(1, Color(couleur, 0.0))
	particules.color_ramp = degrade
	var carre := QuadMesh.new()
	carre.size = Vector2(0.08, 0.08)
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if reussite else BaseMaterial3D.BLEND_MODE_MIX
	matiere.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	matiere.vertex_color_use_as_albedo = true
	matiere.albedo_texture = ApparenceRarete._point_lumineux()
	carre.material = matiere
	particules.mesh = carre
	particules.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_dessus_enclume.add_child(particules)
	particules.emitting = true
	particules.finished.connect(particules.queue_free)
