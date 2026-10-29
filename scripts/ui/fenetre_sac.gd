extends PanelContainer
## Fenêtre du sac à dos : les cases du sac (vignette, cadre à la couleur de la rareté, niveau),
## l'or, et la fiche de l'objet touché. Le jeu continue de tourner pendant qu'elle est ouverte.

const COLONNES := 8
const TAILLE_CASE := 58

var _joueur: Joueur
var _vignettes: Vignettes
var _grille: GridContainer
var _disposition: BoxContainer
var _or: Label
var _fiche: FicheObjet
var _cases: Array[Button] = []
var _case_choisie := -1


func _ready() -> void:
	add_to_group(CommandesTactiles.GROUPE_UI)
	visible = false
	var fond := StyleBoxFlat.new()
	fond.bg_color = Color(0.06, 0.08, 0.13, 0.94)
	fond.set_corner_radius_all(16)
	fond.set_content_margin_all(18)
	fond.border_color = Color(1, 0.85, 0.4, 0.6)
	fond.set_border_width_all(2)
	add_theme_stylebox_override("panel", fond)

	var contenu := VBoxContainer.new()
	contenu.add_theme_constant_override("separation", 10)
	add_child(contenu)
	var entete := HBoxContainer.new()
	var titre := _texte("Sac à dos", 30, Color(1, 0.85, 0.4))
	titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(titre)
	_or = _texte("", 22, Color(1, 0.85, 0.4))
	entete.add_child(_or)
	contenu.add_child(entete)

	# En paysage, la fiche est à droite des cases ; en portrait, en dessous.
	_disposition = BoxContainer.new()
	_disposition.add_theme_constant_override("separation", 16)
	contenu.add_child(_disposition)
	_grille = GridContainer.new()
	_grille.columns = COLONNES
	_grille.add_theme_constant_override("h_separation", 5)
	_grille.add_theme_constant_override("v_separation", 5)
	_disposition.add_child(_grille)
	var defilement := ScrollContainer.new()
	defilement.custom_minimum_size = Vector2(300, 200)
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_fiche = FicheObjet.new()
	_fiche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	defilement.add_child(_fiche)
	_disposition.add_child(defilement)

	var fermer := Button.new()
	fermer.text = "Fermer"
	fermer.custom_minimum_size = Vector2(170, 60)
	fermer.focus_mode = Control.FOCUS_NONE
	fermer.add_theme_font_size_override("font_size", 26)
	fermer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	fermer.pressed.connect(fermer_fenetre)
	contenu.add_child(fermer)


func relier(joueur: Joueur, vignettes: Vignettes) -> void:
	_joueur = joueur
	_vignettes = vignettes
	_vignettes.vignette_prete.connect(func(_id, _texture): _rafraichir())
	for i in _joueur.inventaire.nombre_cases():
		var bouton := Button.new()
		bouton.custom_minimum_size = Vector2(TAILLE_CASE, TAILLE_CASE)
		bouton.focus_mode = Control.FOCUS_NONE
		bouton.expand_icon = true
		bouton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bouton.pressed.connect(_choisir.bind(i))
		var niveau := Label.new()
		niveau.name = "Niveau"
		niveau.add_theme_font_size_override("font_size", 14)
		niveau.add_theme_color_override("font_outline_color", Color.BLACK)
		niveau.add_theme_constant_override("outline_size", 4)
		niveau.position = Vector2(4, TAILLE_CASE - 22)
		niveau.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bouton.add_child(niveau)
		_grille.add_child(bouton)
		_cases.append(bouton)
	_joueur.inventaire.change.connect(_rafraichir)


func ouvrir() -> void:
	var ecran := get_viewport_rect().size
	_disposition.vertical = ecran.y > ecran.x
	visible = true
	_case_choisie = -1
	_rafraichir()
	reset_size()
	await get_tree().process_frame
	position = (get_viewport_rect().size - size) / 2.0


func fermer_fenetre() -> void:
	visible = false


func basculer() -> void:
	if visible:
		fermer_fenetre()
	else:
		ouvrir()


func _choisir(case_numero: int) -> void:
	_case_choisie = case_numero
	_rafraichir()


func _rafraichir() -> void:
	if _joueur == null or not visible:
		return
	var config := Config.jeu
	var inventaire := _joueur.inventaire
	_or.text = "%d or" % inventaire.or_possede
	for i in _cases.size():
		var objet := inventaire.objet(i)
		var bouton := _cases[i]
		var couleur := config.couleur_rarete(objet.rarete) if objet != null else Color(1, 1, 1, 0.15)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0.45) if objet == null else couleur.darkened(0.75)
		style.border_color = couleur
		style.set_border_width_all(4 if i == _case_choisie else 2)
		style.set_corner_radius_all(8)
		for etat in ["normal", "hover", "pressed"]:
			bouton.add_theme_stylebox_override(etat, style)
		bouton.icon = _vignettes.demander(objet.modele(config, _joueur.personnage == IdentifiantsAssets.HEROS_FEMME)) if objet != null else null
		(bouton.get_node("Niveau") as Label).text = str(objet.niveau) if objet != null else ""
	_fiche.afficher(inventaire.objet(_case_choisie))


func _texte(texte: String, taille: int, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.text = texte
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_color", couleur)
	return etiquette
