class_name Partie
extends RefCounted
## Tout ce qui doit survivre à une fermeture de l'application, mis en forme pour être sauvegardé
## (dictionnaire simple, transformable en texte JSON). Indépendant des fichiers et d'Internet.
##
## Le numéro de version permettra de faire évoluer la sauvegarde sans perdre les parties :
## une sauvegarde d'une version inconnue n'est pas chargée.

const VERSION := 1

var personnage := ""
var niveau := 1
var xp := 0
var statistiques := Statistiques.new()
var inventaire: Inventaire
var equipement := Equipement.new()
var recyclage_auto := RecyclageAuto.new()
var monstres_sans_dore := 0
var monstres_sans_epique := 0
var victoires_sans_epique := {}
## Moment de la sauvegarde (secondes depuis 1970), pour garder la plus récente.
var sauvegarde_le := 0.0


func vers_dictionnaire() -> Dictionary:
	var cases := []
	for objet in inventaire.cases:
		cases.append(objet.vers_dictionnaire() if objet != null else null)
	return {
		"version": VERSION,
		"sauvegarde_le": sauvegarde_le,
		"personnage": personnage,
		"niveau": niveau,
		"xp": xp,
		"statistiques": {"valeurs": statistiques.valeurs, "points_libres": statistiques.points_libres},
		"sac": {"cases": cases, "or": inventaire.or_possede, "ressources": inventaire.ressources},
		"equipement": equipement.vers_dictionnaire(),
		"recyclage_auto": recyclage_auto.vers_dictionnaire(),
		"garantie": {"monstres_sans_dore": monstres_sans_dore, "monstres_sans_epique": monstres_sans_epique,
			"victoires_sans_epique": victoires_sans_epique},
	}


## Relit une partie sauvegardée. Renvoie null si la sauvegarde est vide ou d'une version inconnue.
static func depuis_dictionnaire(donnees: Variant, config: ConfigJeu) -> Partie:
	if not donnees is Dictionary or int(donnees.get("version", 0)) != VERSION:
		return null
	var partie := Partie.new()
	partie.sauvegarde_le = float(donnees.get("sauvegarde_le", 0.0))
	partie.personnage = str(donnees.get("personnage", ""))
	partie.niveau = maxi(1, int(donnees.get("niveau", 1)))
	partie.xp = maxi(0, int(donnees.get("xp", 0)))

	var stats: Dictionary = donnees.get("statistiques", {})
	var valeurs: Dictionary = stats.get("valeurs", {})
	for nom in Statistiques.NOMS:
		partie.statistiques.valeurs[nom] = int(valeurs.get(nom, 0))
	partie.statistiques.points_libres = int(stats.get("points_libres", 0))

	partie.inventaire = Inventaire.new(config)
	var sac: Dictionary = donnees.get("sac", {})
	var cases: Array = sac.get("cases", [])
	for i in mini(cases.size(), partie.inventaire.nombre_cases()):
		partie.inventaire.cases[i] = _objet_valide(cases[i], config)
	partie.inventaire.or_possede = int(sac.get("or", 0))
	var ressources: Dictionary = sac.get("ressources", {})
	for id: String in ressources:
		if id in config.ids_ressources():
			partie.inventaire.ressources[id] = int(ressources[id])

	var equipement: Dictionary = donnees.get("equipement", {})
	for emplacement: String in equipement:
		var objet := _objet_valide(equipement[emplacement], config)
		if objet != null and emplacement in Equipement.EMPLACEMENTS:
			partie.equipement.objets[emplacement] = objet

	partie.recyclage_auto = RecyclageAuto.depuis_dictionnaire(donnees.get("recyclage_auto", {}))
	var garantie: Dictionary = donnees.get("garantie", {})
	partie.monstres_sans_dore = int(garantie.get("monstres_sans_dore", 0))
	partie.monstres_sans_epique = int(garantie.get("monstres_sans_epique", 0))
	var victoires: Dictionary = garantie.get("victoires_sans_epique", {})
	for id: String in victoires:
		partie.victoires_sans_epique[id] = int(victoires[id])
	return partie


## Un objet dont la famille n'existe plus (retirée de objets.cfg) est ignoré au lieu de casser la partie.
static func _objet_valide(donnees: Variant, config: ConfigJeu) -> Objet:
	if not donnees is Dictionary:
		return null
	if not str(donnees.get("famille", "")) in config.ids_familles_objets():
		push_warning("Sauvegarde : objet inconnu « %s » ignoré." % donnees.get("famille", ""))
		return null
	return Objet.depuis_dictionnaire(donnees, config)
