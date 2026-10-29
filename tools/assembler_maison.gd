extends SceneTree
## Atelier : assemble une maison (ou un décor) avec les pièces du Medieval Village Pack
## (Quaternius, CC0), puis la fusionne en un seul modèle léger pour le mobile.
##
## Il ne tourne pas dans le jeu : on le lance dans un petit projet Godot à part, qui contient
## les pièces du pack dans un dossier « pieces/ » (textures réduites avec tools/reduire_textures.gd).
## Le résultat va dans assets/models/prop/maisons_village/.
##   -- photo <maison>   : photos sous 4 angles (avec --write-movie)
##   -- export <maison> <fichier.glb> : fusionne par matériau et exporte un seul GLB

const W := 2.0

var _racine: Node3D
var _camera: Camera3D
var _image := 0
var _maison := ""


static func t(x: float, y: float, z: float, angle_deg: float = 0.0) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, deg_to_rad(angle_deg)), Vector3(x, y, z))


## Murs d'une maison rectangulaire de largeur (x) × profondeur (z) en cases de 2 m.
## « facade » : liste des pièces de la façade avant (+z), de gauche à droite.
static func murs(largeur: int, profondeur: int, facade: Array, cotes: String, arriere: String, matiere: String) -> Array:
	var pieces := []
	var lx := largeur * W / 2.0
	var lz := profondeur * W / 2.0
	for i in largeur:
		var x := -lx + W / 2.0 + i * W
		pieces.append([facade[i] if i < facade.size() else "Wall_%s_Straight" % matiere, t(x, 0, lz, 0)])
		pieces.append([arriere if i == largeur / 2 else "Wall_%s_Straight" % matiere, t(-x, 0, -lz, 180)])
	for j in profondeur:
		var z := -lz + W / 2.0 + j * W
		pieces.append([cotes if j == profondeur / 2 else "Wall_%s_Straight" % matiere, t(lx, 0, -z, 90)])
		pieces.append(["Wall_%s_Straight" % matiere, t(-lx, 0, z, -90)])
	for c in [Vector2(lx, lz), Vector2(-lx, lz), Vector2(lx, -lz), Vector2(-lx, -lz)]:
		pieces.append(["Corner_Exterior_Wood", t(c.x, 0, c.y)])
	return pieces


static func plan(nom: String) -> Array:
	match nom:
		"maison_a":
			var p := murs(2, 2, ["Wall_Plaster_Window_Wide_Round", "Wall_Plaster_Door_Round"], "Wall_Plaster_Window_Wide_Round", "Wall_Plaster_Straight", "Plaster")
			p.append(["Door_1_Round", t(0.45, 0, 2.0)])
			p.append(["Roof_Front_Brick4", t(0, 3.12, 2.0)])
			p.append(["Roof_Front_Brick4", t(0, 3.12, -2.0, 180)])
			p.append(["Roof_RoundTiles_4x4", t(0, 3.12, 0)])
			p.append(["Prop_Chimney", t(-1.2, 3.12, -0.8)])
			return p
		"maison_b":
			var p := murs(3, 2, ["Wall_UnevenBrick_Window_Wide_Round", "Wall_UnevenBrick_Door_Round", "Wall_UnevenBrick_Window_Wide_Round"], "Wall_UnevenBrick_Window_Wide_Round", "Wall_UnevenBrick_Straight", "UnevenBrick")
			p.append(["Door_1_Round", t(-0.55, 0, 2.0)])
			p.append(["Roof_Front_Brick4", t(3.0, 3.12, 0, 90)])
			p.append(["Roof_Front_Brick4", t(-3.0, 3.12, 0, -90)])
			p.append(["Roof_RoundTiles_4x6", t(0, 3.12, 0, 90)])
			return p
		"chariot":
			return [["Prop_Wagon", t(0, 0, 0)]]
		"barriere":
			return [["Prop_WoodenFence_Single", t(0, 0, 0)]]
	return []


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_maison = args[1]
	_racine = Node3D.new()
	for piece in plan(_maison):
		var scene: PackedScene = load("res://pieces/%s.gltf" % piece[0])
		var noeud: Node3D = scene.instantiate()
		noeud.transform = piece[1]
		_racine.add_child(noeud)
	if args[0] == "export":
		_exporter(args[2])
		quit(0)
		return
	root.add_child(_racine)
	var soleil := DirectionalLight3D.new()
	soleil.rotation_degrees = Vector3(-50, 30, 0)
	root.add_child(soleil)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.5, 0.7, 0.9)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.8, 0.8, 0.85)
	root.add_child(env)
	_camera = Camera3D.new()
	root.add_child(_camera)
	_placer_camera()


func _placer_camera() -> void:
	var a := deg_to_rad(30 + 90 * _image)
	_camera.position = Vector3(sin(a) * 13, 7, cos(a) * 13)
	_camera.look_at(Vector3(0, 2.5, 0))


func _process(_delta: float) -> bool:
	if _camera == null:
		return true
	_image += 1
	if _image >= 4:
		return true
	_placer_camera()
	return false


func _exporter(chemin: String) -> void:
	var par_matiere := {}
	for instance in _racine.find_children("*", "MeshInstance3D", true, false):
		var mi := instance as MeshInstance3D
		var transformation := Transform3D.IDENTITY
		var courant: Node = mi
		while courant != null and courant != _racine:
			transformation = (courant as Node3D).transform * transformation
			courant = courant.get_parent()
		for s in mi.mesh.get_surface_count():
			var matiere := mi.get_active_material(s)
			# Les pièces importées séparément ont chacune leur copie d'un même matériau : on les regroupe par texture.
			var cle := _cle(matiere)
			if not par_matiere.has(cle):
				var outil := SurfaceTool.new()
				outil.begin(Mesh.PRIMITIVE_TRIANGLES)
				outil.set_material(matiere)
				par_matiere[cle] = outil
			(par_matiere[cle] as SurfaceTool).append_from(mi.mesh, s, transformation)
	var maillage := ArrayMesh.new()
	for cle in par_matiere:
		(par_matiere[cle] as SurfaceTool).commit(maillage)
	var sortie := Node3D.new()
	sortie.name = _maison
	var mi := MeshInstance3D.new()
	mi.name = _maison
	mi.mesh = maillage
	sortie.add_child(mi)
	mi.owner = sortie
	var doc := GLTFDocument.new()
	var etat := GLTFState.new()
	doc.append_from_scene(sortie, etat)
	var erreur := doc.write_to_filesystem(etat, chemin)
	print("Export %s : %d matériaux, erreur %d" % [chemin, par_matiere.size(), erreur])
	var boite := maillage.get_aabb()
	print("Boîte : ", boite)


func _cle(matiere: Material) -> String:
	var standard := matiere as BaseMaterial3D
	if standard == null or standard.albedo_texture == null:
		return str(matiere)
	return standard.albedo_texture.resource_path + "|" + str(standard.albedo_color)
