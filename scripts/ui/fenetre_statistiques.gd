extends PanelContainer
## Fenêtre des statistiques : boutons + et − pour répartir les points, aperçu des effets,
## puis « Valider » (définitif). Le jeu continue de tourner pendant qu'elle est ouverte.

const COULEURS := {
	"force": Color(0.88, 0.33, 0.24),
	"agilite": Color(0.37, 0.75, 0.29),
	"vitalite": Color(0.94, 0.76, 0.25),
	"intelligence": Color(0.31, 0.56, 0.91),
}
const EFFETS := {
	"force": "+2 dégâts par coup",
	"agilite": "+0,4 % vitesse, +0,1 % critique",
	"vitalite": "+12 vie, +0,5 défense",
	"intelligence": "+5 mana (magie plus tard)",
}
const TAILLE_TEXTE := 22

var _joueur: Joueur
var _points: Label
var _valeurs := {}
var _apercu: Label
var _objets: Label
var _valider: Button


func _ready() -> void:
	add_to_group(CommandesTactiles.GROUPE_UI)
	visible = false
	set_anchors_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(600, 0)
	var fond := StyleBoxFlat.new()
	fond.bg_color = Color(0.06, 0.08, 0.13, 0.94)
	fond.set_corner_radius_all(16)
	fond.set_content_margin_all(20)
	fond.border_color = Color(1, 0.85, 0.4, 0.6)
	fond.set_border_width_all(2)
	add_theme_stylebox_override("panel", fond)

	var contenu := VBoxContainer.new()
	contenu.add_theme_constant_override("separation", 10)
	add_child(contenu)
	contenu.add_child(_texte("Statistiques", 30, Color(1, 0.85, 0.4)))
	_points = _texte("", TAILLE_TEXTE, Color.WHITE)
	contenu.add_child(_points)
	for nom in Statistiques.NOMS:
		contenu.add_child(_ligne(nom))
	_apercu = _texte("", 18, Color(0.85, 0.88, 0.95))
	contenu.add_child(_apercu)
	_objets = _texte("", 14, Color(0.7, 0.72, 0.8))
	contenu.add_child(_objets)
	var boutons := HBoxContainer.new()
	boutons.alignment = BoxContainer.ALIGNMENT_CENTER
	boutons.add_theme_constant_override("separation", 16)
	_valider = _bouton("Valider", _sur_valider)
	boutons.add_child(_valider)
	boutons.add_child(_bouton("Fermer", fermer))
	contenu.add_child(boutons)
	contenu.add_child(_texte("Une fois validés, les points sont définitifs.", 15, Color(0.7, 0.72, 0.8)))


func relier(joueur: Joueur) -> void:
	_joueur = joueur
	_joueur.statistiques.change.connect(_rafraichir)
	_joueur.caracteristiques_change.connect(_rafraichir)
	_joueur.equipement_change.connect(_rafraichir)


func ouvrir() -> void:
	visible = true
	_rafraichir()
	position = (get_viewport_rect().size - size) / 2.0


func fermer() -> void:
	if _joueur != null:
		_joueur.statistiques.annuler()
	visible = false


func basculer() -> void:
	if visible:
		fermer()
	else:
		ouvrir()


func _ligne(nom: String) -> Control:
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	var titre := VBoxContainer.new()
	titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titre.add_child(_texte(Statistiques.NOMS_AFFICHES[nom], TAILLE_TEXTE, COULEURS[nom]))
	titre.add_child(_texte(EFFETS[nom], 14, Color(0.7, 0.72, 0.8)))
	ligne.add_child(titre)
	ligne.add_child(_bouton("−", _modifier.bind(nom, false), Vector2(64, 56)))
	var valeur := _texte("0", TAILLE_TEXTE, Color.WHITE)
	valeur.custom_minimum_size = Vector2(150, 0)
	valeur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_valeurs[nom] = valeur
	ligne.add_child(valeur)
	ligne.add_child(_bouton("+", _modifier.bind(nom, true), Vector2(64, 56)))
	return ligne


func _modifier(nom: String, ajouter: bool) -> void:
	if ajouter:
		_joueur.statistiques.ajouter(nom)
	else:
		_joueur.statistiques.retirer(nom)


func _sur_valider() -> void:
	_joueur.statistiques.valider()


func _rafraichir() -> void:
	if _joueur == null or not visible:
		return
	var stats := _joueur.statistiques
	var objets := _joueur.equipement.statistiques_totales(Config.jeu)
	_points.text = "Points à répartir : %d" % stats.points_restants()
	for nom in Statistiques.NOMS:
		var attente := int(stats.en_attente[nom])
		var des_objets := int(objets.get(nom, 0))
		# Points du joueur, points en attente (+), points des objets portés (entre crochets).
		(_valeurs[nom] as Label).text = "%d" % stats.valeur(nom) + (" (+%d)" % attente if attente > 0 else "") 			+ (" [+%d]" % des_objets if des_objets > 0 else "")
	_valider.disabled = not stats.a_des_points_en_attente()
	var apercu := _joueur.caracteristiques(stats.apercu())
	_apercu.text = "%s — dégâts %d · %.2f coups/s · critique %d %%
Vie %d · défense %d · mana %d" % [
		str(_joueur.arme.get("nom", "")),
		roundi(apercu["degats"]),
		apercu["vitesse"],
		roundi(apercu["critique"] * 100.0),
		roundi(apercu["pv"]),
		roundi(apercu["defense"]),
		roundi(apercu["mana"]),
	]
	_objets.text = "Entre crochets : les points donnés par les objets portés." if not objets.is_empty() else ""


func _texte(texte: String, taille: int, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.text = texte
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_color", couleur)
	return etiquette


func _bouton(texte: String, action: Callable, taille: Vector2 = Vector2(170, 60)) -> Button:
	var bouton := Button.new()
	bouton.text = texte
	bouton.custom_minimum_size = taille
	bouton.focus_mode = Control.FOCUS_NONE
	bouton.add_theme_font_size_override("font_size", 26)
	bouton.pressed.connect(action)
	return bouton
