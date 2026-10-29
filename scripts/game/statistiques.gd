class_name Statistiques
extends RefCounted
## Les 4 statistiques du personnage et les points à répartir.
##
## Les points s'ajoutent d'abord « en attente » (boutons + et −), puis deviennent
## définitifs quand on valide. Seul un parchemin de réinitialisation (plus tard) pourra les rendre.

signal change

const NOMS: PackedStringArray = ["force", "agilite", "vitalite", "intelligence"]
const NOMS_AFFICHES := {
	"force": "Force",
	"agilite": "Agilité",
	"vitalite": "Vitalité",
	"intelligence": "Intelligence",
}

## Points validés, définitifs.
var valeurs := {"force": 0, "agilite": 0, "vitalite": 0, "intelligence": 0}
## Points ajoutés mais pas encore validés.
var en_attente := {"force": 0, "agilite": 0, "vitalite": 0, "intelligence": 0}
## Points gagnés et pas encore validés (en attente compris).
var points_libres := 0


## Statistiques du joueur « moyen » qui sert à régler les monstres.
static func joueur_moyen(niveau: int, config: ConfigJeu) -> Statistiques:
	var stats := Statistiques.new()
	var par_stat := int(config.combat("calibrage", "points_par_statistique_par_niveau")) * (niveau - 1)
	for nom in NOMS:
		stats.valeurs[nom] = par_stat
	return stats


## Valeur validée d'une statistique.
func valeur(nom: String) -> int:
	return int(valeurs.get(nom, 0))


## Valeur en comptant les points en attente.
func valeur_apercu(nom: String) -> int:
	return valeur(nom) + int(en_attente.get(nom, 0))


func points_restants() -> int:
	var places := 0
	for nom in NOMS:
		places += int(en_attente[nom])
	return points_libres - places


func a_des_points_en_attente() -> bool:
	return points_restants() != points_libres


func gagner_points(nombre: int) -> void:
	points_libres += nombre
	change.emit()


## Bouton + : met un point en attente. Renvoie faux s'il ne reste plus de point.
func ajouter(nom: String) -> bool:
	if not nom in NOMS or points_restants() <= 0:
		return false
	en_attente[nom] += 1
	change.emit()
	return true


## Bouton − : retire un point en attente (jamais un point déjà validé).
func retirer(nom: String) -> bool:
	if not nom in NOMS or int(en_attente[nom]) <= 0:
		return false
	en_attente[nom] -= 1
	change.emit()
	return true


## Rend définitifs les points en attente.
func valider() -> void:
	for nom in NOMS:
		valeurs[nom] += int(en_attente[nom])
		points_libres -= int(en_attente[nom])
		en_attente[nom] = 0
	change.emit()


## Abandonne les points en attente.
func annuler() -> void:
	for nom in NOMS:
		en_attente[nom] = 0
	change.emit()


## Copie avec des points en plus (par exemple ceux des objets portés : {"force": 12, …}).
func avec_bonus(supplement: Dictionary) -> Statistiques:
	var copie := Statistiques.new()
	for nom in NOMS:
		copie.valeurs[nom] = valeur(nom) + int(supplement.get(nom, 0))
	return copie


## Copie où les points en attente sont considérés comme validés (pour l'aperçu).
func apercu() -> Statistiques:
	var copie := Statistiques.new()
	for nom in NOMS:
		copie.valeurs[nom] = valeur_apercu(nom)
	return copie
