class_name Lucioles
extends CPUParticles3D
## Un essaim de lucioles : de petits points lumineux qui flottent lentement au-dessus du sol.
## À poser dans une zone ; la taille de l'essaim et le nombre de lucioles se règlent dans l'éditeur.
## Avec de gros points pâles (« taille », couleur peu opaque), cela fait une brume (la Lisière pourpre).

## Étendue de l'essaim (largeur, hauteur, profondeur), en mètres.
@export var etendue := Vector3(10, 2.5, 10)
@export var nombre := 14
@export var couleur := Color(0.85, 1.0, 0.45)
## Taille de chaque point lumineux, en mètres.
@export var taille := 0.12
## Au-delà de cette distance de la caméra, l'essaim n'est plus dessiné.
@export var distance_affichage := 40.0


func _ready() -> void:
	amount = nombre
	lifetime = 4.0
	preprocess = 4.0
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emission_box_extents = etendue / 2.0
	position.y = maxf(position.y, etendue.y / 2.0 + 0.3)
	direction = Vector3.UP
	spread = 180.0
	gravity = Vector3.ZERO
	initial_velocity_min = 0.05
	initial_velocity_max = 0.3
	scale_amount_min = 0.6
	scale_amount_max = 1.2
	var degrade := Gradient.new()
	degrade.set_color(0, Color(couleur, 0.0))
	degrade.add_point(0.3, Color(couleur, couleur.a))
	degrade.add_point(0.7, Color(couleur, couleur.a * 0.8))
	degrade.set_color(degrade.get_point_count() - 1, Color(couleur, 0.0))
	color_ramp = degrade
	var carre := QuadMesh.new()
	carre.size = Vector2(taille, taille)
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	matiere.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	matiere.vertex_color_use_as_albedo = true
	matiere.albedo_texture = ApparenceRarete._point_lumineux()
	carre.material = matiere
	mesh = carre
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visibility_range_end = distance_affichage
