class_name FicheObjet
extends VBoxContainer
## Fiche détaillée d'un objet : nom (couleur de sa rareté), niveau, qualité, puissance,
## dégâts ou armure, statistiques et bonus en %.

const NOMS_EMPLACEMENTS := {
	"arme": "Arme", "casque": "Casque", "plastron": "Plastron", "gants": "Gants", "bottes": "Bottes",
	"ceinture": "Ceinture", "cape": "Cape", "collier": "Collier", "boucle_oreille": "Boucle d'oreille",
}


func _ready() -> void:
	add_theme_constant_override("separation", 4)


func afficher(objet: Objet) -> void:
	for enfant in get_children():
		enfant.queue_free()
	if objet == null:
		return
	var config := Config.jeu
	var couleur := config.couleur_rarete(objet.rarete)
	add_child(_texte(objet.nom, 26, couleur))
	var type: String = str(NOMS_EMPLACEMENTS.get(objet.emplacement, objet.emplacement))
	if objet.est_arme():
		type = str(config.arme(objet.type_arme).get("nom", type))
	add_child(_texte("%s · %s · niveau %d" % [config.nom_rarete(objet.rarete), type, objet.niveau], 17, couleur.lerp(Color.WHITE, 0.4)))
	var qualite := roundi(objet.qualite * 100.0)
	add_child(_texte("Qualité %d %%%s · puissance %d" % [qualite, " (parfaite)" if qualite >= 100 else "", objet.puissance(config)],
		17, Color(0.85, 0.88, 0.95)))
	if objet.degats > 0.0:
		add_child(_texte("Dégâts %d" % roundi(objet.degats), 20, Color.WHITE))
	if objet.armure > 0.0:
		add_child(_texte("Armure %d" % roundi(objet.armure), 20, Color.WHITE))
	for nom: String in objet.statistiques:
		add_child(_texte("+%d %s" % [objet.statistiques[nom], Statistiques.NOMS_AFFICHES.get(nom, nom)], 18, Color(0.75, 0.92, 0.75)))
	for nom: String in objet.bonus:
		add_child(_texte("+%.1f %% %s" % [float(objet.bonus[nom]) * 100.0, Objet.NOMS_BONUS.get(nom, nom)], 18, Color(0.7, 0.85, 1.0)))


func _texte(texte: String, taille: int, couleur: Color) -> Label:
	var etiquette := Label.new()
	etiquette.text = texte
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_color", couleur)
	etiquette.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return etiquette
