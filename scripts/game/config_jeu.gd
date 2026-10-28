class_name ConfigJeu
extends RefCounted
## Valeurs d'équilibrage lues dans les fichiers du dossier config/.
##
## Classe indépendante des nœuds : les tests automatiques l'utilisent
## directement, et l'autoload « Config » en garde un exemplaire pour le jeu.

const DOSSIER_PAR_DEFAUT := "res://config"

var _raretes := ConfigFile.new()
var _amelioration := ConfigFile.new()
var _progression := ConfigFile.new()


## Lit tous les fichiers de configuration du dossier indiqué.
static func charger(dossier: String = DOSSIER_PAR_DEFAUT) -> ConfigJeu:
	var config := ConfigJeu.new()
	config._raretes = _lire(dossier.path_join("raretes.cfg"))
	config._amelioration = _lire(dossier.path_join("amelioration.cfg"))
	config._progression = _lire(dossier.path_join("progression.cfg"))
	return config


# --- Raretés ---

func ids_raretes() -> PackedStringArray:
	return PackedStringArray(_raretes.get_value("raretes", "ordre", []))


func a_rarete(id: String) -> bool:
	return id in ids_raretes() and _raretes.has_section(id)


func nom_rarete(id: String) -> String:
	return str(_valeur(_raretes, id, "nom", id))


func multiplicateur_rarete(id: String) -> float:
	return float(_valeur(_raretes, id, "multiplicateur", 1.0))


func bonus_pourcent_rarete(id: String) -> int:
	return int(_valeur(_raretes, id, "bonus_pourcent", 0))


# --- Amélioration ---

func palier_max_amelioration() -> int:
	return int(_valeur(_amelioration, "amelioration", "palier_max", 10))


## Chance (0 à 1) de réussir l'amélioration vers le palier indiqué (+1 à +10).
func taux_reussite_amelioration(palier: int) -> float:
	return float(_valeur(_amelioration, "reussite", "plus_%d" % palier, 0.0))


# --- Progression ---

func temps_cible_base() -> float:
	return float(_valeur(_progression, "temps_cible", "base_minutes", 0.0))


func temps_cible_coefficient() -> float:
	return float(_valeur(_progression, "temps_cible", "coefficient", 0.0))


func temps_cible_exposant() -> float:
	return float(_valeur(_progression, "temps_cible", "exposant", 1.0))


func monstres_par_minute() -> float:
	return float(_valeur(_progression, "farm", "monstres_par_minute", 0.0))


# --- Outils internes ---

static func _lire(chemin: String) -> ConfigFile:
	var fichier := ConfigFile.new()
	var erreur := fichier.load(chemin)
	if erreur != OK:
		push_error("Config : impossible de lire %s (erreur %d)." % [chemin, erreur])
	return fichier


static func _valeur(fichier: ConfigFile, section: String, cle: String, defaut: Variant) -> Variant:
	if not fichier.has_section_key(section, cle):
		push_error("Config : valeur manquante [%s] %s, valeur par défaut utilisée." % [section, cle])
		return defaut
	return fichier.get_value(section, cle)
