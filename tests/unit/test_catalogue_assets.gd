extends GutTest
## Catalogue d'assets : identifiants présents, animations, points d'attache et repli automatique.

const SCRIPT_IDENTIFIANTS := "res://scripts/game/identifiants_assets.gd"


func _identifiants_du_jeu() -> Array:
	return load(SCRIPT_IDENTIFIANTS).get_script_constant_map().values()


func test_chaque_identifiant_du_jeu_est_dans_le_catalogue() -> void:
	var identifiants := _identifiants_du_jeu()
	assert_gt(identifiants.size(), 0)
	for id: String in identifiants:
		assert_true(CatalogueAssets.contient(id), "« %s » manque dans assets/catalogue.cfg" % id)


func test_chaque_entree_du_catalogue_indique_un_fichier() -> void:
	for id in CatalogueAssets.identifiants():
		assert_ne(str(CatalogueAssets.reglage(id, "fichier", "")), "", "« %s » n'a pas de fichier" % id)


func test_les_animations_du_catalogue_existent() -> void:
	for id in CatalogueAssets.identifiants():
		var animations: Dictionary = CatalogueAssets.reglage(id, "animations", {})
		if animations.is_empty():
			continue
		var modele := CatalogueAssets.creer(id)
		for standard: String in animations:
			assert_true(modele.a_animation(standard),
				"« %s » : l'animation « %s » (%s) est introuvable" % [id, standard, animations[standard]])
		modele.free()


func test_les_points_d_attache_suivent_un_os() -> void:
	for id in [IdentifiantsAssets.HEROS_HOMME, IdentifiantsAssets.HEROS_FEMME]:
		var modele := CatalogueAssets.creer(id)
		for point in ["main_droite", "main_gauche", "dos", "tete"]:
			assert_true(modele.point_attache(point) is BoneAttachment3D, "« %s » : point « %s »" % [id, point])
		modele.free()


func test_les_personnages_chargent_leur_vrai_modele() -> void:
	for id in [IdentifiantsAssets.HEROS_HOMME, IdentifiantsAssets.HEROS_FEMME]:
		var modele := CatalogueAssets.creer(id)
		assert_false(modele.provisoire, "Le fichier de « %s » devrait se charger" % id)
		modele.free()


func test_le_cristal_charge_son_vrai_modele() -> void:
	var modele := CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST)
	assert_false(modele.provisoire, "Le fichier du cristal devrait se charger")
	modele.free()


func test_un_fichier_manquant_donne_un_modele_provisoire() -> void:
	var modele := CatalogueAssets.creer(IdentifiantsAssets.EXEMPLE_MANQUANT)
	assert_not_null(modele)
	assert_true(modele.provisoire)
	assert_eq(modele.get_child_count(), 1)
	assert_true(modele.get_child(0) is MeshInstance3D)
	assert_false(modele.a_animation("idle"))
	modele.free()


func test_animation_sans_correspondance_garde_le_nom_standard() -> void:
	assert_eq(CatalogueAssets.nom_animation(IdentifiantsAssets.CRISTAL_TEST, "idle"), "idle")
