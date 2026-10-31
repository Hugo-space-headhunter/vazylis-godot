extends SceneTree
## Outil : fabrique les modèles provisoires de la cape et des bijoux (formes simples, originales).
##
## À lancer depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/generer_objets_provisoires.gd
##
## Cape : haut de la cape à l'origine, elle tombe vers -Y, l'extérieur tourné vers -Z (le dos).
## Elle a un squelette (trois colonnes d'os) pour flotter avec les mouvements.
## Collier et boucle d'oreille : centrés à l'origine.

const TISSU := Color(0.42, 0.18, 0.12)
const DORURE := Color(0.85, 0.68, 0.3)
const OS_CLAIR := Color(0.9, 0.86, 0.75)
const GEMME := Color(0.45, 0.85, 0.6)
## Cape : colonnes d'os dans le tissu (position de gauche à droite, de -0.5 à 0.5) et morceaux par colonne.
const COLONNES_CAPE := {"Gauche": -0.36, "Centre": 0.0, "Droite": 0.36}
const SEGMENTS_CAPE := 4


func _init() -> void:
	var code := _ecrire(_cape(), "res://assets/models/armor/cape_voyage/cape_voyage.glb")
	code += _ecrire(_collier(), "res://assets/models/jewel/amulette_lucioles/amulette_lucioles.glb")
	code += _ecrire(_boucle(), "res://assets/models/jewel/boucle_os/boucle_os.glb")
	quit(code)


func _cape() -> Node3D:
	var racine := Node3D.new()
	racine.name = "Cape"
	# Squelette du tissu : trois colonnes d'os (gauche, centre, droite) de SEGMENTS morceaux chacune,
	# que le jeu fait bouger comme des ressorts (scripts/world/tissu.gd).
	var squelette := Skeleton3D.new()
	squelette.name = "Squelette"
	racine.add_child(squelette)
	squelette.add_bone("Racine")
	var colonnes_os := {}
	for colonne: String in COLONNES_CAPE:
		var parent := 0
		var precedent := Vector3.ZERO
		var os_colonne := []
		for k in SEGMENTS_CAPE + 1:
			var point := _point_cape(float(k) / SEGMENTS_CAPE, COLONNES_CAPE[colonne])
			var os := squelette.add_bone("%s_%d" % [colonne, k])
			squelette.set_bone_parent(os, parent)
			squelette.set_bone_rest(os, Transform3D(Basis.IDENTITY, point - precedent))
			parent = os
			precedent = point
			os_colonne.append(os)
		colonnes_os[colonne] = os_colonne
	squelette.reset_bone_poses()
	# Bandes de tissu de plus en plus larges vers le bas, légèrement bombées vers l'arrière.
	# Chaque sommet suit le segment d'os qui le porte, mélangé entre les deux colonnes voisines.
	var outil := SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	var lignes := 8
	var colonnes := 8
	var noms := COLONNES_CAPE.keys()
	for l in lignes + 1:
		var t := float(l) / lignes
		var segment := mini(int(t * SEGMENTS_CAPE), SEGMENTS_CAPE - 1)
		for c in colonnes + 1:
			var u := float(c) / colonnes - 0.5
			var os := PackedInt32Array([0, 0, 0, 0])
			var poids := PackedFloat32Array([0, 0, 0, 0])
			for n in noms.size() - 1:
				var u1: float = COLONNES_CAPE[noms[n]]
				var u2: float = COLONNES_CAPE[noms[n + 1]]
				if (u <= u2 or n == noms.size() - 2) and (u >= u1 or n == 0):
					var f := clampf((u - u1) / (u2 - u1), 0.0, 1.0)
					os = PackedInt32Array([colonnes_os[noms[n]][segment], colonnes_os[noms[n + 1]][segment], 0, 0])
					poids = PackedFloat32Array([1.0 - f, f, 0, 0])
					break
			outil.set_bones(os)
			outil.set_weights(poids)
			outil.add_vertex(_point_cape(t, u))
	for l in lignes:
		for c in colonnes:
			var a := l * (colonnes + 1) + c
			var d := a + colonnes + 1
			for indice in [a, a + 1, d, a + 1, d + 1, d]:
				outil.add_index(indice)
	outil.generate_normals()
	var maillage := outil.commit()
	var instance := MeshInstance3D.new()
	instance.name = "Tissu"
	instance.mesh = maillage
	var matiere := _matiere(TISSU)
	matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
	maillage.surface_set_material(0, matiere)
	squelette.add_child(instance)
	instance.skeleton = NodePath("..")
	instance.skin = squelette.create_skin_from_rest_transforms()
	var fermoir := SphereMesh.new()
	fermoir.radius = 0.035
	fermoir.height = 0.07
	racine.add_child(_piece("Fermoir", fermoir, DORURE, Vector3(0, -0.02, 0.0)))
	return racine


## Point du tissu de la cape : t de 0 (haut) à 1 (bas), u de -0.5 (gauche) à 0.5 (droite).
static func _point_cape(t: float, u: float) -> Vector3:
	var largeur := lerpf(0.36, 0.62, t)
	var bombe := -0.12 * cos(u * PI) - 0.08 * t
	return Vector3(u * largeur, -t * 1.05, bombe)


func _collier() -> Node3D:
	var racine := Node3D.new()
	racine.name = "Amulette"
	var chaine := TorusMesh.new()
	chaine.inner_radius = 0.1
	chaine.outer_radius = 0.115
	chaine.rings = 16
	chaine.ring_segments = 4
	var anneau := _piece("Chaine", chaine, DORURE, Vector3(0, 0.08, 0))
	anneau.rotation_degrees.x = 90
	racine.add_child(anneau)
	var pierre := PrismMesh.new()
	pierre.size = Vector3(0.06, 0.08, 0.03)
	racine.add_child(_piece("Pierre", pierre, GEMME, Vector3(0, -0.06, 0), true))
	return racine


func _boucle() -> Node3D:
	var racine := Node3D.new()
	racine.name = "Boucle"
	var anneau := TorusMesh.new()
	anneau.inner_radius = 0.025
	anneau.outer_radius = 0.035
	anneau.rings = 12
	anneau.ring_segments = 4
	var piece := _piece("Anneau", anneau, DORURE, Vector3(0, 0.03, 0))
	piece.rotation_degrees.x = 90
	racine.add_child(piece)
	var croc := PrismMesh.new()
	croc.size = Vector3(0.025, 0.07, 0.02)
	var dent := _piece("Croc", croc, OS_CLAIR, Vector3(0, -0.03, 0))
	dent.rotation_degrees.z = 180
	racine.add_child(dent)
	return racine


func _piece(nom: String, maillage: PrimitiveMesh, couleur: Color, position: Vector3, lumineux: bool = false) -> MeshInstance3D:
	var matiere := _matiere(couleur)
	if lumineux:
		matiere.emission_enabled = true
		matiere.emission = couleur
		matiere.emission_energy_multiplier = 0.4
	maillage.material = matiere
	var instance := MeshInstance3D.new()
	instance.name = nom
	instance.mesh = maillage
	instance.position = position
	return instance


func _matiere(couleur: Color) -> StandardMaterial3D:
	var matiere := StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.roughness = 0.6
	return matiere


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
