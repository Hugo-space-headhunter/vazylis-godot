class_name Panoplies
extends RefCounted
## Bonus des panoplies portées (config/panoplies.cfg) : chaque palier atteint (2 pièces, 4 pièces…)
## ajoute ses statistiques, ses bonus en % et son effet spécial. Plusieurs panoplies se cumulent.


## Nombre de pièces portées de chaque panoplie : {"panoplie.couronne_verger": 2, …}
static func compter(equipement: Equipement, config: ConfigJeu) -> Dictionary:
	var compte := {}
	for objet: Objet in equipement.objets.values():
		var panoplie := objet.panoplie(config)
		if not panoplie.is_empty():
			compte[panoplie] = int(compte.get(panoplie, 0)) + 1
	return compte


## Total des bonus actifs : {"statistiques": {…}, "bonus": {…}, "effets": ["regain", …]}.
static func bonus(equipement: Equipement, config: ConfigJeu) -> Dictionary:
	var total := {"statistiques": {}, "bonus": {}, "effets": []}
	var compte := compter(equipement, config)
	for id: String in compte:
		for palier: Dictionary in paliers_actifs(id, int(compte[id]), config):
			var stats: Dictionary = palier.get("statistiques", {})
			for nom: String in stats:
				total["statistiques"][nom] = int(total["statistiques"].get(nom, 0)) + int(stats[nom])
			var pourcents: Dictionary = palier.get("bonus", {})
			for nom: String in pourcents:
				total["bonus"][nom] = float(total["bonus"].get(nom, 0.0)) + float(pourcents[nom])
			var effet := str(palier.get("effet", ""))
			if not effet.is_empty() and not effet in total["effets"]:
				total["effets"].append(effet)
	return total


## Paliers d'une panoplie atteints avec ce nombre de pièces.
static func paliers_actifs(id: String, pieces: int, config: ConfigJeu) -> Array:
	return config.panoplie(id).get("paliers", []).filter(func(p: Dictionary) -> bool: return pieces >= int(p.get("pieces", 99)))


## Nombre de pièces de la panoplie complète.
static func nombre_de_pieces(id: String, config: ConfigJeu) -> int:
	return config.pieces_de_panoplie(id).size()


## Texte d'un palier : « 2 pièces : +15 Vitalité » ou « 3 pièces : +5 % vie, Regain (…) ».
static func decrire_palier(palier: Dictionary, config: ConfigJeu) -> String:
	var morceaux := PackedStringArray()
	var stats: Dictionary = palier.get("statistiques", {})
	for nom: String in stats:
		morceaux.append("+%d %s" % [stats[nom], Statistiques.NOMS_AFFICHES.get(nom, nom)])
	var pourcents: Dictionary = palier.get("bonus", {})
	for nom: String in pourcents:
		morceaux.append("+%d %% %s" % [roundi(float(pourcents[nom]) * 100.0), Objet.NOMS_BONUS.get(nom, nom)])
	var effet := str(palier.get("effet", ""))
	if not effet.is_empty():
		var definition := config.effet_panoplie(effet)
		morceaux.append("%s (%s)" % [definition.get("nom", effet), definition.get("description", "")])
	return "%d pièces : %s" % [int(palier.get("pieces", 0)), ", ".join(morceaux)]
