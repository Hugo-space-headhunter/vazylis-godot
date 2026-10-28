extends SceneTree
## Outil : fabrique les icônes PNG de la web app à partir de icon.svg.
##
## À relancer après chaque modification de icon.svg :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/generer_icones.gd

const SOURCE := "res://icon.svg"
const DOSSIER := "res://assets/icones"
const TAILLES := [144, 180, 512]


func _init() -> void:
	var svg := FileAccess.get_file_as_string(SOURCE)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DOSSIER))
	var code := 0
	for taille: int in TAILLES:
		var image := Image.new()
		var erreur := image.load_svg_from_string(svg, taille / 512.0)
		if erreur == OK:
			erreur = image.save_png(ProjectSettings.globalize_path("%s/icone_%d.png" % [DOSSIER, taille]))
		print("Icône %d px : %s" % [taille, "OK" if erreur == OK else "erreur %d" % erreur])
		if erreur != OK:
			code = 1
	quit(code)
