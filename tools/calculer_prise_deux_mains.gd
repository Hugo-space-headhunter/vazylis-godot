extends SceneTree
## Outil : calcule « poignee_mains » d'une arme à deux mains (ligne à copier dans assets/catalogue.cfg) :
## où se posent la main droite et la main gauche sur l'arme (dans le repère du modèle de l'arme),
## pour la cinématique inverse. La position « traînée » au repos : tools/calculer_traine.gd.
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/calculer_prise_deux_mains.gd -- res://assets/models/weapon/claymore/claymore.glb lame 1.009
##
## Arguments : <modèle> <lame|manche> <échelle du catalogue> [axe imposé, ex. « 1,1,0 » si le manche est en diagonale]

## Écart entre les deux mains sur la poignée, en mètres.
const ECART_MAINS := 0.17


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
	var gauche := poignee - pointe * (ECART_MAINS / echelle)
	print("poignee_mains={\"droite\": %s, \"gauche\": %s}" % [_v(poignee), _v(gauche)])
	quit()


static func _v(v: Vector3) -> String:
	return "Vector3(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]
