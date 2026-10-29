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
var _matieres_teintees := {}


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
## Renvoie toujours un modèle : le vrai, ou un modèle provisoire en cas de problème.
func creer(id: String) -> ModeleAsset:
	var conteneur := ModeleAsset.new()
	if not contient(id):
		push_error("Catalogue : identifiant inconnu « %s », modèle provisoire affiché." % id)
		conteneur.configurer(id, _modele_provisoire(id), true, {}, {}, [])
		return conteneur

	var modele := _charger_modele(id)
	var provisoire := modele == null
	if provisoire:
		modele = _modele_provisoire(id)
	else:
		modele.scale = Vector3.ONE * float(reglage(id, "echelle", 1.0))
		modele.rotation_degrees = reglage(id, "rotation_degres", Vector3.ZERO)
		modele.position = reglage(id, "decalage", Vector3.ZERO)
		_appliquer_teinte(id, modele)
	conteneur.configurer(id, modele, provisoire, reglage(id, "animations", {}),
		points_attache(id), _charger_bibliotheques(id), reglage(id, "placements", {}))
	return conteneur


## Multiplie la couleur de toutes les matières du modèle (réglage « teinte »).
## Les matières teintées sont partagées entre tous les exemplaires d'un même identifiant.
func _appliquer_teinte(id: String, modele: Node3D) -> void:
	var teinte: Color = reglage(id, "teinte", Color.WHITE)
	if teinte == Color.WHITE:
		return
	var cache: Dictionary = _matieres_teintees.get_or_add(id, {})
	for noeud in modele.find_children("*", "MeshInstance3D", true, false):
		var instance := noeud as MeshInstance3D
		for surface in instance.get_surface_override_material_count():
			var origine := instance.get_active_material(surface) as BaseMaterial3D
			if origine == null:
				continue
			if not cache.has(origine):
				var copie := origine.duplicate() as BaseMaterial3D
				copie.albedo_color *= teinte
				cache[origine] = copie
			instance.set_surface_override_material(surface, cache[origine])


## Bibliothèques d'animations partagées (réglage « bibliotheques_animations », une liste).
func _charger_bibliotheques(id: String) -> Array:
	var bibliotheques := []
	for chemin in reglage(id, "bibliotheques_animations", []):
		if ResourceLoader.exists(chemin) and load(chemin) is AnimationLibrary:
			bibliotheques.append(load(chemin))
		else:
			push_warning("Catalogue : bibliothèque d'animations introuvable pour « %s » (%s)." % [id, chemin])
	return bibliotheques


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
