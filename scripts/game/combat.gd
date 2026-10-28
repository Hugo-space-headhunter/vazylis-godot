class_name Combat
extends RefCounted
## Formules de combat de l'étape 2 (sans points de statistiques, qui arrivent à l'étape 3).


## Dégâts de l'arme de départ : (base + par_niveau × niveau) × multiplicateur de rareté.
static func degats_arme(niveau: int, config: ConfigJeu) -> float:
	var brut := config.combat("arme_depart", "degats_base") + config.combat("arme_depart", "degats_par_niveau") * niveau
	return brut * config.multiplicateur_rarete(config.rarete_arme_depart())


## Points de vie maximum du joueur.
static func pv_joueur(niveau: int, config: ConfigJeu) -> float:
	return config.combat("joueur", "pv_base") + config.combat("joueur", "pv_par_niveau") * niveau


## Secondes entre deux coups du joueur.
static func intervalle_attaque_joueur(config: ConfigJeu) -> float:
	return 1.0 / config.combat("arme_depart", "vitesse")


## Dégâts moyens par seconde d'un joueur de ce niveau, critiques compris.
static func dps_joueur(niveau: int, config: ConfigJeu) -> float:
	var bonus_critique := config.combat("critique", "chance") * (config.combat("critique", "multiplicateur") - 1.0)
	return degats_arme(niveau, config) * config.combat("arme_depart", "vitesse") * (1.0 + bonus_critique)


## Points de vie d'un monstre : on le tue en environ 10 secondes à niveau égal.
static func pv_monstre(niveau: int, config: ConfigJeu) -> float:
	return dps_joueur(niveau, config) * config.combat("calibrage", "secondes_pour_tuer_un_monstre")


## Dégâts d'une attaque de monstre : il tue un joueur de son niveau en environ 60 secondes.
static func degats_monstre(niveau_monstre: int, niveau_joueur: int, passif: bool,
		intervalle_attaque: float, config: ConfigJeu) -> float:
	var dps := pv_joueur(niveau_monstre, config) / config.combat("calibrage", "secondes_pour_etre_tue")
	var degats := dps * intervalle_attaque
	if passif:
		degats *= config.combat("calibrage", "multiplicateur_passifs")
	var ecart := niveau_monstre - niveau_joueur - int(config.combat("calibrage", "ecart_sans_bonus"))
	if ecart > 0:
		degats *= 1.0 + config.combat("calibrage", "bonus_par_niveau") * ecart
	return degats


## Un coup du joueur : renvoie {"degats": int, "critique": bool}.
static func coup_joueur(niveau: int, config: ConfigJeu, hasard: RandomNumberGenerator) -> Dictionary:
	var critique := hasard.randf() < config.combat("critique", "chance")
	var degats := degats_arme(niveau, config)
	if critique:
		degats *= config.combat("critique", "multiplicateur")
	return {"degats": maxi(1, roundi(degats)), "critique": critique}
