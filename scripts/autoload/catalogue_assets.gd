extends Node
## Autoload « CatalogueAssets » : relie chaque identifiant (ex. « prop.cristal_test »)
## à son fichier 3D et à ses réglages, lus dans assets/catalogue.cfg.
##
## C'est le seul endroit qui connaît les fichiers 3D. Si un fichier manque ou
## ne se charge pas, un modèle provisoire simple est affiché à la place,
## et un avertissement apparaît dans la console.

const CHEMIN_CATALOGUE := "res://assets/catalogue.cfg"

## Noms d'animations communs à tout le jeu. Le catalogue indique, pour chaque
## modèle, le vrai nom de chacune (réglage « animations »).
const ANIMATIONS_STANDARD: PackedStringArray = ["idle", "walk", "run", "attack", "hit", "die"]

const COULEUR_REPLI_PAR_DEFAUT := Color(1.0, 0.35, 0.6)

var _catalogue := ConfigFile.new()


func _init() -> void:
	charger(CHEMIN_CATALOGUE)


func charger(chemin: String) -> void:
	_catalogue = ConfigFile.new()
	var erreur := _catalogue.load(chemin)
	if erreur != OK:
		push_error("Catalogue : impossible de lire %s (erreur %d)." % [chemin, erreur])


func contient(id: String) -> bool:
	return _catalogue.has_section(id)


func identifiants() -> PackedStringArray:
	return _catalogue.get_sections()


func reglage(id: String, cle: String, defaut: Variant = null) -> Variant:
	return _catalogue.get_value(id, cle, defaut)


## Vrai nom, dans le modèle, d'une animation standard (« idle », « walk »…).
func nom_animation(id: String, animation_standard: String) -> String:
	var table: Dictionary = reglage(id, "animations", {})
	return str(table.get(animation_standard, animation_standard))


## Points d'attache du modèle : nom du point (« main_droite »…) → nom de l'os.
func points_attache(id: String) -> Dictionary:
	return reglage(id, "points_attache", {})


## Crée le modèle 3D correspondant à l'identifiant, prêt à être ajouté à la scène.
## Renvoie toujours un nœud : le vrai modèle, ou un modèle provisoire en cas de problème.
func creer(id: String) -> Node3D:
	var conteneur := Node3D.new()
	conteneur.name = id.replace(".", "_")
	conteneur.set_meta("asset_id", id)

	if not contient(id):
		push_error("Catalogue : identifiant inconnu « %s », modèle provisoire affiché." % id)
		conteneur.add_child(_modele_provisoire(id))
		conteneur.set_meta("provisoire", true)
		return conteneur

	var modele := _charger_modele(id)
	if modele == null:
		modele = _modele_provisoire(id)
		conteneur.set_meta("provisoire", true)
	else:
		modele.scale = Vector3.ONE * float(reglage(id, "echelle", 1.0))
		modele.rotation_degrees = reglage(id, "rotation_degres", Vector3.ZERO)
		modele.position = reglage(id, "decalage", Vector3.ZERO)
		conteneur.set_meta("provisoire", false)
	conteneur.add_child(modele)
	return conteneur


func _charger_modele(id: String) -> Node3D:
	var chemin := str(reglage(id, "fichier", ""))
	if chemin.is_empty() or not ResourceLoader.exists(chemin):
		push_warning("Catalogue : fichier introuvable pour « %s » (%s), modèle provisoire affiché." % [id, chemin])
		return null
	var ressource := load(chemin)
	if ressource is PackedScene:
		var instance := (ressource as PackedScene).instantiate()
		if instance is Node3D:
			return instance
		instance.free()
	push_warning("Catalogue : le fichier de « %s » (%s) ne contient pas de modèle 3D, modèle provisoire affiché." % [id, chemin])
	return null


## Forme simple et colorée, posée au sol (origine aux pieds).
func _modele_provisoire(id: String) -> MeshInstance3D:
	var taille: Vector3 = reglage(id, "taille_repli", Vector3.ONE)
	var forme := str(reglage(id, "forme_repli", "boite"))
	var maillage: PrimitiveMesh
	match forme:
		"sphere":
			var sphere := SphereMesh.new()
			sphere.radius = taille.x / 2.0
			sphere.height = taille.y
			maillage = sphere
		"capsule":
			var capsule := CapsuleMesh.new()
			capsule.radius = taille.x / 2.0
			capsule.height = taille.y
			maillage = capsule
		_:
			var boite := BoxMesh.new()
			boite.size = taille
			maillage = boite

	var matiere := StandardMaterial3D.new()
	matiere.albedo_color = reglage(id, "couleur_repli", COULEUR_REPLI_PAR_DEFAUT)
	maillage.material = matiere

	var instance := MeshInstance3D.new()
	instance.name = "ModeleProvisoire"
	instance.mesh = maillage
	instance.position.y = taille.y / 2.0
	return instance
