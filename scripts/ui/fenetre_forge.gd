extends PanelContainer
## Fenêtre de la forge de Vazylis : on choisit un objet (porté ou dans le sac), on voit sa chance
## de réussite, le prix et ce qu'il gagnera, puis on tente l'amélioration.

## Une amélioration a été tentée (pour l'effet sur l'enclume et le message).
signal tentative(objet: Objet, reussite: bool)

const COULEUR_TITRE := Color(1, 0.85, 0.4)

var _joueur: Joueur
var _disposition: BoxContainer
var _liste: VBoxContainer
var _ressources: Label
var _detail: VBoxContainer
var _ameliorer: Button
var _resultat: Label
var _choisi: Objet


func _ready() -> void:
	add_to_group(CommandesTactiles.GROUPE_UI)
	visible = false
	var fond := StyleBoxFlat.new()
	fond.bg_color = Color(0.08, 0.07, 0.07, 0.95)
	fond.set_corner_radius_all(16)
	fond.set_content_margin_all(18)
	fond.border_color = Color(1, 0.6, 0.25, 0.7)
	fond.set_border_width_all(2)
	add_theme_stylebox_override("panel", fond)

	var contenu := VBoxContainer.new()
	contenu.add_theme_constant_override("separation", 10)
	add_child(contenu)
	contenu.add_child(_texte("Forge de Vazylis", 30, COULEUR_TITRE))
	_ressources = _texte("", 20, Color(0.9, 0.9, 0.9))
	contenu.add_child(_ressources)

	# En paysage : la liste à gauche, le détail à droite ; en portrait, l'un sous l'autre.
	_disposition = BoxContainer.new()
	_disposition.add_theme_constant_override("separation", 16)
	contenu.add_child(_disposition)
	var defilement := ScrollContainer.new()
	defilement.custom_minimum_size = Vector2(340, 300)
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_liste = VBoxContainer.new()
	_liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_liste.add_theme_constant_override("separation", 6)
	defilement.add_child(_liste)
	_disposition.add_child(defilement)

	var colonne := VBoxContainer.new()
	colonne.custom_minimum_size = Vector2(330, 0)
	colonne.add_theme_constant_override("separation", 8)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 4)
	colonne.add_child(_detail)
	_ameliorer = _bouton("Améliorer", _sur_ameliorer)
	_ameliorer.add_theme_font_size_override("font_size", 26)
	colonne.add_child(_ameliorer)
	_resultat = _texte("", 22, Color.WHITE)
	_resultat.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	colonne.add_child(_resultat)
	_disposition.add_child(colonne)

	var fermer := _bouton("Fermer", fermer_fenetre)
	fermer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	contenu.add_child(fermer)


func relier(joueur: Joueur) -> void:
	_joueur = joueur
	_joueur.inventaire.change.connect(_rafraichir)
	_joueur.equipement_change.connect(_rafraichir)


func ouvrir() -> void:
	var ecran := get_viewport_rect().size
	_disposition.vertical = ecran.y > ecran.x
	visible = true
	_resultat.text = ""
	if _choisi == null or not _objets().has(_choisi):
		var objets := _objets()
		_choisi = objets[0] if not objets.is_empty() else null
	_rafraichir()
	reset_size()
	await get_tree().process_frame
	position = (get_viewport_rect().size - size) / 2.0


func fermer_fenetre() -> void:
	visible = false


func choisir(objet: Objet) -> void:
	_choisi = objet
	_resultat.text = ""
	_rafraichir()


func objet_choisi() -> Objet:
	return _choisi


## Les objets qu'on peut forger : ceux qu'on porte, puis ceux du sac.
func _objets() -> Array[Objet]:
	var objets: Array[Objet] = []
	for emplacement in Equipement.EMPLACEMENTS:
		var porte := _joueur.equipement.objet(emplacement)
		if porte != null:
			objets.append(porte)
	for objet in _joueur.inventaire.cases:
		if objet != null:
			objets.append(objet)
	return objets


func _rafraichir() -> void:
	if _joueur == null or not visible:
		return
	var config := Config.jeu
	var inventaire := _joueur.inventaire
	var morceaux := PackedStringArray()
	for id in config.ids_ressources():
		if str(config.ressource(id).get("famille", "")) != "familier":
			morceaux.append("%s %d" % [config.ressource(id).get("nom", id), inventaire.quantite(id)])
	morceaux.append("%d or" % inventaire.or_possede)
	_ressources.text = "   ".join(morceaux)

	for enfant in _liste.get_children():
		enfant.queue_free()
	for objet in _objets():
		var porte := _joueur.equipement.emplacement_de(objet) != ""
		var bouton := _bouton("%s%s  · niv. %d" % ["Porté · " if porte else "", objet.nom_affiche(), objet.niveau], choisir.bind(objet))
		bouton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		bouton.add_theme_font_size_override("font_size", 19)
		bouton.custom_minimum_size = Vector2(0, 48)
		bouton.add_theme_color_override("font_color", config.couleur_rarete(objet.rarete))
		if objet == _choisi:
			bouton.add_theme_color_override("font_color", Color.WHITE)
			bouton.modulate = Color(1, 0.9, 0.6)
		_liste.add_child(bouton)
	_afficher_detail()


func _afficher_detail() -> void:
	for enfant in _detail.get_children():
		enfant.queue_free()
	_ameliorer.visible = _choisi != null
	if _choisi == null:
		_detail.add_child(_texte("Rien à forger.", 20, Color(0.8, 0.8, 0.8)))
		return
	var config := Config.jeu
	var forge := _joueur.forge
	_detail.add_child(_texte(_choisi.nom_affiche(), 24, config.couleur_rarete(_choisi.rarete)))
	if forge.est_au_maximum(_choisi):
		_detail.add_child(_texte("Amélioration maximum atteinte (+%d)." % forge.palier_max(), 20, COULEUR_TITRE))
		_ameliorer.disabled = true
		return
	var palier := _choisi.amelioration + 1
	_detail.add_child(_texte("+%d → +%d" % [_choisi.amelioration, palier], 22, COULEUR_TITRE))
	_detail.add_child(_texte("Chance de réussite : %d %%" % roundi(forge.chance(_choisi) * 100.0), 20, Color.WHITE))
	var prix := forge.cout(_choisi)
	var ressource := config.ressource(prix["ressource"])
	var assez_materiau := _joueur.inventaire.quantite(prix["ressource"]) >= int(prix["quantite"])
	var assez_or := _joueur.inventaire.or_possede >= int(prix["or"])
	_detail.add_child(_texte("Prix : %d %s (tu en as %d)" % [prix["quantite"], ressource.get("nom", prix["ressource"]),
		_joueur.inventaire.quantite(prix["ressource"])], 19, Color(0.85, 0.95, 0.85) if assez_materiau else Color(1, 0.5, 0.45)))
	_detail.add_child(_texte("          %d or (tu en as %d)" % [prix["or"], _joueur.inventaire.or_possede], 19,
		Color(0.85, 0.95, 0.85) if assez_or else Color(1, 0.5, 0.45)))
	var facteur := config.multiplicateur_amelioration(palier) / config.multiplicateur_amelioration(_choisi.amelioration)
	if _choisi.degats > 0.0:
		_detail.add_child(_texte("Dégâts : %d → %d" % [roundi(_choisi.degats), roundi(_choisi.degats * facteur)], 19, Color(0.75, 0.88, 1)))
	if _choisi.armure > 0.0:
		_detail.add_child(_texte("Armure : %s → %s" % [_nombre(_choisi.armure), _nombre(_choisi.armure * facteur)], 19, Color(0.75, 0.88, 1)))
	_detail.add_child(_texte("Toutes ses valeurs : +%d %%" % roundi((facteur - 1.0) * 100.0), 17, Color(0.8, 0.8, 0.85)))
	_detail.add_child(_texte("Un échec fait perdre le prix, jamais le palier.", 16, Color(0.7, 0.7, 0.72)))
	_ameliorer.disabled = not forge.peut_payer(_choisi, _joueur.inventaire)


func _sur_ameliorer() -> void:
	if _choisi == null:
		return
	var resultat := _joueur.ameliorer_objet(_choisi)
	if resultat == Forge.Resultat.IMPOSSIBLE:
		return
	var reussite := resultat == Forge.Resultat.REUSSITE
	if reussite:
		_resultat.text = "Réussite ! %s" % _choisi.nom_affiche()
		_resultat.add_theme_color_override("font_color", PosteForge.COULEUR_REUSSITE)
	else:
		_resultat.text = "Échec… le métal a cédé. Le palier reste +%d." % _choisi.amelioration
		_resultat.add_theme_color_override("font_color", Color(0.75, 0.75, 0.78))
	tentative.emit(_choisi, reussite)
	_rafraichir()


func _nombre(valeur: float) -> String:
	return ("%.1f" % valeur).replace(".", ",") if valeur < 10.0 else str(roundi(valeur))


func _bouton(texte: String, action: Callable) -> Button:
	var bouton := Button.new()
	bouton.text = texte
	bouton.custom_minimum_size = Vector2(170, 60)
	bouton.focus_mode = Control.FOCUS_NONE
	bouton.add_theme_font_size_override("font_size", 24)
	bouton.pressed.connect(action)
	return bouton


func _texte(texte: String, taille: int, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.text = texte
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_color", couleur)
	return etiquette
