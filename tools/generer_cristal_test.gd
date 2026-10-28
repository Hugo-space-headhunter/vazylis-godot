extends SceneTree
## Outil : fabrique le modèle provisoire « cristal_test.glb » (cristal sur un socle de pierre).
##
## À lancer une seule fois depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/generer_cristal_test.gd

const SORTIE := "res://assets/models/prop/cristal_test/cristal_test.glb"


func _init() -> void:
	var racine := Node3D.new()
	racine.name = "CristalTest"
	racine.add_child(_socle())
	racine.add_child(_cristal("Cristal", Vector3(0, 0.25, 0), 0.28, 0.55, 0.6, 0.0))
	racine.add_child(_cristal("Eclat1", Vector3(0.32, 0.2, 0.1), 0.08, 0.15, 0.2, 25.0))
	racine.add_child(_cristal("Eclat2", Vector3(-0.25, 0.2, 0.22), 0.07, 0.12, 0.17, -20.0))

	var document := GLTFDocument.new()
	var etat := GLTFState.new()
	var erreur := document.append_from_scene(racine, etat)
	if erreur == OK:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SORTIE.get_base_dir()))
		erreur = document.write_to_filesystem(etat, ProjectSettings.globalize_path(SORTIE))
	print("Cristal : ", "écrit dans " + SORTIE if erreur == OK else "erreur %d" % erreur)
	racine.free()
	quit(0 if erreur == OK else 1)


func _socle() -> MeshInstance3D:
	var cylindre := CylinderMesh.new()
	cylindre.top_radius = 0.38
	cylindre.bottom_radius = 0.48
	cylindre.height = 0.25
	cylindre.radial_segments = 8
	cylindre.rings = 1
	cylindre.material = _matiere(Color(0.42, 0.4, 0.46), false)
	var socle := MeshInstance3D.new()
	socle.name = "Socle"
	socle.mesh = cylindre
	socle.position.y = 0.125
	return socle


## Cristal à 6 faces : pointe basse, couronne, pointe haute.
func _cristal(nom: String, base: Vector3, rayon: float, bas: float, haut: float, inclinaison: float) -> MeshInstance3D:
	var couronne := []
	for i in 6:
		var angle := TAU * i / 6.0
		couronne.append(Vector3(cos(angle) * rayon, bas, sin(angle) * rayon))
	var pointe_basse := Vector3.ZERO
	var pointe_haute := Vector3(0, bas + haut, 0)

	var outil := SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	outil.set_smooth_group(-1)
	for i in 6:
		var a: Vector3 = couronne[i]
		var b: Vector3 = couronne[(i + 1) % 6]
		outil.add_vertex(pointe_haute)
		outil.add_vertex(b)
		outil.add_vertex(a)
		outil.add_vertex(pointe_basse)
		outil.add_vertex(a)
		outil.add_vertex(b)
	outil.generate_normals()
	outil.set_material(_matiere(Color(1.0, 0.86, 0.45), true))

	var cristal := MeshInstance3D.new()
	cristal.name = nom
	cristal.mesh = outil.commit()
	cristal.position = base
	cristal.rotation_degrees.z = inclinaison
	return cristal


func _matiere(couleur: Color, lumineuse: bool) -> StandardMaterial3D:
	var matiere := StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.roughness = 0.35 if lumineuse else 0.9
	if lumineuse:
		matiere.emission_enabled = true
		matiere.emission = couleur
		matiere.emission_energy_multiplier = 0.35
	return matiere
