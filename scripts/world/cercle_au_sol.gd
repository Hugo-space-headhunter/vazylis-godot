class_name CercleAuSol
extends RefCounted
## Anneau lumineux posé au sol sous un monstre : l'aura des champions et des sous-boss,
## ou le cercle rouge qui annonce une attaque de zone.

static var _texture_anneau: Texture2D


## Crée l'anneau (enfant de « parent ») ; sa matière permet d'en changer la couleur ensuite.
static func creer(parent: Node3D, nom: String, rayon: float, couleur: Color, hauteur: float = 0.03) -> MeshInstance3D:
	var disque := PlaneMesh.new()
	disque.size = Vector2(rayon * 2.0, rayon * 2.0)
	var matiere := StandardMaterial3D.new()
	matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	matiere.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	matiere.albedo_color = couleur
	matiere.albedo_texture = _anneau()
	disque.material = matiere
	var cercle := MeshInstance3D.new()
	cercle.name = nom
	cercle.mesh = disque
	cercle.position.y = hauteur
	cercle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(cercle)
	return cercle


static func matiere(cercle: MeshInstance3D) -> StandardMaterial3D:
	return (cercle.mesh as PlaneMesh).material as StandardMaterial3D


## Aura des champions (dorée) et des sous-boss (violette) : un anneau qui pulse et des étincelles.
static func aura(monstre: Node3D, boite: AABB, couleur: Color) -> StandardMaterial3D:
	var rayon := maxf(boite.size.x, boite.size.z) * 0.6 + 0.2
	var cercle := creer(monstre, "Aura", rayon, Color(couleur, 0.7))
	var pulsation := cercle.create_tween().set_loops()
	pulsation.tween_property(cercle, "scale", Vector3.ONE * 1.12, 0.8).set_trans(Tween.TRANS_SINE)
	pulsation.tween_property(cercle, "scale", Vector3.ONE, 0.8).set_trans(Tween.TRANS_SINE)
	var particules := ApparenceRarete.ajouter_etincelles(monstre, "dore", boite, 14)
	if particules != null:
		var degrade := particules.color_ramp
		for i in degrade.get_point_count():
			degrade.set_color(i, Color(couleur, degrade.get_color(i).a))
	return matiere(cercle)


## Anneau lumineux (transparent au centre et sur le bord).
static func _anneau() -> Texture2D:
	if _texture_anneau == null:
		var degrade := Gradient.new()
		degrade.set_color(0, Color(1, 1, 1, 0))
		degrade.add_point(0.55, Color(1, 1, 1, 0.15))
		degrade.add_point(0.82, Color(1, 1, 1, 1))
		degrade.set_color(degrade.get_point_count() - 1, Color(1, 1, 1, 0))
		var texture := GradientTexture2D.new()
		texture.gradient = degrade
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 128
		texture.height = 128
		_texture_anneau = texture
	return _texture_anneau
