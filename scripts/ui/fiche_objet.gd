class_name FicheObjet
extends VBoxContainer
## Fiche détaillée d'un objet : nom (couleur de sa rareté), niveau, qualité, puissance,
## dégâts ou armure, statistiques et bonus en %, et sa panoplie (pièces portées, paliers actifs).
## Peut le comparer à l'objet porté au même endroit.

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
	if objet.degats > 0.0:
		add_child(_texte("Dégâts %s" % _nombre(objet.degats), 20, Color.WHITE))
	if objet.armure > 0.0:
		add_child(_texte("Armure %s" % _nombre(objet.armure), 20, Color.WHITE))
	for nom: String in objet.statistiques:
		add_child(_texte("+%d %s" % [objet.statistiques[nom], Statistiques.NOMS_AFFICHES.get(nom, nom)], 18, Color(0.75, 0.92, 0.75)))
	for nom: String in objet.bonus:
		add_child(_texte("+%.1f %% %s" % [float(objet.bonus[nom]) * 100.0, Objet.NOMS_BONUS.get(nom, nom)], 18, Color(0.7, 0.85, 1.0)))
	_afficher_panoplie(objet, equipement, config)
	if porte != null and porte != objet:
		var ecart := objet.puissance(config) - porte.puissance(config)
		var signe := "+" if ecart > 0 else ""
		var couleur_ecart := Color(0.5, 1, 0.5) if ecart > 0 else (Color(1, 0.5, 0.45) if ecart < 0 else Color(0.85, 0.85, 0.85))
		add_child(_texte("Porté : %s (puissance %d) → %s%d" % [porte.nom_affiche(), porte.puissance(config), signe, ecart], 16, couleur_ecart))



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
