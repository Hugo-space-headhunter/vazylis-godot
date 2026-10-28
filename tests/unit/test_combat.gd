extends GutTest
## Formules de combat et calibrage des monstres.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func test_degats_de_l_arme_de_depart() -> void:
	# (10 + 3 × niveau) × 1 (standard)
	assert_almost_eq(Combat.degats_arme(1, config), 13.0, 0.001)
	assert_almost_eq(Combat.degats_arme(10, config), 40.0, 0.001)


func test_points_de_vie_du_joueur() -> void:
	assert_almost_eq(Combat.pv_joueur(1, config), 115.0, 0.001)
	assert_almost_eq(Combat.pv_joueur(10, config), 250.0, 0.001)


func test_on_tue_un_monstre_de_son_niveau_en_10_secondes() -> void:
	for niveau in [1, 5, 10, 50]:
		var secondes := Combat.pv_monstre(niveau, config) / Combat.dps_joueur(niveau, config)
		assert_almost_eq(secondes, 10.0, 0.001, "Niveau %d" % niveau)


func test_un_monstre_agressif_tue_le_joueur_en_60_secondes() -> void:
	var intervalle := 1.5
	for niveau in [1, 10, 50]:
		var dps := Combat.degats_monstre(niveau, niveau, false, intervalle, config) / intervalle
		assert_almost_eq(Combat.pv_joueur(niveau, config) / dps, 60.0, 0.001, "Niveau %d" % niveau)


func test_les_passifs_frappent_deux_fois_moins_fort() -> void:
	var agressif := Combat.degats_monstre(5, 5, false, 1.5, config)
	assert_almost_eq(Combat.degats_monstre(5, 5, true, 1.5, config), agressif * 0.5, 0.001)


func test_monstre_bien_plus_haut_frappe_plus_fort() -> void:
	var normal := Combat.degats_monstre(20, 15, false, 1.5, config)
	# 5 niveaux d'écart : pas de bonus. 8 niveaux : +5 % × 3.
	assert_almost_eq(normal, Combat.degats_monstre(20, 20, false, 1.5, config), 0.001)
	assert_almost_eq(Combat.degats_monstre(20, 12, false, 1.5, config), normal * 1.15, 0.001)


func test_coups_critiques_environ_5_pourcent() -> void:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = 42
	var critiques := 0
	for i in 10000:
		var coup := Combat.coup_joueur(10, config, hasard)
		if coup["critique"]:
			critiques += 1
			assert_eq(coup["degats"], 60)
		else:
			assert_eq(coup["degats"], 40)
	assert_almost_eq(critiques / 10000.0, 0.05, 0.01)


func test_chaque_monstre_de_la_config_a_un_modele_au_catalogue() -> void:
	assert_eq(config.ids_monstres().size(), 3)
	for id in config.ids_monstres():
		var monstre := config.monstre(id)
		assert_true(CatalogueAssets.contient(str(monstre["modele"])), id)
		assert_true(monstre["comportement"] in ["passif", "agressif"], id)
		assert_lte(int(monstre["niveau_min"]), int(monstre["niveau_max"]), id)
