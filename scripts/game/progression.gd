class_name Progression
extends RefCounted
## Formules de progression du personnage (temps cible et XP par niveau).


## Temps de jeu visé pour passer le niveau indiqué, en minutes :
## t(L) = base + coefficient × L ^ exposant.
static func minutes_cibles(niveau: int, config: ConfigJeu) -> float:
	return config.temps_cible_base() + config.temps_cible_coefficient() * pow(niveau, config.temps_cible_exposant())


## Temps de jeu cumulé, en minutes, pour passer tous les niveaux de 1 à niveau_final.
static func minutes_cumulees(niveau_final: int, config: ConfigJeu) -> float:
	var total := 0.0
	for niveau in range(1, niveau_final + 1):
		total += minutes_cibles(niveau, config)
	return total


## XP requise pour passer un niveau :
## temps cible × monstres tués par minute × XP de base d'un monstre de ce niveau.
static func xp_requise(niveau: int, xp_base_monstre: float, config: ConfigJeu) -> int:
	return roundi(minutes_cibles(niveau, config) * config.monstres_par_minute() * xp_base_monstre)
