extends GutTest
## L'outil qui remplit une zone (tools/peuplement_zone.gd) d'après un plan.

const PLAN := "res://tools/plans_zones/exemple.cfg"

var zone: Node3D
var plan: ConfigFile


func before_each() -> void:
	zone = Node3D.new()
	zone.set_script(load("res://scripts/world/zone.gd"))
	zone.set("taille", Vector2(60, 60))
	var a_la_main := Node3D.new()
	a_la_main.name = "Fontaine"
	zone.add_child(a_la_main)
	plan = ConfigFile.new()
	plan.load(PLAN)


func after_each() -> void:
	zone.free()


func _positions() -> Array:
	return zone.get_node("Peuplement").get_children().map(func(n: Node3D) -> Vector3: return n.position)


func test_le_plan_d_exemple_pose_les_monstres_et_le_decor() -> void:
	var poses := PeuplementZone.peupler(zone, plan)
	assert_eq(poses, 22, "12 arbres et 10 buissons")
	var cochonnets := zone.get_node("Monstres/Cochonnets")
	assert_eq(cochonnets.get("monstre_id"), "monstre.cochonnet_suie")
	assert_eq(cochonnets.get("nombre"), 4)
	assert_true(zone.has_node("Fontaine"), "Ce qui a été posé à la main est gardé")
	for objet: Node3D in zone.get_node("Peuplement").get_children():
		assert_true(CatalogueAssets.contient(objet.get("id_asset")), objet.name)


func test_le_decor_evite_le_chemin_les_places_libres_et_les_monstres() -> void:
	PeuplementZone.peupler(zone, plan)
	for p: Vector3 in _positions():
		assert_gt(absf(p.x), 3.0, "Pas de décor sur le chemin")
		assert_gt(Vector2(p.x, p.z).length(), 6.0, "Pas de décor sur la place libre")
		assert_gt(Vector2(p.x, p.z).distance_to(Vector2(-12, 8)), 6.0, "Pas de décor sur les monstres")
		assert_lt(absf(p.x), 30.0, "Dans la zone")


func test_relancer_avec_la_meme_graine_redonne_la_meme_zone() -> void:
	PeuplementZone.peupler(zone, plan)
	var premiere := _positions()
	PeuplementZone.peupler(zone, plan)
	assert_eq(_positions(), premiere)
	assert_eq(zone.get_node("Monstres").get_child_count(), 1, "Le groupe de monstres est remplacé, pas doublé")
