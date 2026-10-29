extends SceneTree
## Outil : calcule comment tenir une arme (lignes à copier dans assets/catalogue.cfg).
##
## L'outil trouve l'axe le plus long de l'arme, devine où est la poignée, puis calcule
## la rotation, le décalage et l'échelle pour la main droite, la main gauche et le dos
## d'un personnage de base.
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/calculer_prise.gd -- res://assets/models/weapon/dague/dague.glb lame 0.45
##
## Arguments : <modèle> <type de prise> <longueur voulue en mètres> [axe]
##   lame   : épée, dague… La poignée est du côté de la garde (la partie la plus large).
##   manche : hache, marteau… La poignée est au bout opposé à la tête (la partie la plus large).
##   centre : arc, bâton… La poignée est au milieu.
##   axe (facultatif) : x, y, z ou une direction « 1,1,0 », pour imposer l'axe du manche quand l'outil se trompe
##   (par exemple une hache dont le fer est presque aussi large que le manche est long).

const PERSONNAGE_PAR_DEFAUT := "res://assets/models/character/heros_homme/heros_homme.gltf"
const TRANCHES := 20


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() < 3:
		print("Usage : -- <modèle> <lame|manche|centre> <longueur en m> [x|y|z]")
		quit(1)
		return
	var points := _sommets(arguments[0])
	var axe_impose := Vector3.ZERO
	if arguments.size() > 3:
		var axes := {"x": Vector3.RIGHT, "y": Vector3.UP, "z": Vector3.BACK}
		if axes.has(arguments[3]):
			axe_impose = axes[arguments[3]]
		else:
			var composantes := arguments[3].split_floats(",")
			axe_impose = Vector3(composantes[0], composantes[1], composantes[2]).normalized()
	var forme := _analyser(points, arguments[1], axe_impose)
	var echelle: float = float(arguments[2]) / float(forme["longueur"])
	var personnage: Node3D = load(PERSONNAGE_PAR_DEFAUT).instantiate()
	var squelette: Skeleton3D = personnage.find_children("*", "Skeleton3D", true, false)[0]

	print("echelle=%.3f" % echelle)
	for cote in ["r", "l"]:
		var prise := _prise_main(squelette, cote, forme, echelle)
		print("main_%s : rotation_degres=%s decalage=%s" % ["droite" if cote == "r" else "gauche", _v(prise.basis.get_euler() * 180.0 / PI), _v(prise.origin)])
	var dos := _prise_dos(squelette, forme, echelle)
	print("dos : rotation_degres=%s decalage=%s" % [_v(dos.basis.get_euler() * 180.0 / PI), _v(dos.origin)])
	personnage.free()
	quit(0)


static func _sommets(chemin: String) -> PackedVector3Array:
	var racine: Node3D = load(chemin).instantiate()
	var points := PackedVector3Array()
	for noeud in racine.find_children("*", "MeshInstance3D", true, false):
		var instance := noeud as MeshInstance3D
		var transformation := racine.global_transform.affine_inverse() * instance.global_transform if instance.is_inside_tree() else _transformation_relative(racine, instance)
		for surface in instance.mesh.get_surface_count():
			for sommet in instance.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
				points.append(transformation * sommet)
	racine.free()
	return points


static func _transformation_relative(racine: Node3D, noeud: Node3D) -> Transform3D:
	var transformation := Transform3D.IDENTITY
	var courant: Node = noeud
	while courant != null and courant != racine:
		if courant is Node3D:
			transformation = (courant as Node3D).transform * transformation
		courant = courant.get_parent()
	return transformation


## Axe principal, axe secondaire, poignée et longueur de l'arme.
static func _analyser(points: PackedVector3Array, type_prise: String, axe_impose: Vector3) -> Dictionary:
	var centre := Vector3.ZERO
	for p in points:
		centre += p
	centre /= points.size()
	var axe := axe_impose if axe_impose != Vector3.ZERO else _axe_principal(points, centre, Vector3.ZERO)
	var mini := INF
	var maxi := -INF
	for p in points:
		var t := (p - centre).dot(axe)
		mini = minf(mini, t)
		maxi = maxf(maxi, t)
	var longueur := maxi - mini
	var largeurs := []
	largeurs.resize(TRANCHES)
	largeurs.fill(0.0)
	for p in points:
		var d := p - centre
		var t := d.dot(axe)
		var i := clampi(int((t - mini) / longueur * TRANCHES), 0, TRANCHES - 1)
		largeurs[i] = maxf(largeurs[i], (d - axe * t).length())
	var plus_large := largeurs.find(largeurs.max())
	var t_poignee: float
	var vers_pointe: Vector3
	match type_prise:
		"manche":
			# La tête est le bout le plus large : on tient l'autre bout.
			var bas := 0.0
			var haut := 0.0
			for i in TRANCHES * 3 / 10:
				bas = maxf(bas, largeurs[i])
				haut = maxf(haut, largeurs[TRANCHES - 1 - i])
			var tete_en_haut := haut > bas
			t_poignee = mini + longueur * 0.15 if tete_en_haut else maxi - longueur * 0.15
			vers_pointe = axe if tete_en_haut else -axe
		"centre":
			t_poignee = (mini + maxi) / 2.0
			vers_pointe = axe
		_:
			# La garde est la partie la plus large, la poignée est entre la garde et le bout le plus proche.
			var garde_en_bas := plus_large < TRANCHES / 2
			var t_garde := mini + (plus_large + 0.5) / TRANCHES * longueur
			var bout := mini if garde_en_bas else maxi
			t_poignee = (t_garde + bout) / 2.0
			vers_pointe = axe if garde_en_bas else -axe
	var secondaire := _axe_principal(points, centre, axe)
	return {
		"poignee": centre + axe * t_poignee,
		"vers_pointe": vers_pointe,
		"secondaire": secondaire,
		"longueur": longueur,
	}


## Direction où les points s'étalent le plus (en ignorant la direction « sauf »).
static func _axe_principal(points: PackedVector3Array, centre: Vector3, sauf: Vector3) -> Vector3:
	var axe := Vector3(0.577, 0.577, 0.577)
	if sauf != Vector3.ZERO:
		axe = (axe - sauf * axe.dot(sauf)).normalized()
	for iteration in 40:
		var suivant := Vector3.ZERO
		for p in points:
			var d := p - centre
			if sauf != Vector3.ZERO:
				d -= sauf * d.dot(sauf)
			suivant += d * d.dot(axe)
		if suivant.length() < 0.000001:
			break
		axe = suivant.normalized()
	return axe


## Repère de l'arme : la pointe part de la poignée vers l'index, l'axe secondaire suit les doigts.
func _prise_main(squelette: Skeleton3D, cote: String, forme: Dictionary, echelle: float) -> Transform3D:
	var main := squelette.get_bone_global_rest(squelette.find_bone("hand_" + cote))
	var local := func(nom: String) -> Vector3:
		return main.affine_inverse() * squelette.get_bone_global_rest(squelette.find_bone(nom + "_" + cote)).origin
	var index: Vector3 = local.call("index_01")
	var auriculaire: Vector3 = local.call("pinky_01")
	var majeur: Vector3 = local.call("middle_01")
	var pointe := (index - auriculaire).normalized()
	var doigts := (majeur - pointe * majeur.dot(pointe)).normalized()
	return _placer(forme, echelle, pointe, doigts, majeur * 0.5)


## Rangée dans le dos : pointe vers le bas, en diagonale, à plat contre le dos.
func _prise_dos(squelette: Skeleton3D, forme: Dictionary, echelle: float) -> Transform3D:
	var dos := squelette.get_bone_global_rest(squelette.find_bone("spine_03"))
	var pointe := dos.basis.inverse() * Vector3(-0.35, -1, 0).normalized()
	var a_plat := dos.basis.inverse() * Vector3(1, -0.35, 0).normalized()
	var poignee := dos.affine_inverse() * (dos.origin + Vector3(0.12, 0.3, -0.2))
	return _placer(forme, echelle, pointe.normalized(), a_plat.normalized(), poignee)


static func _placer(forme: Dictionary, echelle: float, pointe: Vector3, secondaire: Vector3, point_poignee: Vector3) -> Transform3D:
	var u: Vector3 = forme["vers_pointe"]
	var g: Vector3 = (forme["secondaire"] - u * forme["secondaire"].dot(u)).normalized()
	var modele := Basis(u, g, u.cross(g))
	var cible := Basis(pointe, secondaire, pointe.cross(secondaire))
	var rotation := (cible * modele.inverse()).orthonormalized()
	var poignee_modele: Vector3 = forme["poignee"]
	var origine := point_poignee - rotation * (poignee_modele * echelle)
	return Transform3D(rotation, origine)


static func _v(v: Vector3) -> String:
	return "Vector3(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]
