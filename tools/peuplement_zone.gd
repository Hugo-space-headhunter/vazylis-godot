class_name PeuplementZone
extends RefCounted
## Remplit une zone à partir d'un plan (fichier .cfg, voir tools/plans_zones/exemple.cfg) :
##   - les groupes de monstres (ZoneApparition) sous le nœud « Monstres » ;
##   - le décor semé au hasard (Decor) sous le nœud « Peuplement », en évitant les places libres,
##     le chemin, les monstres et en gardant un écart entre deux objets.
## Il ne remplace que ce qu'il a lui-même posé : les groupes de monstres nommés dans le plan et le
## nœud « Peuplement ». Le reste de la zone (sol, retouches faites à la main…) n'est pas touché.
## Le hasard est fixé par « graine » : relancer l'outil avec le même plan redonne la même zone.
##
## Lancer : tools/peupler_zone.gd.

const SCRIPT_DECOR := "res://scripts/world/decor.gd"
const SCRIPT_APPARITION := "res://scripts/world/zone_apparition.gd"
const NOEUD_MONSTRES := "Monstres"
const NOEUD_PEUPLEMENT := "Peuplement"
## Essais au hasard pour placer un objet avant d'abandonner (zone trop pleine).
const ESSAIS_PAR_OBJET := 40


## Remplit « zone » (la racine de la scène, avec le script Zone) selon le plan.
## Renvoie le nombre d'objets de décor posés.
static func peupler(zone: Node3D, plan: ConfigFile) -> int:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = int(plan.get_value("zone", "graine", 1))
	var taille: Vector2 = zone.get("taille") if zone.get("taille") != null else Vector2(40, 40)
	var libres: Array = plan.get_value("zone", "places_libres", [])
	var chemin: Dictionary = plan.get_value("zone", "chemin", {})
	var occupes: Array = []
	for place: Array in libres:
		occupes.append([Vector2(place[0], place[1]), float(place[2])])

	var monstres := _noeud(zone, NOEUD_MONSTRES)
	for section in plan.get_sections():
		if not section.begins_with("monstres."):
			continue
		var nom := section.trim_prefix("monstres.")
		_retirer(monstres.get_node_or_null(nom))
		var position: Vector2 = plan.get_value(section, "position", Vector2.ZERO)
		var rayon := float(plan.get_value(section, "rayon", 3.0))
		var apparition := Node3D.new()
		apparition.name = nom
		apparition.set_script(load(SCRIPT_APPARITION))
		apparition.position = Vector3(position.x, 0, position.y)
		apparition.set("monstre_id", str(plan.get_value(section, "monstre", "")))
		apparition.set("nombre", int(plan.get_value(section, "nombre", 4)))
		apparition.set("rayon", rayon)
		_ajouter(monstres, apparition, zone)
		occupes.append([position, rayon + 2.0])

	_retirer(zone.get_node_or_null(NOEUD_PEUPLEMENT))
	var peuplement := _noeud(zone, NOEUD_PEUPLEMENT)
	var poses := 0
	for section in plan.get_sections():
		if not section.begins_with("decor."):
			continue
		var groupe := section.trim_prefix("decor.")
		var assets: Array = plan.get_value(section, "assets", [])
		var ecart := float(plan.get_value(section, "ecart_min", 2.0))
		var echelles: Array = plan.get_value(section, "echelle", [1.0, 1.0])
		var marge := float(plan.get_value(section, "marge_bord", 2.0))
		for i in int(plan.get_value(section, "nombre", 0)):
			var point := _trouver_une_place(hasard, taille, marge, ecart, occupes, chemin)
			if point == Vector2.INF or assets.is_empty():
				push_warning("PeuplementZone : plus de place pour « %s » (%d posés sur %d)." % [groupe, i, int(plan.get_value(section, "nombre", 0))])
				break
			occupes.append([point, ecart / 2.0])
			var decor := Node3D.new()
			decor.name = "%s%d" % [groupe, i + 1]
			decor.set_script(load(SCRIPT_DECOR))
			decor.set("id_asset", str(assets[hasard.randi() % assets.size()]))
			decor.set("obstacle", plan.get_value(section, "obstacle", Vector3.ZERO))
			decor.set("distance_affichage", float(plan.get_value(section, "distance_affichage", 0.0)))
			decor.set("projette_ombre", bool(plan.get_value(section, "projette_ombre", true)))
			decor.set("fondu_camera", float(plan.get_value(section, "fondu_camera", 0.0)))
			decor.position = Vector3(point.x, 0, point.y)
			decor.rotation.y = hasard.randf() * TAU
			decor.scale = Vector3.ONE * hasard.randf_range(float(echelles[0]), float(echelles[-1]))
			_ajouter(peuplement, decor, zone)
			poses += 1
	return poses


## Une place libre dans la zone (repère de la zone, x et z), ou Vector2.INF s'il n'y en a plus.
static func _trouver_une_place(hasard: RandomNumberGenerator, taille: Vector2, marge: float, ecart: float,
		occupes: Array, chemin: Dictionary) -> Vector2:
	var demi := taille / 2.0 - Vector2.ONE * marge
	for essai in ESSAIS_PAR_OBJET:
		var point := Vector2(hasard.randf_range(-demi.x, demi.x), hasard.randf_range(-demi.y, demi.y))
		if _sur_le_chemin(point, chemin, ecart / 2.0):
			continue
		var libre := true
		for place: Array in occupes:
			if point.distance_to(place[0]) < float(place[1]) + ecart / 2.0:
				libre = false
				break
		if libre:
			return point
	return Vector2.INF


## Chemin droit le long de l'axe Z : {"x": centre, "demi_largeur": …}.
static func _sur_le_chemin(point: Vector2, chemin: Dictionary, marge: float) -> bool:
	if chemin.is_empty():
		return false
	return absf(point.x - float(chemin.get("x", 0.0))) < float(chemin.get("demi_largeur", 3.0)) + marge


static func _noeud(zone: Node3D, nom: String) -> Node3D:
	var noeud := zone.get_node_or_null(nom) as Node3D
	if noeud == null:
		noeud = Node3D.new()
		noeud.name = nom
		_ajouter(zone, noeud, zone)
	return noeud


static func _ajouter(parent: Node, enfant: Node, zone: Node) -> void:
	parent.add_child(enfant)
	enfant.owner = zone


static func _retirer(noeud: Node) -> void:
	if noeud != null:
		noeud.get_parent().remove_child(noeud)
		noeud.free()
