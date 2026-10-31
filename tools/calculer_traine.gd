extends SceneTree
## Outil : calcule la position « repos » d'une arme à deux mains (ligne à copier dans assets/catalogue.cfg,
## placement « main_droite:repos »). L'arme reste dans la main droite, le bras suit l'animation,
## et l'arme traîne derrière, la pointe (ou le fer) au sol.
##
## L'outil lance le vrai personnage en mode combat, lit la pose de la main droite à l'arrêt,
## puis oriente l'arme pour que sa pointe touche le sol derrière, un peu sur la droite.
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/calculer_traine.gd -- objet.lame_guet res://assets/models/weapon/claymore/claymore.glb lame 1.009
##
## Arguments : <famille d'objet> <modèle> <lame|manche> <échelle du catalogue> [axe imposé, ex. « 1,1,0 »]

## Direction de la pointe au sol, vue de dessus (repère du personnage, qui regarde vers +Z ; sa droite est -X) :
## vers l'arrière et un peu sur la droite.
const DIRECTION_TRAINE := Vector2(-0.35, -1.0)

var _image := 0
var _joueur: Node3D


func _process(_delta: float) -> bool:
	_image += 1
	var arguments := OS.get_cmdline_user_args()
	if _image == 2:
		var sol := StaticBody3D.new()
		var forme := CollisionShape3D.new()
		forme.shape = BoxShape3D.new()
		(forme.shape as BoxShape3D).size = Vector3(20, 1, 20)
		forme.position.y = -0.5
		sol.add_child(forme)
		root.add_child(sol)
		_joueur = load("res://scenes/personnages/joueur.tscn").instantiate()
		root.add_child(_joueur)
	if _image == 5:
		_joueur.equiper_objet(_joueur.butin.creer_objet(arguments[0], 1, "standard", RandomNumberGenerator.new()))
		_joueur.changer_mode(1)
	if _image == 40:
		_calculer(arguments)
		return true
	return false


func _calculer(arguments: PackedStringArray) -> void:
	var outil = load("res://tools/calculer_prise.gd")
	var points: PackedVector3Array = outil._sommets(arguments[1])
	var axe := Vector3.ZERO
	if arguments.size() > 4:
		var morceaux := arguments[4].split(",")
		axe = Vector3(float(morceaux[0]), float(morceaux[1]), float(morceaux[2])).normalized()
	var forme: Dictionary = outil._analyser(points, arguments[2], axe)
	var echelle := float(arguments[3])
	var poignee: Vector3 = forme["poignee"]
	var portee := 0.0
	for p in points:
		portee = maxf(portee, (p - poignee).dot(forme["vers_pointe"]))

	var squelette: Skeleton3D = _joueur.find_children("*", "Skeleton3D", true, false)[0]
	var main := squelette.get_bone_global_pose(squelette.find_bone("hand_r"))
	var majeur := squelette.get_bone_global_pose(squelette.find_bone("middle_01_r")).origin
	var point_poignee := main.affine_inverse() * (main.origin + (majeur - main.origin) * 0.5)
	var vers_squelette := squelette.global_basis.orthonormalized().inverse() * _joueur.global_basis.orthonormalized()
	var hauteur := (squelette.global_transform * (main * point_poignee)).y - _joueur.global_position.y
	var longueur := portee * echelle
	var horizontal := sqrt(maxf(0.01, longueur * longueur - hauteur * hauteur))
	var sol := DIRECTION_TRAINE.normalized() * horizontal
	var pointe := (main.basis.orthonormalized().inverse() * vers_squelette * Vector3(sol.x, -hauteur, sol.y)).normalized()
	var cote := (main.basis.orthonormalized().inverse() * vers_squelette * Vector3.RIGHT)
	cote = (cote - pointe * cote.dot(pointe)).normalized()
	var prise: Transform3D = outil._placer(forme, echelle, pointe, cote, point_poignee)
	print("\"main_droite:repos\": {\"rotation_degres\": %s, \"decalage\": %s}" % [_v(prise.basis.get_euler() * 180.0 / PI), _v(prise.origin)])
	print("Main à %.2f m du sol, arme de %.2f m" % [hauteur, longueur])


static func _v(v: Vector3) -> String:
	return "Vector3(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]
