extends SceneTree
## Outil : réduit les textures PNG d'un dossier pour le mobile (côté le plus long limité).
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/reduire_textures.gd -- res://assets/models/character/heros_homme 1024


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() < 2:
		print("Usage : -- <dossier res://> <taille max en pixels>")
		quit(1)
		return
	var dossier := arguments[0]
	var taille_max := int(arguments[1])
	for fichier in DirAccess.get_files_at(dossier):
		if fichier.get_extension().to_lower() != "png":
			continue
		var chemin := ProjectSettings.globalize_path(dossier.path_join(fichier))
		var image := Image.load_from_file(chemin)
		if image == null:
			print("Illisible : ", fichier)
			continue
		var avant := image.get_size()
		var plus_grand := maxi(avant.x, avant.y)
		if plus_grand > taille_max:
			var facteur := float(taille_max) / plus_grand
			image.resize(roundi(avant.x * facteur), roundi(avant.y * facteur), Image.INTERPOLATE_LANCZOS)
			image.save_png(chemin)
		print("%s : %s -> %s" % [fichier, avant, image.get_size()])
	quit(0)
