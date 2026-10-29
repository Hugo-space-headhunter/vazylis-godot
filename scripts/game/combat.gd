class_name Combat
extends RefCounted
## Formules de combat (docs/game-design.md, « Formules de combat »).
## « arme » est une section de config/armes.cfg (voir ConfigJeu.arme).


## Dégâts de l'arme : (base + par_niveau × niveau) × rareté × multiplicateur du type d'arme.
static func degats_arme(niveau: int, arme: Dictionary, config: ConfigJeu) -> float:
	var brut := config.combat("arme", "degats_base") + config.combat("arme", "degats_par_niveau") * niveau
	return brut * config.multiplicateur_rarete(config.rarete_arme()) * float(arme.get("multiplicateur_degats", 1.0))


## Dégâts d'un coup normal : (arme + 2 × Force) × (1 + 0,3 % × statistique d'affinité).
static func degats_coup(niveau: int, stats: Statistiques, arme: Dictionary, config: ConfigJeu) -> float:
	var force := stats.valeur("force") * config.statistique("force", "degats_par_point")
	var affinite := stats.valeur(str(arme.get("affinite", "force"))) * config.statistique("affinite", "bonus_par_point")
	return (degats_arme(niveau, arme, config) + force) * (1.0 + affinite)


## Chance de coup critique (0 à 1), plafonnée.
static func chance_critique(stats: Statistiques, arme: Dictionary, config: ConfigJeu) -> float:
	var chance := config.combat("critique", "chance") \
		+ stats.valeur("agilite") * config.statistique("agilite", "critique_par_point") \
		+ float(arme.get("bonus_critique", 0.0))
	return minf(chance, config.statistique("plafonds", "critique_max"))


static func multiplicateur_critique(arme: Dictionary) -> float:
	return float(arme.get("multiplicateur_critique", 1.5))


## Coups par seconde : vitesse de l'arme × (1 + 0,4 % × Agilité), au plus ×2,5.
static func vitesse_attaque(stats: Statistiques, arme: Dictionary, config: ConfigJeu) -> float:
	var bonus := 1.0 + stats.valeur("agilite") * config.statistique("agilite", "vitesse_par_point")
	return float(arme.get("vitesse", 1.0)) * minf(bonus, config.statistique("plafonds", "vitesse_max"))


## Points de vie : base + par niveau + 12 × Vitalité.
static func pv_joueur(niveau: int, stats: Statistiques, config: ConfigJeu) -> float:
	return config.combat("joueur", "pv_base") + config.combat("joueur", "pv_par_niveau") * niveau \
		+ stats.valeur("vitalite") * config.statistique("vitalite", "pv_par_point")


## Défense : bouclier (par niveau) + 0,5 × Vitalité (l'armure des items arrivera à l'étape 4).
static func defense_joueur(niveau: int, stats: Statistiques, arme: Dictionary, config: ConfigJeu) -> float:
	return float(arme.get("defense_par_niveau", 0.0)) * niveau \
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
static func dps(niveau: int, stats: Statistiques, arme: Dictionary, config: ConfigJeu) -> float:
	var bonus_critique := chance_critique(stats, arme, config) * (multiplicateur_critique(arme) - 1.0)
	return degats_coup(niveau, stats, arme, config) * vitesse_attaque(stats, arme, config) * (1.0 + bonus_critique)


## Points de vie d'un monstre : le joueur « moyen » de son niveau le tue en environ 10 secondes.
static func pv_monstre(niveau: int, config: ConfigJeu) -> float:
	var arme := config.arme(config.arme_reference())
	return dps(niveau, Statistiques.joueur_moyen(niveau, config), arme, config) \
		* config.combat("calibrage", "secondes_pour_tuer_un_monstre")


## Dégâts bruts d'une attaque de monstre (avant la défense du joueur) : il tue le joueur
## « moyen » de son niveau, défense comprise, en environ 60 secondes.
static func degats_monstre(niveau_monstre: int, niveau_joueur: int, passif: bool,
		intervalle_attaque: float, config: ConfigJeu) -> float:
	var stats := Statistiques.joueur_moyen(niveau_monstre, config)
	var arme := config.arme(config.arme_reference())
	var protection := 1.0 - reduction(defense_joueur(niveau_monstre, stats, arme, config), niveau_monstre, config)
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
		niveau_cible: int, config: ConfigJeu, hasard: RandomNumberGenerator) -> Dictionary:
	var critique := hasard.randf() < chance_critique(stats, arme, config)
	var degats := degats_coup(niveau, stats, arme, config)
	if critique:
		degats *= multiplicateur_critique(arme)
	var defense := defense_cible * (1.0 - float(arme.get("ignore_defense", 0.0)))
	degats *= 1.0 - reduction(defense, niveau, config)
	return {"degats": maxi(1, roundi(degats)), "critique": critique}


## Le bouclier bloque-t-il ce coup ?
static func bloque(arme: Dictionary, hasard: RandomNumberGenerator) -> bool:
	return hasard.randf() < float(arme.get("chance_blocage", 0.0))
