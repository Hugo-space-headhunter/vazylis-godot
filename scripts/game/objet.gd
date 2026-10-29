class_name Objet
extends RefCounted
## Un objet tombé d'un monstre (arme, armure ou bijou), avec ses valeurs tirées au hasard.
## Classe indépendante de l'affichage ; elle se transforme en dictionnaire pour la sauvegarde.

const EMPLACEMENTS_BIJOUX: PackedStringArray = ["collier", "boucle_oreille"]
const NOMS_BONUS := {
	"vitesse_attaque": "vitesse d'attaque",
	"chance_critique": "chance de critique",
	"degats_critiques": "dégâts critiques",
	"vie": "vie",
	"degats": "dégâts",
}

static var _compteur := 0

## Numéro unique de l'objet.
var numero := 0
## Famille de l'objet (section de config/objets.cfg, ex. « objet.hache_bucheron »).
var famille := ""
var nom := ""
var emplacement := ""
var type_arme := ""
var niveau := 1
var rarete := "standard"
## Moyenne des tirages, de 0,7 à 1 (1 = objet parfait).
var qualite := 1.0
## Dégâts (arme) ou armure (armure), selon l'objet.
var degats := 0.0
var armure := 0.0
## Statistiques données : {"force": 12, …}
var statistiques := {}
## Bonus en % : {"vitesse_attaque": 0.03, …}
var bonus := {}


func _init() -> void:
	_compteur += 1
	numero = _compteur


func est_arme() -> bool:
	return emplacement == "arme"


func est_bijou() -> bool:
	return emplacement in EMPLACEMENTS_BIJOUX


## Puissance : niveau × multiplicateur de rareté (les améliorations viendront à l'étape 7).
func puissance(config: ConfigJeu) -> int:
	return PuissanceItem.calculer(niveau, rarete, config)


## Identifiant du modèle 3D qui représente l'objet (pour sa vignette ou sur le sol).
func modele(config: ConfigJeu, femme: bool = false) -> String:
	var definition := config.famille_objet(famille)
	if est_arme():
		var droite := str(definition.get("modele_main_droite", ""))
		return droite if not droite.is_empty() else str(definition.get("modele_main_gauche", ""))
	return str(definition.get("modele_femme" if femme else "modele_homme", ""))


func vers_dictionnaire() -> Dictionary:
	return {
		"famille": famille, "niveau": niveau, "rarete": rarete, "qualite": qualite,
		"degats": degats, "armure": armure, "statistiques": statistiques, "bonus": bonus,
	}


static func depuis_dictionnaire(donnees: Dictionary, config: ConfigJeu) -> Objet:
	var objet := Objet.new()
	objet.famille = str(donnees.get("famille", ""))
	var definition := config.famille_objet(objet.famille)
	objet.nom = str(definition.get("nom", objet.famille))
	objet.emplacement = str(definition.get("emplacement", ""))
	objet.type_arme = str(definition.get("type_arme", ""))
	objet.niveau = int(donnees.get("niveau", 1))
	objet.rarete = str(donnees.get("rarete", "standard"))
	objet.qualite = float(donnees.get("qualite", 1.0))
	objet.degats = float(donnees.get("degats", 0.0))
	objet.armure = float(donnees.get("armure", 0.0))
	objet.statistiques = donnees.get("statistiques", {})
	objet.bonus = donnees.get("bonus", {})
	return objet
