class_name RecyclageAuto
extends RefCounted
## Recyclage automatique par filtres : un objet qui tombe est recyclé tout de suite (en or)
## s'il est sous la rareté choisie et de l'un des types cochés. Évite que le sac se remplisse.

signal change

const TYPES: PackedStringArray = ["arme", "armure", "bijou"]
const NOMS_TYPES := {"arme": "Armes", "armure": "Armures", "bijou": "Bijoux"}

var actif := false
## On recycle ce qui est strictement en dessous de cette rareté (ex. « dore » : standard et argenté).
var rarete_limite := "dore"
var types := {"arme": true, "armure": true, "bijou": true}


static func type_de(objet: Objet) -> String:
	if objet.est_arme():
		return "arme"
	return "bijou" if objet.est_bijou() else "armure"


func doit_recycler(objet: Objet, config: ConfigJeu) -> bool:
	if not actif or not bool(types.get(type_de(objet), false)):
		return false
	var ordre := config.ids_raretes()
	return ordre.find(objet.rarete) < ordre.find(rarete_limite)


func regler(nouvel_actif: bool, nouvelle_limite: String) -> void:
	actif = nouvel_actif
	rarete_limite = nouvelle_limite
	change.emit()


func cocher(type: String, coche: bool) -> void:
	types[type] = coche
	change.emit()


func vers_dictionnaire() -> Dictionary:
	return {"actif": actif, "rarete_limite": rarete_limite, "types": types}


static func depuis_dictionnaire(donnees: Dictionary) -> RecyclageAuto:
	var filtre := RecyclageAuto.new()
	filtre.actif = bool(donnees.get("actif", false))
	filtre.rarete_limite = str(donnees.get("rarete_limite", "dore"))
	filtre.types = donnees.get("types", filtre.types)
	return filtre
