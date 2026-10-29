class_name Equipement
extends RefCounted
## Les objets portés par le personnage, emplacement par emplacement.
## Pour le prototype, un seul emplacement « arme » couvre les deux mains
## (une paire de dagues, une épée et son écu, une arme à deux mains…).

signal change

const EMPLACEMENTS: PackedStringArray = [
	"arme", "casque", "plastron", "gants", "bottes", "ceinture", "cape",
	"collier", "boucle_oreille_1", "boucle_oreille_2",
]
## Emplacements prévus par le game design mais encore vides (familier à l'étape 8, les autres plus tard).
const EMPLACEMENTS_A_VENIR: PackedStringArray = ["familier", "etendard", "accessoire"]
const NOMS := {
	"arme": "Arme", "casque": "Casque", "plastron": "Plastron", "gants": "Gants", "bottes": "Bottes",
	"ceinture": "Ceinture", "cape": "Cape", "collier": "Collier", "boucle_oreille_1": "Boucle",
	"boucle_oreille_2": "Boucle", "familier": "Familier", "etendard": "Étendard", "accessoire": "Accessoire",
}

var objets := {}


func objet(emplacement: String) -> Objet:
	return objets.get(emplacement, null)


func arme() -> Objet:
	return objet("arme")


## Emplacement où irait cet objet (une boucle d'oreille prend la première oreille libre).
func emplacement_pour(un_objet: Objet) -> String:
	if un_objet.emplacement == "boucle_oreille":
		return "boucle_oreille_2" if objet("boucle_oreille_1") != null and objet("boucle_oreille_2") == null else "boucle_oreille_1"
	return un_objet.emplacement


## Vrai si l'objet peut aller dans cet emplacement.
func accepte(emplacement: String, un_objet: Objet) -> bool:
	if un_objet == null:
		return false
	if emplacement.begins_with("boucle_oreille"):
		return un_objet.emplacement == "boucle_oreille"
	return un_objet.emplacement == emplacement


## Porte l'objet. Renvoie l'objet qui était porté à cet endroit (à remettre dans le sac), ou null.
func equiper(un_objet: Objet, emplacement: String = "") -> Objet:
	if emplacement.is_empty():
		emplacement = emplacement_pour(un_objet)
	if not accepte(emplacement, un_objet):
		push_error("Equipement : « %s » ne va pas dans l'emplacement « %s »." % [un_objet.nom, emplacement])
		return un_objet
	var ancien := objet(emplacement)
	objets[emplacement] = un_objet
	change.emit()
	return ancien


func retirer(emplacement: String) -> Objet:
	var ancien := objet(emplacement)
	objets.erase(emplacement)
	if ancien != null:
		change.emit()
	return ancien


func armure_totale() -> float:
	var total := 0.0
	for un_objet: Objet in objets.values():
		total += un_objet.armure
	return total


## Statistiques données par tous les objets portés : {"force": 12, …}
func statistiques_totales() -> Dictionary:
	var total := {}
	for un_objet: Objet in objets.values():
		for nom: String in un_objet.statistiques:
			total[nom] = int(total.get(nom, 0)) + int(un_objet.statistiques[nom])
	return total


## Bonus en % de tous les objets portés, additionnés : {"vitesse_attaque": 0.05, …}
func bonus_totaux() -> Dictionary:
	var total := {}
	for un_objet: Objet in objets.values():
		for nom: String in un_objet.bonus:
			total[nom] = float(total.get(nom, 0.0)) + float(un_objet.bonus[nom])
	return total


func vers_dictionnaire() -> Dictionary:
	var donnees := {}
	for emplacement: String in objets:
		donnees[emplacement] = (objets[emplacement] as Objet).vers_dictionnaire()
	return donnees


static func depuis_dictionnaire(donnees: Dictionary, config: ConfigJeu) -> Equipement:
	var equipement := Equipement.new()
	for emplacement: String in donnees:
		equipement.objets[emplacement] = Objet.depuis_dictionnaire(donnees[emplacement], config)
	return equipement
