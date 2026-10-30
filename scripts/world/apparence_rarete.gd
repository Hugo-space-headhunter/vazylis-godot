class_name ApparenceRarete
extends RefCounted
## Rendu d'un objet selon sa rareté (docs/game-design.md, « Lecture de la rareté ») :
## une teinte vers la couleur de la rareté, un aspect plus métallique, un éclat lumineux,
## et des étincelles pour les plus rares. Les réglages sont dans config/raretes.cfg.


## Applique le rendu de la rareté à tous les maillages sous « noeud », et une teinte (celle de
## la panoplie de l'objet). Les matières sont copiées : le modèle d'origine n'est pas modifié.
static func appliquer(noeud: Node, rarete: String, teinte: Color = Color.WHITE) -> void:
	var config := Config.jeu
	var reglages := config.apparence_rarete(rarete)
	var melange := float(reglages.get("melange_couleur", 0.0))
	var metallique := float(reglages.get("metallique", 0.0))
	var eclat := float(reglages.get("eclat", 0.0))
	if melange <= 0.0 and metallique <= 0.0 and eclat <= 0.0 and teinte == Color.WHITE:
		return
	var couleur := config.couleur_rarete(rarete)
	var instances: Array = noeud.find_children("*", "MeshInstance3D", true, false)
	if noeud is MeshInstance3D:
		instances.append(noeud)
	for element in instances:
		var instance := element as MeshInstance3D
		for surface in instance.get_surface_override_material_count():
			var origine := instance.get_active_material(surface) as BaseMaterial3D
			if origine == null:
				continue
			var matiere := origine.duplicate() as BaseMaterial3D
			matiere.albedo_color = (matiere.albedo_color * teinte).lerp(couleur, melange)
			matiere.metallic = maxf(matiere.metallic, metallique)
			matiere.roughness = minf(matiere.roughness, 1.0 - metallique * 0.6)
			if eclat > 0.0:
				matiere.emission_enabled = true
				matiere.emission = couleur
				matiere.emission_energy_multiplier = eclat
			instance.set_surface_override_material(surface, matiere)


## Nombre d'étincelles autour d'un objet de cette rareté (0 = aucune).
static func etincelles(rarete: String) -> int:
	return int(Config.jeu.apparence_rarete(rarete).get("etincelles", 0))


## Ajoute des étincelles de la couleur de la rareté autour d'un objet (ou d'un personnage).
## « boite » : zone d'où partent les étincelles, dans le repère du parent.
static func ajouter_etincelles(parent: Node3D, rarete: String, boite: AABB, nombre: int = -1) -> CPUParticles3D:
	if nombre < 0:
		nombre = etincelles(rarete)
	if nombre <= 0:
		return null
	var couleur := Config.jeu.couleur_rarete(rarete)
	var particules := CPUParticles3D.new()
	particules.name = "Etincelles"
	particules.amount = nombre
	particules.lifetime = 1.2
	particules.local_coords = false
	particules.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particules.emission_box_extents = boite.size / 2.0
	particules.position = boite.get_center()
	particules.direction = Vector3.UP
	particules.spread = 25.0
	particules.gravity = Vector3(0, 0.6, 0)
	particules.initial_velocity_min = 0.05
	particules.initial_velocity_max = 0.25
	particules.scale_amount_min = 0.5
	particules.scale_amount_max = 1.0
	var degrade := Gradient.new()
	degrade.set_color(0, Color(couleur, 0.0))
	degrade.add_point(0.2, Color(couleur, 0.9))
	degrade.set_color(degrade.get_point_count() - 1, Color(couleur, 0.0))
	particules.color_ramp = degrade
	var carre := QuadMesh.new()
	carre.size = Vector2(0.07, 0.07)
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	matiere.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	matiere.vertex_color_use_as_albedo = true
	matiere.albedo_texture = _point_lumineux()
	carre.material = matiere
	particules.mesh = carre
	particules.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(particules)
	return particules


static var _texture_point: Texture2D


## Petit point lumineux rond, au bord adouci, pour les étincelles.
static func _point_lumineux() -> Texture2D:
	if _texture_point == null:
		var degrade := Gradient.new()
		degrade.set_color(0, Color(1, 1, 1, 1))
		degrade.set_color(1, Color(1, 1, 1, 0))
		var texture := GradientTexture2D.new()
		texture.gradient = degrade
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(0.5, 0.0)
		texture.width = 32
		texture.height = 32
		_texture_point = texture
	return _texture_point
