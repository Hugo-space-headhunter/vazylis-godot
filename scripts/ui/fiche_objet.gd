class_name FicheObjet
extends VBoxContainer
## Fiche détaillée d'un objet : nom (couleur de sa rareté), niveau, qualité, puissance,
## dégâts ou armure, statistiques et bonus en %, et sa panoplie (pièces portées, paliers actifs).
## Peut le comparer à l'objet porté au même endroit : chaque valeur montre son écart avec l'objet porté
## (vert si c'est mieux, rouge si c'est moins bien), et ce qu'on perdrait est listé à la fin.

const COULEUR_MIEUX := Color(0.5, 1, 0.5)
const COULEUR_MOINS := Color(1, 0.5, 0.45)

const NOMS_EMPLACEMENTS := {
	"arme": "Arme", "casque": "Casque", "plastron": "Plastron", "gants": "Gants", "bottes": "Bottes",
	"ceinture": "Ceinture", "cape": "Cape", "collier": "Collier", "boucle_oreille": "Boucle d'oreille",
}


func _ready() -> void:
	add_theme_constant_override("separation", 4)


func afficher(objet: Objet, porte: Objet = null, equipement: Equipement = null) -> void:
	for enfant in get_children():
		enfant.queue_free()
	if objet == null:
		return
	var config := Config.jeu
	var couleur := config.couleur_rarete(objet.rarete)
	add_child(_texte(objet.nom_affiche(), 26, couleur))
	var type: String = str(NOMS_EMPLACEMENTS.get(objet.emplacement, objet.emplacement))
	if objet.est_arme():
		type = str(config.arme(objet.type_arme).get("nom", type))
	add_child(_texte("%s · %s · niveau %d" % [config.nom_rarete(objet.rarete), type, objet.niveau], 17, couleur.lerp(Color.WHITE, 0.4)))
	var qualite := roundi(objet.qualite * 100.0)
	add_child(_texte("Qualité %d %%%s · puissance %d" % [qualite, " (parfaite)" if qualite >= 100 else "", objet.puissance(config)],
		17, Color(0.85, 0.88, 0.95)))
	if objet.amelioration > 0:
		add_child(_texte("Amélioré +%d à la forge : valeurs ×%s" % [objet.amelioration,
			("%.2f" % config.multiplicateur_amelioration(objet.amelioration)).replace(".", ",")], 17, Color(1, 0.85, 0.4)))
	var compare := porte if porte != null and porte != objet else null
	if objet.degats > 0.0:
		_ligne("Dégâts %s" % _nombre(objet.degats), 20, Color.WHITE, objet.degats, compare.degats if compare else NAN, false)
	if objet.armure > 0.0:
		_ligne("Armure %s" % _nombre(objet.armure), 20, Color.WHITE, objet.armure, compare.armure if compare else NAN, false)
	for nom: String in objet.statistiques:
		var ancienne: float = float(compare.statistiques.get(nom, 0)) if compare else NAN
		_ligne("+%d %s" % [objet.statistiques[nom], Statistiques.NOMS_AFFICHES.get(nom, nom)], 18, Color(0.75, 0.92, 0.75),
			float(objet.statistiques[nom]), ancienne, false)
	for nom: String in objet.bonus:
		var ancien: float = float(compare.bonus.get(nom, 0.0)) * 100.0 if compare else NAN
		_ligne(("+%.1f %% %s" % [float(objet.bonus[nom]) * 100.0, Objet.NOMS_BONUS.get(nom, nom)]).replace(".", ","), 18, Color(0.7, 0.85, 1.0),
			float(objet.bonus[nom]) * 100.0, ancien, true)
	if compare != null:
		_pertes(objet, compare)
	_afficher_panoplie(objet, equipement, config)
	if porte != null and porte != objet:
		var ecart := objet.puissance(config) - porte.puissance(config)
		var signe := "+" if ecart > 0 else ""
		var couleur_ecart := COULEUR_MIEUX if ecart > 0 else (COULEUR_MOINS if ecart < 0 else Color(0.85, 0.85, 0.85))
		add_child(_texte("Porté : %s (puissance %d) → %s%d" % [porte.nom_affiche(), porte.puissance(config), signe, ecart], 16, couleur_ecart))



## Une ligne de valeur, suivie de son écart avec l'objet porté (« ancienne » = NAN : pas de comparaison).
func _ligne(texte: String, taille: int, couleur: Color, valeur: float, ancienne: float, pourcent: bool) -> void:
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	var valeur_affichee := _texte(texte, taille, couleur)
	valeur_affichee.autowrap_mode = TextServer.AUTOWRAP_OFF
	ligne.add_child(valeur_affichee)
	if not is_nan(ancienne):
		var ecart := valeur - ancienne
		if absf(ecart) >= 0.05:
			var format := "%+.1f %%" if pourcent else ("%+.1f" if absf(ecart) < 10.0 else "%+.0f")
			var texte_ecart := (format % ecart).replace(".", ",")
			var affiche_ecart := _texte(("▲ " if ecart > 0 else "▼ ") + texte_ecart, taille - 3, COULEUR_MIEUX if ecart > 0 else COULEUR_MOINS)
			affiche_ecart.autowrap_mode = TextServer.AUTOWRAP_OFF
			ligne.add_child(affiche_ecart)
	add_child(ligne)


## Ce que l'objet porté donne et que celui-ci n'a pas : perdu en changeant.
func _pertes(objet: Objet, porte: Objet) -> void:
	for nom: String in porte.statistiques:
		if not objet.statistiques.has(nom):
			add_child(_texte("▼ −%d %s (perdu)" % [porte.statistiques[nom], Statistiques.NOMS_AFFICHES.get(nom, nom)], 16, COULEUR_MOINS))
	for nom: String in porte.bonus:
		if not objet.bonus.has(nom):
			add_child(_texte(("▼ −%.1f %% %s (perdu)" % [float(porte.bonus[nom]) * 100.0, Objet.NOMS_BONUS.get(nom, nom)]).replace(".", ","),
				16, COULEUR_MOINS))


## « Panoplie Couronne du Verger (2/3) », puis ses paliers : en vert ceux qui sont actifs.
func _afficher_panoplie(objet: Objet, equipement: Equipement, config: ConfigJeu) -> void:
	var id := objet.panoplie(config)
	if id.is_empty():
		return
	var portees := int(Panoplies.compter(equipement, config).get(id, 0)) if equipement != null else 0
	add_child(_texte("Panoplie %s (%d/%d)" % [config.panoplie(id).get("nom", id), portees, Panoplies.nombre_de_pieces(id, config)],
		19, Color(0.55, 0.95, 0.6)))
	for palier: Dictionary in config.panoplie(id).get("paliers", []):
		var actif := portees >= int(palier.get("pieces", 99))
		add_child(_texte(Panoplies.decrire_palier(palier, config), 16, Color(0.6, 1, 0.6) if actif else Color(0.6, 0.62, 0.66)))


## Un nombre lisible : une décimale en dessous de 10 (0,5), un entier au-dessus.
func _nombre(valeur: float) -> String:
	return ("%.1f" % valeur).replace(".", ",") if valeur < 10.0 else str(roundi(valeur))


func _texte(texte: String, taille: int, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.text = texte
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_color", couleur)
	etiquette.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return etiquette
