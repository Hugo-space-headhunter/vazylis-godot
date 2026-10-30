class_name Forge
extends RefCounted
## La forge : améliorer un objet de +1 à +10 en payant des matériaux et de l'or (config/amelioration.cfg).
## Un échec fait perdre ce qui a été payé, jamais le niveau d'amélioration.

enum Resultat { REUSSITE, ECHEC, IMPOSSIBLE }

var _config: ConfigJeu


func _init(config: ConfigJeu) -> void:
	_config = config


func palier_max() -> int:
	return _config.palier_max_amelioration()


func est_au_maximum(objet: Objet) -> bool:
	return objet.amelioration >= palier_max()


## Chance de réussir le prochain palier (0 à 1).
func chance(objet: Objet) -> float:
	return _config.taux_reussite_amelioration(objet.amelioration + 1)


## Ce que coûte la tentative du prochain palier : {"ressource": id, "quantite": n, "or": n}.
func cout(objet: Objet) -> Dictionary:
	var palier := objet.amelioration + 1
	var quantite := ceili((_config.amelioration("cout", "materiaux_base") + palier)
		* (1.0 + objet.niveau * _config.amelioration("cout", "materiaux_par_niveau")) - 0.0001)
	var prix := roundi(palier * _config.amelioration("cout", "or_par_palier") * objet.puissance_de_depart(_config))
	return {"ressource": objet.materiau(_config), "quantite": quantite, "or": prix}


## Peut-on payer la tentative ? (et l'objet n'est pas déjà au maximum)
func peut_payer(objet: Objet, inventaire: Inventaire) -> bool:
	if est_au_maximum(objet):
		return false
	var prix := cout(objet)
	return inventaire.quantite(prix["ressource"]) >= int(prix["quantite"]) and inventaire.or_possede >= int(prix["or"])


## Tente d'améliorer l'objet : paie, puis réussit selon la chance du palier.
func ameliorer(objet: Objet, inventaire: Inventaire, hasard: RandomNumberGenerator) -> Resultat:
	if not peut_payer(objet, inventaire):
		return Resultat.IMPOSSIBLE
	var prix := cout(objet)
	inventaire.payer(prix["ressource"], int(prix["quantite"]), int(prix["or"]))
	if hasard.randf() >= chance(objet):
		return Resultat.ECHEC
	objet.amelioration += 1
	objet.appliquer_amelioration(_config)
	inventaire.change.emit()
	return Resultat.REUSSITE
