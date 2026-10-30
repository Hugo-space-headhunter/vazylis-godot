class_name Herbe
extends Node3D
## Des centaines de touffes d'herbe semées sur une zone, dessinées par lots : chaque carreau de
## terrain est un seul objet pour la carte graphique (MultiMeshInstance3D), masqué quand il est loin.
## L'herbe prend la teinte de sa zone ; elle évite le chemin de terre et une zone ronde (Vazylis).
## À régler dans l'éditeur ; le semis est toujours le même (graine fixe).

## Modèle d'une touffe (identifiant du catalogue d'assets). Vide : une touffe simple fabriquée ici,
## 8 brins d'un triangle par face, bien moins chère à dessiner qu'un modèle détaillé.
@export var id_asset := ""
## Espace couvert (largeur X, profondeur Z), centré sur ce nœud.
@export var taille := Vector2(100, 80)
## Touffes par mètre carré.
@export var densite := 0.12
## Teinte de l'herbe (multiplie ses couleurs).
@export var teinte := Color(1, 1, 1)
## Côté d'un carreau, en mètres (un carreau = un lot dessiné d'un coup).
@export var taille_carreau := 16.0
## Au-delà de cette distance de la caméra, un carreau n'est plus dessiné.
@export var distance_affichage := 32.0
## Pas d'herbe sur le chemin : demi-largeur évitée autour de x = 0, entre ces deux z du monde.
@export var chemin_demi_largeur := 5.5
@export var chemin_z_debut := 0.0
@export var chemin_z_fin := 0.0
## Pas d'herbe dans ce cercle (position du monde, rayon 0 = aucun).
@export var exclusion_centre := Vector3.ZERO
@export var exclusion_rayon := 0.0
@export var graine := 1


func _ready() -> void:
	var maillage: Mesh
	var matiere: BaseMaterial3D
	var echelle := 1.0
	if id_asset.is_empty():
		maillage = _touffe_simple()
		matiere = StandardMaterial3D.new()
		matiere.roughness = 1.0
	else:
		var modele := CatalogueAssets.creer(id_asset)
		var source := modele.find_children("*", "MeshInstance3D", true, false)
		if source.is_empty():
			modele.free()
			return
		maillage = (source[0] as MeshInstance3D).mesh
		echelle = modele.scale.x
		matiere = (maillage.surface_get_material(0) as BaseMaterial3D).duplicate() as BaseMaterial3D
		modele.free()
	matiere.vertex_color_use_as_albedo = true
	# Les touffes qui passent tout près de la caméra (en bas de l'écran) s'effacent, au lieu de
	# devenir énormes.
	matiere.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
	matiere.distance_fade_min_distance = 2.5
	matiere.distance_fade_max_distance = 4.5

	var hasard := RandomNumberGenerator.new()
	hasard.seed = graine
	var carreaux := {}
	var origine := global_position
	var nombre := roundi(taille.x * taille.y * densite)
	for i in nombre:
		var x := origine.x + hasard.randf_range(-taille.x / 2.0, taille.x / 2.0)
		var z := origine.z + hasard.randf_range(-taille.y / 2.0, taille.y / 2.0)
		var tourne := hasard.randf() * TAU
		var grossit := hasard.randf_range(0.75, 1.35) * echelle
		var nuance := hasard.randf_range(0.85, 1.1)
		if not _place_libre(x, z):
			continue
		var cle := Vector2i(floori(x / taille_carreau), floori(z / taille_carreau))
		if not carreaux.has(cle):
			carreaux[cle] = []
		carreaux[cle].append([Vector3(x, 0, z), tourne, grossit, nuance])
	for cle: Vector2i in carreaux:
		_creer_carreau(cle, carreaux[cle], maillage, matiere)


## Une touffe de 8 brins (un triangle par face), sombre au pied et claire au bout.
static func _touffe_simple() -> ArrayMesh:
	var outil := SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hasard := RandomNumberGenerator.new()
	hasard.seed = 7
	for brin in 8:
		var angle := brin * TAU / 8.0 + hasard.randf_range(-0.4, 0.4)
		var pied := Vector3(cos(angle), 0, sin(angle)) * hasard.randf_range(0.02, 0.12)
		var cote := Vector3(-sin(angle), 0, cos(angle)) * 0.05
		var hauteur := hasard.randf_range(0.28, 0.48)
		var bout := pied * 2.2 + Vector3(0, hauteur, 0)
		# Deux faces (une par sens) : un brin vu de dos ne doit pas paraître noir.
		for sommets in [[pied - cote, pied + cote, bout], [pied + cote, pied - cote, bout]]:
			for i in 3:
				outil.set_normal(Vector3.UP)
				outil.set_color(Color(1.3, 1.3, 1.3) if i == 2 else Color(0.7, 0.7, 0.7))
				outil.add_vertex(sommets[i])
	return outil.commit()


func _place_libre(x: float, z: float) -> bool:
	if exclusion_rayon > 0.0 and Vector2(x - exclusion_centre.x, z - exclusion_centre.z).length() < exclusion_rayon:
		return false
	var sur_le_chemin := z <= chemin_z_debut and z >= chemin_z_fin and absf(x) < chemin_demi_largeur
	return not sur_le_chemin


func _creer_carreau(cle: Vector2i, touffes: Array, maillage: Mesh, matiere: Material) -> void:
	var centre := Vector3((cle.x + 0.5) * taille_carreau, 0, (cle.y + 0.5) * taille_carreau)
	var lot := MultiMesh.new()
	lot.transform_format = MultiMesh.TRANSFORM_3D
	lot.use_colors = true
	lot.mesh = maillage
	lot.instance_count = touffes.size()
	for i in touffes.size():
		var touffe: Array = touffes[i]
		var base := Basis(Vector3.UP, touffe[1]).scaled(Vector3.ONE * touffe[2])
		lot.set_instance_transform(i, Transform3D(base, touffe[0] - centre))
		lot.set_instance_color(i, Color(teinte.r * touffe[3], teinte.g * touffe[3], teinte.b * touffe[3], 1.0))
	var carreau := MultiMeshInstance3D.new()
	carreau.name = "Carreau_%d_%d" % [cle.x, cle.y]
	carreau.multimesh = lot
	carreau.material_override = matiere
	carreau.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	carreau.visibility_range_end = distance_affichage
	carreau.visibility_range_end_margin = 4.0
	add_child(carreau)
	carreau.global_position = centre
