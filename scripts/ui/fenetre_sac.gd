extends PanelContainer
## Fenêtre du sac à dos : l'équipement porté, les cases du sac, l'or, et la fiche de l'objet touché.
## On s'équipe en faisant glisser un objet du sac vers le personnage (ou avec le bouton « Équiper »),
## on retire un objet en le faisant glisser vers le sac (ou avec « Retirer »).
## En bas : le recyclage automatique (rareté et types d'objets à recycler dès qu'ils tombent).
## Le jeu continue de tourner pendant qu'elle est ouverte.

signal or_gagne(quantite: int, raison: String)

const COLONNES := 8

var _joueur: Joueur
var _vignettes: Vignettes
var _disposition: BoxContainer
var _apercu: ApercuPersonnage
var _equipement: GridContainer
var _grille: GridContainer
var _or: Label
var _fiche: FicheObjet
var _action: Button
var _recycler: Button
var _filtre_rarete: OptionButton
var _filtre_types := {}
var _cases_sac: Array[CaseObjet] = []
var _cases_equipement := {}
## Case touchée : {"lieu": "sac"|"equipement", "cle": …}, ou vide.
var _choix := {}


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

	# En paysage : équipement, sac et fiche côte à côte ; en portrait, les uns sous les autres.
	_disposition = BoxContainer.new()
	_disposition.add_theme_constant_override("separation", 16)
	contenu.add_child(_disposition)
	_apercu = ApercuPersonnage.new()
	_disposition.add_child(_apercu)
	_equipement = GridContainer.new()
	_equipement.add_theme_constant_override("h_separation", 5)
	_equipement.add_theme_constant_override("v_separation", 5)
	_disposition.add_child(_equipement)
	_grille = GridContainer.new()
	_grille.columns = COLONNES
	_grille.add_theme_constant_override("h_separation", 5)
	_grille.add_theme_constant_override("v_separation", 5)
	_disposition.add_child(_grille)

	var colonne_fiche := VBoxContainer.new()
	colonne_fiche.add_theme_constant_override("separation", 8)
	var defilement := ScrollContainer.new()
	defilement.custom_minimum_size = Vector2(270, 200)
	defilement.size_flags_vertical = Control.SIZE_EXPAND_FILL
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_fiche = FicheObjet.new()
	_fiche.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	defilement.add_child(_fiche)
	colonne_fiche.add_child(defilement)
	var boutons_fiche := VBoxContainer.new()
	boutons_fiche.add_theme_constant_override("separation", 8)
	_action = _bouton("Équiper", _sur_action)
	_action.visible = false
	_action.add_theme_font_size_override("font_size", 22)
	boutons_fiche.add_child(_action)
	_recycler = _bouton("Recycler", _sur_recycler)
	_recycler.visible = false
	_recycler.add_theme_font_size_override("font_size", 22)
	boutons_fiche.add_child(_recycler)
	colonne_fiche.add_child(boutons_fiche)
	_disposition.add_child(colonne_fiche)

	contenu.add_child(_ligne_recyclage_auto())

	var fermer := _bouton("Fermer", fermer_fenetre)
	fermer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	contenu.add_child(fermer)


func relier(joueur: Joueur, vignettes: Vignettes) -> void:
	_joueur = joueur
	_vignettes = vignettes
	_vignettes.vignette_prete.connect(func(_id, _texture): _rafraichir())
	for emplacement in Array(Equipement.EMPLACEMENTS) + Array(Equipement.EMPLACEMENTS_A_VENIR):
		var case_objet := _nouvelle_case("equipement", emplacement)
		_cases_equipement[emplacement] = case_objet
		_equipement.add_child(case_objet)
	for i in _joueur.inventaire.nombre_cases():
		var case_objet := _nouvelle_case("sac", i)
		_cases_sac.append(case_objet)
		_grille.add_child(case_objet)
	_joueur.inventaire.change.connect(_rafraichir)
	_joueur.equipement_change.connect(_rafraichir)
	_apercu.relier(joueur)
	_afficher_filtres()


func ouvrir() -> void:
	var ecran := get_viewport_rect().size
	var portrait := ecran.y > ecran.x
	_disposition.vertical = portrait
	_equipement.columns = 7 if portrait else 2
	visible = true
	_choix = {}
	_rafraichir()
	_apercu.rafraichir()
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


## Toucher une case : on voit la fiche de son objet.
func choisir(lieu: String, cle: Variant) -> void:
	_choix = {"lieu": lieu, "cle": cle}
	_rafraichir()


func _nouvelle_case(lieu: String, cle: Variant) -> CaseObjet:
	var case_objet := CaseObjet.new()
	case_objet.lieu = lieu
	case_objet.cle = cle
	case_objet.peut_recevoir = _peut_deposer.bind(lieu, cle)
	case_objet.pressed.connect(choisir.bind(lieu, cle))
	case_objet.deposee.connect(deposer)
	return case_objet


func _objet(choix: Dictionary) -> Objet:
	if choix.is_empty():
		return null
	if choix["lieu"] == "sac":
		return _joueur.inventaire.objet(int(choix["cle"]))
	return _joueur.equipement.objet(str(choix["cle"]))


func _peut_deposer(source: Dictionary, lieu: String, cle: Variant) -> bool:
	var objet := _objet(source)
	if objet == null:
		return false
	if source["lieu"] == "sac" and lieu == "equipement":
		return not str(cle) in Equipement.EMPLACEMENTS_A_VENIR
	if source["lieu"] == "equipement" and lieu == "sac":
		return source["cle"] != "arme"
	return source["lieu"] == "sac" and lieu == "sac"


## Une case a été déposée sur une autre (glisser-déposer).
func deposer(source: Dictionary, cible: Dictionary) -> void:
	if source["lieu"] == "sac" and cible["lieu"] == "equipement":
		var objet := _objet(source)
		# Sur un petit écran, on accepte un dépôt « à peu près » sur le personnage :
		# si la case visée ne convient pas, l'objet va dans son emplacement.
		var emplacement := str(cible["cle"])
		if not _joueur.equipement.accepte(emplacement, objet):
			emplacement = ""
		_joueur.equiper_depuis_sac(int(source["cle"]), emplacement)
		_choix = {"lieu": "equipement", "cle": emplacement if not emplacement.is_empty() else _joueur.equipement.emplacement_pour(objet)}
	elif source["lieu"] == "equipement" and cible["lieu"] == "sac":
		_joueur.retirer_vers_sac(str(source["cle"]))
		_choix = {}
	elif source["lieu"] == "sac" and cible["lieu"] == "sac":
		_joueur.inventaire.echanger(int(source["cle"]), int(cible["cle"]))
		_choix = cible
	_rafraichir()


func _sur_action() -> void:
	if _choix.is_empty():
		return
	if _choix["lieu"] == "sac":
		var objet := _objet(_choix)
		var emplacement := _joueur.equipement.emplacement_pour(objet)
		if _joueur.equiper_depuis_sac(int(_choix["cle"])):
			_choix = {"lieu": "equipement", "cle": emplacement}
	elif _joueur.retirer_vers_sac(str(_choix["cle"])):
		_choix = {}
	_rafraichir()


func _sur_recycler() -> void:
	if _choix.is_empty() or _choix["lieu"] != "sac":
		return
	var objet := _objet(_choix)
	var gain := _joueur.inventaire.recycler(int(_choix["cle"]))
	if gain > 0:
		or_gagne.emit(gain, objet.nom)
	_choix = {}
	_rafraichir()


## Ligne du recyclage automatique : « Recyclage auto : [sous Doré] [Armes] [Armures] [Bijoux] [Recycler le sac] ».
func _ligne_recyclage_auto() -> Control:
	var ligne := HFlowContainer.new()
	ligne.add_theme_constant_override("h_separation", 10)
	ligne.add_theme_constant_override("v_separation", 6)
	ligne.add_child(_texte("Recyclage auto :", 20, Color(0.85, 0.88, 0.95)))
	_filtre_rarete = OptionButton.new()
	_filtre_rarete.focus_mode = Control.FOCUS_NONE
	_filtre_rarete.add_theme_font_size_override("font_size", 20)
	_filtre_rarete.custom_minimum_size = Vector2(180, 52)
	_filtre_rarete.item_selected.connect(_sur_filtre_rarete)
	ligne.add_child(_filtre_rarete)
	for type in RecyclageAuto.TYPES:
		var case_a_cocher := CheckBox.new()
		case_a_cocher.text = RecyclageAuto.NOMS_TYPES[type]
		case_a_cocher.focus_mode = Control.FOCUS_NONE
		case_a_cocher.add_theme_font_size_override("font_size", 20)
		case_a_cocher.toggled.connect(_sur_filtre_type.bind(type))
		_filtre_types[type] = case_a_cocher
		ligne.add_child(case_a_cocher)
	var maintenant := _bouton("Recycler le sac", _sur_recycler_le_sac)
	maintenant.add_theme_font_size_override("font_size", 20)
	maintenant.custom_minimum_size = Vector2(190, 52)
	ligne.add_child(maintenant)
	return ligne


## Remplit la liste des raretés : « Désactivé », puis « Sous Argenté », « Sous Doré »…
func _afficher_filtres() -> void:
	var config := Config.jeu
	var filtre := _joueur.recyclage_auto
	_filtre_rarete.clear()
	_filtre_rarete.add_item("Désactivé")
	var raretes := config.ids_raretes()
	for i in range(1, raretes.size()):
		_filtre_rarete.add_item("Sous %s" % config.nom_rarete(raretes[i]))
	_filtre_rarete.select(raretes.find(filtre.rarete_limite) if filtre.actif else 0)
	for type: String in _filtre_types:
		(_filtre_types[type] as CheckBox).set_pressed_no_signal(bool(filtre.types.get(type, true)))


func _sur_filtre_rarete(index: int) -> void:
	var raretes := Config.jeu.ids_raretes()
	_joueur.recyclage_auto.regler(index > 0, raretes[maxi(index, 1)])


func _sur_filtre_type(coche: bool, type: String) -> void:
	_joueur.recyclage_auto.cocher(type, coche)


func _sur_recycler_le_sac() -> void:
	var gain := _joueur.recycler_le_sac_selon_les_filtres()
	if gain > 0:
		or_gagne.emit(gain, "le sac")
	_choix = {}
	_rafraichir()


func _rafraichir() -> void:
	if _joueur == null or not visible:
		return
	var config := Config.jeu
	var femme := _joueur.personnage == IdentifiantsAssets.HEROS_FEMME
	_or.text = "%d or" % _joueur.inventaire.or_possede
	for i in _cases_sac.size():
		_remplir_case(_cases_sac[i], _joueur.inventaire.objet(i), _choix == {"lieu": "sac", "cle": i}, "", false, femme)
	for emplacement: String in _cases_equipement:
		var bloquee := emplacement in Equipement.EMPLACEMENTS_A_VENIR
		_remplir_case(_cases_equipement[emplacement], _joueur.equipement.objet(emplacement),
			_choix == {"lieu": "equipement", "cle": emplacement}, str(Equipement.NOMS.get(emplacement, emplacement)), bloquee, femme)

	var objet := _objet(_choix)
	var porte: Objet = null
	_action.visible = false
	_recycler.visible = false
	if objet != null and _choix["lieu"] == "sac":
		porte = _joueur.equipement.objet(_joueur.equipement.emplacement_pour(objet))
		_action.text = "Équiper"
		_action.visible = true
		_recycler.text = "Recycler : +%d or" % _joueur.inventaire.valeur_recyclage(objet)
		_recycler.visible = true
	elif objet != null and _choix["cle"] != "arme":
		_action.text = "Retirer"
		_action.visible = true
		_action.disabled = _joueur.inventaire.est_plein()
	if _action.text == "Équiper":
		_action.disabled = false
	_fiche.afficher(objet, porte)


func _remplir_case(case_objet: CaseObjet, objet: Objet, choisie: bool, nom_si_vide: String, bloquee: bool, femme: bool) -> void:
	var config := Config.jeu
	case_objet.occupee = objet != null
	var texture: Texture2D = _vignettes.demander(objet.modele(config, femme)) if objet != null else null
	var couleur := config.couleur_rarete(objet.rarete) if objet != null else Color.WHITE
	case_objet.afficher(texture, couleur, objet.niveau if objet != null else 0, choisie, nom_si_vide, bloquee)


func _bouton(texte: String, action: Callable) -> Button:
	var bouton := Button.new()
	bouton.text = texte
	bouton.custom_minimum_size = Vector2(170, 60)
	bouton.focus_mode = Control.FOCUS_NONE
	bouton.add_theme_font_size_override("font_size", 26)
	bouton.pressed.connect(action)
	return bouton


func _texte(texte: String, taille: int, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.text = texte
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_color", couleur)
	return etiquette
