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
## Palier d'amélioration à la forge (0 à 10). Il augmente les dégâts, l'armure et les statistiques.
var amelioration := 0
## Dégâts, armure et statistiques de départ (avant amélioration) : {"degats": …, "armure": …, "statistiques": {…}}.
var _depart := {}


func _init() -> void:
	_compteur += 1
	numero = _compteur


func est_arme() -> bool:
	return emplacement == "arme"


func est_bijou() -> bool:
	return emplacement in EMPLACEMENTS_BIJOUX


## Puissance : niveau × multiplicateur de rareté, plus le bonus de son amélioration à la forge.
func puissance(config: ConfigJeu) -> int:
	var depart := puissance_de_depart(config)
	return PuissanceItem.calculer(niveau, rarete, config, floori(depart * (config.multiplicateur_amelioration(amelioration) - 1.0) + 0.0001))


## Puissance sans l'amélioration.
func puissance_de_depart(config: ConfigJeu) -> int:
	return PuissanceItem.calculer(niveau, rarete, config)


## Nom affiché, avec le palier d'amélioration (« Lame du Guet +7 »).
func nom_affiche() -> String:
	return nom if amelioration <= 0 else "%s +%d" % [nom, amelioration]


## Matériau qui sert à l'améliorer et qu'il rend au recyclage (fer, chêne, cuir…).
func materiau(config: ConfigJeu) -> String:
	return config.materiau_amelioration(emplacement, type_arme)


## Retient les valeurs actuelles comme valeurs de départ (à l'objet neuf, avant toute amélioration).
func fixer_depart() -> void:
	_depart = {"degats": degats, "armure": armure, "statistiques": statistiques.duplicate()}


## Recalcule dégâts, armure et statistiques d'après les valeurs de départ et le palier.
func appliquer_amelioration(config: ConfigJeu) -> void:
	if _depart.is_empty():
		fixer_depart()
	var facteur := config.multiplicateur_amelioration(amelioration)
	degats = float(_depart["degats"]) * facteur
	armure = float(_depart["armure"]) * facteur
	var depart_stats: Dictionary = _depart["statistiques"]
	for nom_stat: String in depart_stats:
		statistiques[nom_stat] = roundi(int(depart_stats[nom_stat]) * facteur)


## Identifiant du modèle 3D qui représente l'objet (pour sa vignette ou sur le sol).
func modele(config: ConfigJeu, femme: bool = false) -> String:
	var definition := config.famille_objet(famille)
	if est_arme():
		var droite := str(definition.get("modele_main_droite", ""))
		return droite if not droite.is_empty() else str(definition.get("modele_main_gauche", ""))
	return str(definition.get("modele_femme" if femme else "modele_homme", ""))


## Pour la sauvegarde : les valeurs de départ et le palier (les valeurs améliorées se recalculent).
func vers_dictionnaire() -> Dictionary:
	if _depart.is_empty():
		fixer_depart()
	return {
		"famille": famille, "niveau": niveau, "rarete": rarete, "qualite": qualite,
		"degats": _depart["degats"], "armure": _depart["armure"], "statistiques": _depart["statistiques"], "bonus": bonus,
		"amelioration": amelioration,
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
	# Le texte JSON ne distingue pas les entiers des décimaux : les statistiques redeviennent entières.
	var statistiques: Dictionary = donnees.get("statistiques", {})
	for nom: String in statistiques:
		objet.statistiques[nom] = int(statistiques[nom])
	var bonus: Dictionary = donnees.get("bonus", {})
	for nom: String in bonus:
		objet.bonus[nom] = float(bonus[nom])
	objet.fixer_depart()
	objet.amelioration = clampi(int(donnees.get("amelioration", 0)), 0, config.palier_max_amelioration())
	objet.appliquer_amelioration(config)
	return objet
