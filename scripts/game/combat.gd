class_name Combat
extends RefCounted
## Formules de combat (docs/game-design.md, « Formules de combat »).
## « arme » est un type d'arme de config/armes.cfg (voir ConfigJeu.arme).
## Les objets portés interviennent par trois paramètres facultatifs :
##   degats_arme_objet : dégâts de l'arme portée (sinon, ceux d'une arme standard du niveau) ;
##   bonus             : bonus en % des objets portés (voir Equipement.bonus_totaux) ;
##   armure_objets     : armure des objets portés.


## Dégâts d'une arme standard parfaite : (base + par_niveau × niveau) × rareté × multiplicateur du type d'arme.
static func degats_arme(niveau: int, arme: Dictionary, config: ConfigJeu) -> float:
	var brut := config.combat("arme", "degats_base") + config.combat("arme", "degats_par_niveau") * niveau
	return brut * config.multiplicateur_rarete(config.rarete_arme()) * float(arme.get("multiplicateur_degats", 1.0))


## Dégâts d'un coup normal : (arme + 2 × Force) × (1 + 0,3 % × statistique d'affinité) × (1 + bonus de dégâts).
static func degats_coup(niveau: int, stats: Statistiques, arme: Dictionary, config: ConfigJeu,
		degats_arme_objet: float = -1.0, bonus: Dictionary = {}) -> float:
	var base := degats_arme_objet if degats_arme_objet >= 0.0 else degats_arme(niveau, arme, config)
	var force := stats.valeur("force") * config.statistique("force", "degats_par_point")
	var affinite := stats.valeur(str(arme.get("affinite", "force"))) * config.statistique("affinite", "bonus_par_point")
	return (base + force) * (1.0 + affinite) * (1.0 + float(bonus.get("degats", 0.0)))


## Chance de coup critique (0 à 1), plafonnée.
static func chance_critique(stats: Statistiques, arme: Dictionary, config: ConfigJeu, bonus: Dictionary = {}) -> float:
	var chance := config.combat("critique", "chance") \
		+ stats.valeur("agilite") * config.statistique("agilite", "critique_par_point") \
		+ float(arme.get("bonus_critique", 0.0)) + float(bonus.get("chance_critique", 0.0))
	return minf(chance, config.statistique("plafonds", "critique_max"))


static func multiplicateur_critique(arme: Dictionary, bonus: Dictionary = {}) -> float:
	return float(arme.get("multiplicateur_critique", 1.5)) + float(bonus.get("degats_critiques", 0.0))


## Coups par seconde : vitesse de l'arme × (1 + 0,4 % × Agilité + bonus), au plus ×2,5.
static func vitesse_attaque(stats: Statistiques, arme: Dictionary, config: ConfigJeu, bonus: Dictionary = {}) -> float:
	var multiplicateur := 1.0 + stats.valeur("agilite") * config.statistique("agilite", "vitesse_par_point") \
		+ float(bonus.get("vitesse_attaque", 0.0))
	return float(arme.get("vitesse", 1.0)) * minf(multiplicateur, config.statistique("plafonds", "vitesse_max"))


## Points de vie : (base + par niveau + 12 × Vitalité) × (1 + bonus de vie).
static func pv_joueur(niveau: int, stats: Statistiques, config: ConfigJeu, bonus: Dictionary = {}) -> float:
	var pv := config.combat("joueur", "pv_base") + config.combat("joueur", "pv_par_niveau") * niveau \
		+ stats.valeur("vitalite") * config.statistique("vitalite", "pv_par_point")
	return pv * (1.0 + float(bonus.get("vie", 0.0)))


## Défense : armure des objets + bouclier (par niveau) + 0,5 × Vitalité.
static func defense_joueur(niveau: int, stats: Statistiques, arme: Dictionary, config: ConfigJeu,
		armure_objets: float = 0.0) -> float:
	return armure_objets + float(arme.get("defense_par_niveau", 0.0)) * niveau \
		+ stats.valeur("vitalite") * config.statistique("vitalite", "defense_par_point")


static func mana(stats: Statistiques, config: ConfigJeu) -> float:
	return stats.valeur("intelligence") * config.statistique("intelligence", "mana_par_point")


## Part des dégâts évitée grâce à la défense (0 à 0,75).
static func reduction(defense: float, niveau_attaquant: int, config: ConfigJeu) -> float:
	if defense <= 0.0:
		return 0.0
	var facteur := config.statistique("defense", "facteur_niveau_attaquant") * maxi(1, niveau_attaquant)
	return minf(defense / (defense + facteur), config.statistique("plafonds", "reduction_max"))


## Dégâts moyens par seconde, critiques compris (contre un adversaire sans défense).
static func dps(niveau: int, stats: Statistiques, arme: Dictionary, config: ConfigJeu,
		degats_arme_objet: float = -1.0, bonus: Dictionary = {}) -> float:
	var bonus_critique := chance_critique(stats, arme, config, bonus) * (multiplicateur_critique(arme, bonus) - 1.0)
	return degats_coup(niveau, stats, arme, config, degats_arme_objet, bonus) \
		* vitesse_attaque(stats, arme, config, bonus) * (1.0 + bonus_critique)


## Le joueur « moyen » qui sert à régler les monstres : 1 point par statistique et par niveau,
## et un équipement complet standard de son niveau, de qualité moyenne.
## Renvoie {"statistiques": Statistiques, "degats_arme": float, "armure": float, "arme": Dictionary}.
static func joueur_moyen(niveau: int, config: ConfigJeu) -> Dictionary:
	var qualite := (float(config.generation_objets("qualite_min")) + float(config.generation_objets("qualite_max"))) / 2.0
	var puissance := float(niveau) * config.multiplicateur_rarete(config.rarete_arme())
	var arme := config.arme(config.arme_reference())
	var parts: Dictionary = config.generation_objets("part_armure")
	var armure := 0.0
	for part in parts.values():
		armure += puissance * float(part) * qualite
	# Statistiques des objets : l'arme et les armures (1 à 2 chacune), les 3 bijoux (2 à 3 chacun).
	var bornes: Array = config.generation_objets("nombre_statistiques")
	var bornes_bijoux: Array = config.generation_objets("nombre_statistiques_bijoux")
	var points := (parts.size() + 1) * (float(bornes[0]) + float(bornes[1])) / 2.0 \
		* float(config.generation_objets("statistiques_par_puissance")) * puissance * qualite \
		+ 3.0 * (float(bornes_bijoux[0]) + float(bornes_bijoux[1])) / 2.0 \
		* float(config.generation_objets("statistiques_par_puissance_bijoux")) * puissance * qualite
	var par_statistique := roundi(points / Statistiques.NOMS.size())
	var supplement := {}
	for nom in Statistiques.NOMS:
		supplement[nom] = par_statistique
	return {
		"statistiques": Statistiques.joueur_moyen(niveau, config).avec_bonus(supplement),
		"degats_arme": degats_arme(niveau, arme, config) * qualite,
		"armure": armure,
		"arme": arme,
	}


## Points de vie d'un monstre : le joueur « moyen » de son niveau le tue en environ 10 secondes.
static func pv_monstre(niveau: int, config: ConfigJeu) -> float:
	var moyen := joueur_moyen(niveau, config)
	return dps(niveau, moyen["statistiques"], moyen["arme"], config, moyen["degats_arme"]) \
		* config.combat("calibrage", "secondes_pour_tuer_un_monstre")


## Dégâts bruts d'une attaque de monstre (avant la défense du joueur) : il tue le joueur
## « moyen » de son niveau, défense comprise, en environ 60 secondes.
static func degats_monstre(niveau_monstre: int, niveau_joueur: int, passif: bool,
		intervalle_attaque: float, config: ConfigJeu) -> float:
	var moyen := joueur_moyen(niveau_monstre, config)
	var stats: Statistiques = moyen["statistiques"]
	var defense := defense_joueur(niveau_monstre, stats, moyen["arme"], config, moyen["armure"])
	var protection := 1.0 - reduction(defense, niveau_monstre, config)
	var dps_monstre := pv_joueur(niveau_monstre, stats, config) / config.combat("calibrage", "secondes_pour_etre_tue") / protection
	var degats := dps_monstre * intervalle_attaque
	if passif:
		degats *= config.combat("calibrage", "multiplicateur_passifs")
	var ecart := niveau_monstre - niveau_joueur - int(config.combat("calibrage", "ecart_sans_bonus"))
	if ecart > 0:
		degats *= 1.0 + config.combat("calibrage", "bonus_par_niveau") * ecart
	return degats


## Dégâts réellement subis par le joueur après sa défense.
static func degats_subis(degats_bruts: float, niveau_attaquant: int, defense: float, config: ConfigJeu) -> int:
	return maxi(1, roundi(degats_bruts * (1.0 - reduction(defense, niveau_attaquant, config))))


## Un coup du joueur : renvoie {"degats": int, "critique": bool}.
## La hache ignore une part de la défense de la cible (« ignore_defense »).
static func coup_joueur(niveau: int, stats: Statistiques, arme: Dictionary, defense_cible: float,
		niveau_cible: int, config: ConfigJeu, hasard: RandomNumberGenerator,
		degats_arme_objet: float = -1.0, bonus: Dictionary = {}) -> Dictionary:
	var critique := hasard.randf() < chance_critique(stats, arme, config, bonus)
	var degats := degats_coup(niveau, stats, arme, config, degats_arme_objet, bonus)
	if critique:
		degats *= multiplicateur_critique(arme, bonus)
	var defense := defense_cible * (1.0 - float(arme.get("ignore_defense", 0.0)))
	degats *= 1.0 - reduction(defense, niveau, config)
	return {"degats": maxi(1, roundi(degats)), "critique": critique}


## Le bouclier bloque-t-il ce coup ?
static func bloque(arme: Dictionary, hasard: RandomNumberGenerator) -> bool:
	return hasard.randf() < float(arme.get("chance_blocage", 0.0))
