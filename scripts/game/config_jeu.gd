class_name ConfigJeu
extends RefCounted
## Valeurs d'équilibrage lues dans les fichiers du dossier config/.
##
## Classe indépendante des nœuds : les tests automatiques l'utilisent
## directement, et l'autoload « Config » en garde un exemplaire pour le jeu.

const DOSSIER_PAR_DEFAUT := "res://config"
const FICHIERS: PackedStringArray = ["raretes", "amelioration", "progression", "personnage", "commandes", "combat", "monstres", "statistiques", "armes", "objets", "butin"]

var _fichiers := {}


## Lit tous les fichiers de configuration du dossier indiqué.
static func charger(dossier: String = DOSSIER_PAR_DEFAUT) -> ConfigJeu:
	var config := ConfigJeu.new()
	for nom in FICHIERS:
		config._fichiers[nom] = _lire(dossier.path_join(nom + ".cfg"))
	return config


# --- Raretés ---

func ids_raretes() -> PackedStringArray:
	return PackedStringArray(_fichier("raretes").get_value("raretes", "ordre", []))


func a_rarete(id: String) -> bool:
	return id in ids_raretes() and _fichier("raretes").has_section(id)


func nom_rarete(id: String) -> String:
	return str(_valeur("raretes", id, "nom", id))


func multiplicateur_rarete(id: String) -> float:
	return _nombre("raretes", id, "multiplicateur", 1.0)


func bonus_pourcent_rarete(id: String) -> int:
	return int(_valeur("raretes", id, "bonus_pourcent", 0))


func couleur_rarete(id: String) -> Color:
	return _valeur("raretes", id, "couleur", Color.WHITE)


# --- Amélioration ---

func palier_max_amelioration() -> int:
	return int(_valeur("amelioration", "amelioration", "palier_max", 10))


## Chance (0 à 1) de réussir l'amélioration vers le palier indiqué (+1 à +10).
func taux_reussite_amelioration(palier: int) -> float:
	return _nombre("amelioration", "reussite", "plus_%d" % palier, 0.0)


# --- Progression ---

func temps_cible_base() -> float:
	return _nombre("progression", "temps_cible", "base_minutes", 0.0)


func temps_cible_coefficient() -> float:
	return _nombre("progression", "temps_cible", "coefficient", 0.0)


func temps_cible_exposant() -> float:
	return _nombre("progression", "temps_cible", "exposant", 1.0)


func monstres_par_minute() -> float:
	return _nombre("progression", "farm", "monstres_par_minute", 0.0)


## Réglages de l'XP gagnée (section [xp] de progression.cfg).
func xp_base_par_niveau() -> float:
	return _nombre("progression", "xp", "xp_base_par_niveau", 10.0)


func bonus_xp_par_niveau_au_dessus() -> float:
	return _nombre("progression", "xp", "bonus_par_niveau_au_dessus", 0.05)


func bonus_xp_maximum() -> float:
	return _nombre("progression", "xp", "bonus_maximum", 0.5)


func malus_xp_par_niveau_en_dessous() -> float:
	return _nombre("progression", "xp", "malus_par_niveau_en_dessous", 0.1)


func coefficient_xp_minimum() -> float:
	return _nombre("progression", "xp", "coefficient_minimum", 0.05)


# --- Combat ---

## Valeur numérique de combat.cfg, par exemple combat("critique", "chance").
func combat(section: String, cle: String) -> float:
	return _nombre("combat", section, cle, 0.0)


func rarete_arme() -> String:
	return str(_valeur("combat", "arme", "rarete", "standard"))


func arme_depart() -> String:
	return str(_valeur("combat", "joueur", "arme_depart", "arme.epee_bouclier"))


func arme_reference() -> String:
	return str(_valeur("combat", "calibrage", "arme_reference", "arme.epee_bouclier"))


# --- Statistiques ---

## Valeur numérique de statistiques.cfg, par exemple statistique("force", "degats_par_point").
func statistique(section: String, cle: String) -> float:
	return _nombre("statistiques", section, cle, 0.0)


# --- Armes ---

func ids_armes() -> PackedStringArray:
	return _fichier("armes").get_sections()


## Toutes les valeurs d'un type d'arme de armes.cfg (nom, vitesse, affinite…).
func arme(id: String) -> Dictionary:
	return _section("armes", id)


# --- Objets et butin ---

## Familles d'objets de objets.cfg (sections « objet.… »).
func ids_familles_objets() -> PackedStringArray:
	var ids := PackedStringArray()
	for section in _fichier("objets").get_sections():
		if section.begins_with("objet."):
			ids.append(section)
	return ids


func famille_objet(id: String) -> Dictionary:
	return _section("objets", id)


## Réglage de la génération des objets (section [generation] de objets.cfg).
func generation_objets(cle: String) -> Variant:
	return _valeur("objets", "generation", cle, null)


## Valeur de butin.cfg, par exemple butin("monstre", "dore").
func butin(section: String, cle: String) -> float:
	return _nombre("butin", section, cle, 0.0)


# --- Monstres ---

func ids_monstres() -> PackedStringArray:
	return _fichier("monstres").get_sections()


## Toutes les valeurs d'un monstre de monstres.cfg (nom, modele, niveau_min…).
func monstre(id: String) -> Dictionary:
	return _section("monstres", id)


# --- Personnage ---

func vitesse_marche() -> float:
	return _nombre("personnage", "deplacement", "vitesse_marche", 1.8)


func vitesse_course() -> float:
	return _nombre("personnage", "deplacement", "vitesse_course", 4.5)


func acceleration() -> float:
	return _nombre("personnage", "deplacement", "acceleration", 18.0)


func lissage_rotation() -> float:
	return _nombre("personnage", "deplacement", "lissage_rotation", 12.0)


func vitesse_reference_marche() -> float:
	return _nombre("personnage", "animation", "vitesse_reference_marche", 1.8)


func vitesse_reference_course() -> float:
	return _nombre("personnage", "animation", "vitesse_reference_course", 4.5)


func fondu_animation() -> float:
	return _nombre("personnage", "animation", "fondu", 0.2)


# --- Commandes ---

func rayon_joystick() -> float:
	return _nombre("commandes", "joystick", "rayon", 110.0)


func zone_morte_joystick() -> float:
	return _nombre("commandes", "joystick", "zone_morte", 0.15)


func seuil_course_joystick() -> float:
	return _nombre("commandes", "joystick", "seuil_course", 0.65)


func distance_camera() -> float:
	return _nombre("commandes", "camera", "distance", 6.5)


func inclinaison_camera_degres() -> float:
	return _nombre("commandes", "camera", "inclinaison_degres", 38.0)


func hauteur_visee_camera() -> float:
	return _nombre("commandes", "camera", "hauteur_visee", 1.1)


func champ_vision_camera() -> float:
	return _nombre("commandes", "camera", "champ_vision", 55.0)


func lissage_suivi_camera() -> float:
	return _nombre("commandes", "camera", "lissage_suivi", 8.0)


func sensibilite_rotation_camera() -> float:
	return _nombre("commandes", "camera", "sensibilite_rotation", 0.35)


# --- Outils internes ---

static func _lire(chemin: String) -> ConfigFile:
	var fichier := ConfigFile.new()
	var erreur := fichier.load(chemin)
	if erreur != OK:
		push_error("Config : impossible de lire %s (erreur %d)." % [chemin, erreur])
	return fichier


func _fichier(nom: String) -> ConfigFile:
	return _fichiers.get(nom, ConfigFile.new())


func _section(fichier: String, section: String) -> Dictionary:
	var config := _fichier(fichier)
	var valeurs := {}
	if not config.has_section(section):
		push_error("Config : « %s » est absent de %s.cfg." % [section, fichier])
		return valeurs
	for cle in config.get_section_keys(section):
		valeurs[cle] = config.get_value(section, cle)
	return valeurs


func _nombre(fichier: String, section: String, cle: String, defaut: float) -> float:
	return float(_valeur(fichier, section, cle, defaut))


func _valeur(fichier: String, section: String, cle: String, defaut: Variant) -> Variant:
	var config := _fichier(fichier)
	if not config.has_section_key(section, cle):
		push_error("Config : valeur manquante dans %s.cfg [%s] %s, valeur par défaut utilisée." % [fichier, section, cle])
		return defaut
	return config.get_value(section, cle)
