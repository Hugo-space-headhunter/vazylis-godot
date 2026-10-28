class_name PuissanceItem
extends RefCounted
## Puissance d'un item : niveau × multiplicateur de rareté, plus le bonus d'amélioration.
##
## Le bonus apporté par chaque palier d'amélioration (+1 à +10) sera défini
## à l'étape 7 (la forge) ; il est passé tel quel en attendant.


## Puissance arrondie à l'entier inférieur, comme dans le game design
## (exemple : un épique niveau 110 vaut 192).
static func calculer(niveau: int, rarete: String, config: ConfigJeu, bonus_amelioration: int = 0) -> int:
	if not config.a_rarete(rarete):
		push_error("PuissanceItem : rareté inconnue « %s »." % rarete)
		return 0
	return floori(niveau * config.multiplicateur_rarete(rarete)) + bonus_amelioration
