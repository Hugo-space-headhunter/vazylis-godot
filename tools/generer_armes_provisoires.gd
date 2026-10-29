extends SceneTree
## Outil : fabrique les modèles provisoires du bouclier rond et de l'arc (formes simples, originales).
##
## À lancer depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/generer_armes_provisoires.gd
##
## Bouclier : disque dans le plan X-Y, face avant vers +Z, centre à l'origine.
## Arc : bois le long de l'axe Y, poignée à l'origine, corde du côté +Z.
## Flèche : le long de l'axe Z, pointe vers +Z, centre à l'origine.

const BOIS := Color(0.45, 0.3, 0.18)
const METAL := Color(0.62, 0.6, 0.58)
const CORDE := Color(0.9, 0.88, 0.8)


func _init() -> void:
	var code := _ecrire(_bouclier(), "res://assets/models/weapon/bouclier/bouclier.glb")
	code += _ecrire(_arc(), "res://assets/models/weapon/arc/arc.glb")
	code += _ecrire(_fleche(), "res://assets/models/projectile/fleche/fleche.glb")
	quit(code)


func _bouclier() -> Node3D:
	var racine := Node3D.new()
	racine.name = "Bouclier"
	var disque := CylinderMesh.new()
	disque.top_radius = 0.32
	disque.bottom_radius = 0.32
	disque.height = 0.04
	disque.radial_segments = 10
	disque.rings = 1
	racine.add_child(_piece("Planches", disque, BOIS, Vector3.ZERO, Vector3(90, 0, 0)))
	var bord := TorusMesh.new()
	bord.inner_radius = 0.3
	bord.outer_radius = 0.34
	bord.rings = 10
	bord.ring_segments = 4
	racine.add_child(_piece("Bord", bord, METAL, Vector3.ZERO, Vector3(90, 0, 0)))
	var umbo := CylinderMesh.new()
	umbo.top_radius = 0.05
	umbo.bottom_radius = 0.08
	umbo.height = 0.05
	umbo.radial_segments = 8
	umbo.rings = 1
	racine.add_child(_piece("Umbo", umbo, METAL, Vector3(0, 0, 0.04), Vector3(90, 0, 0)))
	return racine


func _arc() -> Node3D:
	var racine := Node3D.new()
	racine.name = "Arc"
	# Le bois suit un arc de cercle dans le plan Y-Z, bombé vers -Z ; la corde relie les deux bouts (côté +Z).
	var rayon := 0.8
	var demi_angle := deg_to_rad(42.0)
	var segments := 8
	var bouts := []
	for i in segments:
		var a0 := -demi_angle + 2.0 * demi_angle * i / segments
		var a1 := -demi_angle + 2.0 * demi_angle * (i + 1) / segments
		var p0 := Vector3(0, sin(a0) * rayon, (cos(a0) - 1.0) * -rayon)
		var p1 := Vector3(0, sin(a1) * rayon, (cos(a1) - 1.0) * -rayon)
		var milieu := (p0 + p1) / 2.0
		var epaisseur := 0.045 if absi(i - segments / 2) <= 1 else 0.03
		var piece := _piece("Bois%d" % i, _boite(Vector3(epaisseur, p0.distance_to(p1) + 0.01, epaisseur)),
			BOIS.darkened(0.3) if absi(i - segments / 2) <= 0 else BOIS, milieu, Vector3.ZERO)
		piece.rotation.x = atan2(p1.z - p0.z, p1.y - p0.y)
		racine.add_child(piece)
		if i == 0:
			bouts.append(p0)
		if i == segments - 1:
			bouts.append(p1)
	var corde := _piece("Corde", _boite(Vector3(0.006, bouts[0].distance_to(bouts[1]), 0.006)), CORDE,
		(bouts[0] + bouts[1]) / 2.0, Vector3.ZERO)
	racine.add_child(corde)
	return racine


func _fleche() -> Node3D:
	var racine := Node3D.new()
	racine.name = "Fleche"
	racine.add_child(_piece("Hampe", _boite(Vector3(0.012, 0.012, 0.6)), BOIS, Vector3.ZERO, Vector3.ZERO))
	var pointe := PrismMesh.new()
	pointe.size = Vector3(0.04, 0.07, 0.012)
	racine.add_child(_piece("Pointe", pointe, METAL, Vector3(0, 0, 0.33), Vector3(90, 0, 0)))
	racine.add_child(_piece("Empennage", _boite(Vector3(0.05, 0.004, 0.1)), CORDE, Vector3(0, 0, -0.26), Vector3.ZERO))
	return racine


func _boite(taille: Vector3) -> BoxMesh:
	var boite := BoxMesh.new()
	boite.size = taille
	return boite


func _piece(nom: String, maillage: PrimitiveMesh, couleur: Color, position: Vector3, rotation_degres: Vector3) -> MeshInstance3D:
	var matiere := StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.roughness = 0.8
	maillage.material = matiere
	var piece := MeshInstance3D.new()
	piece.name = nom
	piece.mesh = maillage
	piece.position = position
	piece.rotation_degrees = rotation_degres
	return piece


func _ecrire(racine: Node3D, sortie: String) -> int:
	var document := GLTFDocument.new()
	var etat := GLTFState.new()
	var erreur := document.append_from_scene(racine, etat)
	if erreur == OK:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(sortie.get_base_dir()))
		erreur = document.write_to_filesystem(etat, ProjectSettings.globalize_path(sortie))
	print(sortie, " : ", "OK" if erreur == OK else "erreur %d" % erreur)
	racine.free()
	return 0 if erreur == OK else 1
