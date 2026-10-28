extends GutTest
## Catalogue d'assets : identifiants présents et repli automatique.

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


func test_le_cristal_charge_son_vrai_modele() -> void:
	var modele := CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST)
	assert_false(modele.get_meta("provisoire"), "Le fichier du cristal devrait se charger")
	modele.free()


func test_un_fichier_manquant_donne_un_modele_provisoire() -> void:
	var modele := CatalogueAssets.creer(IdentifiantsAssets.EXEMPLE_MANQUANT)
	assert_not_null(modele)
	assert_true(modele.get_meta("provisoire"))
	assert_eq(modele.get_child_count(), 1)
	assert_true(modele.get_child(0) is MeshInstance3D)
	modele.free()


func test_animation_sans_correspondance_garde_le_nom_standard() -> void:
	assert_eq(CatalogueAssets.nom_animation(IdentifiantsAssets.CRISTAL_TEST, "idle"), "idle")
