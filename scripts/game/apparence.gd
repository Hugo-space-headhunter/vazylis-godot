class_name Apparence
extends RefCounted
## L'apparence du personnage, indépendante de l'équipement : coiffure, barbe et couleur des cheveux.
## Ce sont des rangs dans les listes de config/personnage.cfg [apparence] (une liste pour l'homme,
## une pour la femme). Elle est enregistrée avec la partie.

signal change

var coiffure := 0
var barbe := 0
var couleur := 0


## Passe au choix suivant pour « champ » (« coiffure », « barbe » ou « couleur »), en revenant au premier.
func suivante(champ: String, config: ConfigJeu, femme: bool) -> void:
	var nombre := config.liste_apparence(_liste(champ), femme).size()
	if nombre <= 0:
		return
	set(champ, (int(get(champ)) + 1) % nombre)
	change.emit()


## Identifiant de la coiffure (catalogue d'assets), ou "" pour aucune.
func id_coiffure(config: ConfigJeu, femme: bool) -> String:
	return _choix(config.liste_apparence("coiffures", femme), coiffure)


## Identifiant de la barbe, ou "" pour aucune (la femme n'en a pas dans sa liste).
func id_barbe(config: ConfigJeu, femme: bool) -> String:
	return _choix(config.liste_apparence("barbes", femme), barbe)


func id_sourcils(config: ConfigJeu, femme: bool) -> String:
	return _choix(config.liste_apparence("sourcils", femme), 0)


func couleur_cheveux(config: ConfigJeu) -> Color:
	var couleurs := config.liste_apparence("couleurs_cheveux", false)
	return couleurs[couleur % couleurs.size()] if not couleurs.is_empty() else Color.WHITE


func vers_dictionnaire() -> Dictionary:
	return {"coiffure": coiffure, "barbe": barbe, "couleur": couleur}


static func depuis_dictionnaire(donnees: Variant) -> Apparence:
	var apparence := Apparence.new()
	if donnees is Dictionary:
		apparence.coiffure = maxi(0, int(donnees.get("coiffure", 0)))
		apparence.barbe = maxi(0, int(donnees.get("barbe", 0)))
		apparence.couleur = maxi(0, int(donnees.get("couleur", 0)))
	return apparence


static func _liste(champ: String) -> String:
	return {"coiffure": "coiffures", "barbe": "barbes", "couleur": "couleurs_cheveux"}.get(champ, champ)


static func _choix(liste: Array, rang: int) -> String:
	return str(liste[rang % liste.size()]) if not liste.is_empty() else ""
