class_name RecyclageAuto
extends RefCounted
## Recyclage automatique par filtres : un objet qui tombe est recyclé tout de suite (en or et en
## matériaux) s'il est sous la rareté choisie, de l'un des types cochés et de l'un des matériaux cochés.
## Évite que le sac se remplisse.

signal change

const TYPES: PackedStringArray = ["arme", "armure", "bijou"]
const NOMS_TYPES := {"arme": "Armes", "armure": "Armures", "bijou": "Bijoux"}

var actif := false
## On recycle ce qui est strictement en dessous de cette rareté (ex. « dore » : standard et argenté).
var rarete_limite := "dore"
var types := {"arme": true, "armure": true, "bijou": true}
## Matériaux cochés (« tout ce qui est en fer ») ; un matériau absent compte comme coché.
var materiaux := {}


static func type_de(objet: Objet) -> String:
	if objet.est_arme():
		return "arme"
	return "bijou" if objet.est_bijou() else "armure"


func doit_recycler(objet: Objet, config: ConfigJeu) -> bool:
	if not actif or not bool(types.get(type_de(objet), false)) or not bool(materiaux.get(objet.materiau(config), true)):
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


func cocher_materiau(id_ressource: String, coche: bool) -> void:
	materiaux[id_ressource] = coche
	change.emit()


func vers_dictionnaire() -> Dictionary:
	return {"actif": actif, "rarete_limite": rarete_limite, "types": types, "materiaux": materiaux}


static func depuis_dictionnaire(donnees: Dictionary) -> RecyclageAuto:
	var filtre := RecyclageAuto.new()
	filtre.actif = bool(donnees.get("actif", false))
	filtre.rarete_limite = str(donnees.get("rarete_limite", "dore"))
	filtre.types = donnees.get("types", filtre.types)
	filtre.materiaux = donnees.get("materiaux", {})
	return filtre
