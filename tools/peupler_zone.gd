extends SceneTree
## Outil : remplit une zone avec ses monstres et son décor, d'après un plan (voir PeuplementZone).
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/peupler_zone.gd -- res://scenes/zones/ma_zone.tscn res://tools/plans_zones/ma_zone.cfg
##
## Arguments : <scène de la zone> <plan>. La scène est réécrite : faire un commit avant, pour pouvoir
## comparer et revenir en arrière.


## Le travail se fait à la première image : la configuration et le catalogue (chargés au démarrage
## du jeu) sont alors prêts, sinon les scripts des monstres et du décor ne se chargeraient pas.
func _process(_delta: float) -> bool:
	_peupler()
	return true


func _peupler() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() < 2:
		print("Usage : -- <scène de la zone .tscn> <plan .cfg>")
		quit(1)
		return
	var plan := ConfigFile.new()
	if plan.load(arguments[1]) != OK:
		push_error("Plan illisible : " + arguments[1])
		quit(1)
		return
	var zone: Node3D = (load(arguments[0]) as PackedScene).instantiate()
	var poses := PeuplementZone.peupler(zone, plan)
	var scene := PackedScene.new()
	var erreur := scene.pack(zone)
	if erreur == OK:
		erreur = ResourceSaver.save(scene, arguments[0])
	zone.free()
	print("%s : %d objets de décor posés (%s)" % [arguments[0], poses, "OK" if erreur == OK else "erreur %d" % erreur])
	quit(0 if erreur == OK else 1)
