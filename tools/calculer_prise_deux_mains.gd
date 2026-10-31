extends SceneTree
## Outil : calcule la tenue d'une arme à deux mains (lignes à copier dans assets/catalogue.cfg).
##   - « poignee_mains » : où se posent la main droite et la main gauche sur l'arme
##     (dans le repère du modèle de l'arme), pour la cinématique inverse ;
##   - le placement « hanche » : l'arme accrochée au bassin, lame vers l'arrière et pointe au sol,
##     pour la marche « traînée à deux mains ».
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/calculer_prise_deux_mains.gd -- res://assets/models/weapon/claymore/claymore.glb lame 1.009
##
## Arguments : <modèle> <lame|manche> <échelle du catalogue> [axe imposé, ex. « 1,1,0 » si le manche est en diagonale]

const PERSONNAGE := "res://assets/models/character/heros_homme/heros_homme.gltf"
## Écart entre les deux mains sur la poignée, en mètres.
const ECART_MAINS := 0.17
## Où tombe la main droite quand l'arme traîne (repère du personnage, qui regarde vers +Z ; sa droite est -X) :
## le long de la cuisse droite, un peu en avant, pour que les bras restent devant le corps.
const MAIN_DROITE_TRAINE := Vector3(-0.3, 0.9, 0.1)
## Direction de la pointe au sol, vue de dessus : vers l'arrière et un peu sur la droite.
const DIRECTION_TRAINE := Vector2(-0.25, -1.0)


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	var outil = load("res://tools/calculer_prise.gd")
	var points: PackedVector3Array = outil._sommets(arguments[0])
	var axe := Vector3.ZERO
	if arguments.size() > 3:
		var morceaux := arguments[3].split(",")
		axe = Vector3(float(morceaux[0]), float(morceaux[1]), float(morceaux[2])).normalized()
	var forme: Dictionary = outil._analyser(points, arguments[1], axe)
	var echelle := float(arguments[2])
	var poignee: Vector3 = forme["poignee"]
	var pointe: Vector3 = forme["vers_pointe"]
	var portee := 0.0
	for p in points:
		portee = maxf(portee, (p - poignee).dot(pointe))
	var gauche := poignee - pointe * (ECART_MAINS / echelle)
	print("poignee_mains={\"droite\": %s, \"gauche\": %s}" % [_v(poignee), _v(gauche)])

	# La pointe touche le sol : on cherche la direction qui l'y amène depuis la main droite.
	var longueur := portee * echelle
	var hauteur := MAIN_DROITE_TRAINE.y
	var horizontal := sqrt(maxf(0.01, longueur * longueur - hauteur * hauteur))
	var sol := DIRECTION_TRAINE.normalized() * horizontal
	var vers_sol := Vector3(sol.x, -hauteur, sol.y).normalized()
	var cote := Vector3(1, 0, 0)

	var personnage: Node3D = (load(PERSONNAGE) as PackedScene).instantiate()
	var squelette: Skeleton3D = personnage.find_children("*", "Skeleton3D", true, false)[0]
	var bassin := squelette.get_bone_global_rest(squelette.find_bone("pelvis"))
	personnage.free()
	var vers_bassin := bassin.affine_inverse()
	var prise: Transform3D = outil._placer(forme, echelle, (vers_bassin.basis * vers_sol).normalized(),
		(vers_bassin.basis * cote).normalized(), vers_bassin * MAIN_DROITE_TRAINE)
	print("\"hanche\": {\"rotation_degres\": %s, \"decalage\": %s}" % [_v(prise.basis.get_euler() * 180.0 / PI), _v(prise.origin)])
	print("Longueur de la poignée à la pointe : %.2f m" % longueur)
	quit()


static func _v(v: Vector3) -> String:
	return "Vector3(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]
