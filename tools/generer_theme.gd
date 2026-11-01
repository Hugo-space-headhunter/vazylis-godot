extends SceneTree
## Outil : fabrique le thème de l'interface (res://assets/interface/theme_vazylis.tres), appliqué à tout
## le jeu par le réglage « gui/theme/custom » de project.godot.
## Style fantasy de Vazylis : fonds bleu nuit presque noirs, bordures dorées, textes ivoire.
## Les outils de développement ont leur propre variante (« BoutonDev », bordure rouge) pour ne pas
## être confondus avec l'interface du joueur.
##
## Lancer depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/generer_theme.gd

const SORTIE := "res://assets/interface/theme_vazylis.tres"

const FOND := Color(0.06, 0.08, 0.13, 0.82)
const FOND_SURVOL := Color(0.1, 0.13, 0.2, 0.9)
const FOND_APPUYE := Color(0.32, 0.25, 0.1, 0.92)
const OR := Color(0.85, 0.68, 0.32)
const IVOIRE := Color(0.97, 0.93, 0.83)
const ROUGE_DEV := Color(0.85, 0.32, 0.28)


func _init() -> void:
	var theme := Theme.new()
	theme.default_font_size = 22

	# Boutons : bordure dorée, le bouton enfoncé (mode actif, AFK allumé) se remplit d'or.
	theme.set_stylebox("normal", "Button", _boite(FOND, Color(OR, 0.75), 2))
	theme.set_stylebox("hover", "Button", _boite(FOND_SURVOL, Color(OR, 0.8), 2))
	theme.set_stylebox("pressed", "Button", _boite(FOND_APPUYE, OR, 3))
	theme.set_stylebox("hover_pressed", "Button", _boite(FOND_APPUYE, OR, 3))
	theme.set_stylebox("disabled", "Button", _boite(Color(FOND, 0.5), Color(OR, 0.2), 2))
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", IVOIRE)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", Color(1.0, 0.86, 0.5))
	theme.set_color("font_hover_pressed_color", "Button", Color(1.0, 0.86, 0.5))
	theme.set_color("font_disabled_color", "Button", Color(IVOIRE, 0.4))
	theme.set_color("font_outline_color", "Button", Color(0, 0, 0, 0.8))
	theme.set_constant("outline_size", "Button", 4)

	# Outils de développement : même forme, bordure rouge.
	theme.set_type_variation("BoutonDev", "Button")
	theme.set_stylebox("normal", "BoutonDev", _boite(Color(0.12, 0.05, 0.05, 0.8), Color(ROUGE_DEV, 0.7), 2))
	theme.set_stylebox("hover", "BoutonDev", _boite(Color(0.18, 0.07, 0.07, 0.9), ROUGE_DEV, 2))
	theme.set_stylebox("pressed", "BoutonDev", _boite(Color(0.3, 0.1, 0.08, 0.92), ROUGE_DEV, 3))
	theme.set_color("font_color", "BoutonDev", Color(1.0, 0.85, 0.82))

	# Panneaux et fenêtres.
	theme.set_stylebox("panel", "PanelContainer", _boite(Color(0.05, 0.07, 0.12, 0.9), Color(OR, 0.55), 2, 14, 14))
	theme.set_stylebox("panel", "Panel", _boite(Color(0.05, 0.07, 0.12, 0.9), Color(OR, 0.55), 2, 14, 14))
	theme.set_color("font_color", "Label", IVOIRE)

	# Listes déroulantes, cases à cocher et barres de défilement assorties.
	for type in ["OptionButton", "CheckBox"]:
		theme.set_color("font_color", type, IVOIRE)
	theme.set_stylebox("normal", "OptionButton", _boite(FOND, Color(OR, 0.55), 2))
	theme.set_stylebox("hover", "OptionButton", _boite(FOND_SURVOL, Color(OR, 0.8), 2))
	theme.set_stylebox("pressed", "OptionButton", _boite(FOND_APPUYE, OR, 2))
	theme.set_stylebox("grabber", "VScrollBar", _boite(Color(OR, 0.6), Color(OR, 0.0), 0, 6, 0))
	theme.set_stylebox("grabber_highlight", "VScrollBar", _boite(OR, Color(OR, 0.0), 0, 6, 0))
	theme.set_stylebox("scroll", "VScrollBar", _boite(Color(0, 0, 0, 0.35), Color(OR, 0.0), 0, 6, 0))

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SORTIE.get_base_dir()))
	var erreur := ResourceSaver.save(theme, SORTIE)
	print(SORTIE, " : ", "OK" if erreur == OK else "erreur %d" % erreur)
	quit(0 if erreur == OK else 1)


static func _boite(fond: Color, bord: Color, epaisseur: int, rayon: int = 12, marge: int = 10) -> StyleBoxFlat:
	var boite := StyleBoxFlat.new()
	boite.bg_color = fond
	boite.border_color = bord
	boite.set_border_width_all(epaisseur)
	boite.set_corner_radius_all(rayon)
	boite.set_content_margin_all(marge)
	boite.anti_aliasing = true
	return boite
