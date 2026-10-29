extends GutTest
## XP gagnée selon l'écart de niveau, et montée de niveau.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func test_xp_de_base() -> void:
	assert_almost_eq(Experience.xp_base_monstre(1, config), 10.0, 0.001)
	assert_almost_eq(Experience.xp_base_monstre(10, config), 100.0, 0.001)


func test_meme_niveau_xp_normale() -> void:
	assert_eq(Experience.xp_gagnee(10, 10, config), 100)


func test_monstre_plus_fort_bonus_plafonne() -> void:
	# +5 % par niveau, plafonné à +50 %.
	assert_almost_eq(Experience.coefficient_ecart(28, 30, config), 1.10, 0.001)
	assert_almost_eq(Experience.coefficient_ecart(10, 30, config), 1.50, 0.001)


func test_monstre_plus_faible_malus_avec_minimum() -> void:
	# −10 % par niveau, au moins 5 % : « presque rien à un personnage niveau 50 ».
	assert_almost_eq(Experience.coefficient_ecart(13, 10, config), 0.70, 0.001)
	assert_almost_eq(Experience.coefficient_ecart(50, 30, config), 0.05, 0.001)
	assert_eq(Experience.xp_gagnee(50, 30, config), 15)


func test_monter_de_niveau() -> void:
	var experience := Experience.new(config)
	var requise := experience.xp_pour_niveau_suivant()
	assert_eq(requise, Progression.xp_requise(1, 10.0, config))
	watch_signals(experience)
	assert_eq(experience.ajouter_xp(requise - 1), 0)
	assert_eq(experience.niveau, 1)
	assert_eq(experience.ajouter_xp(1), 1)
	assert_eq(experience.niveau, 2)
	assert_eq(experience.xp, 0)
	assert_signal_emitted_with_parameters(experience, "niveau_gagne", [2])


func test_plusieurs_niveaux_d_un_coup() -> void:
	var experience := Experience.new(config)
	var total := 0
	for niveau in range(1, 4):
		total += Progression.xp_requise(niveau, Experience.xp_base_monstre(niveau, config), config)
	assert_eq(experience.ajouter_xp(total + 5), 3)
	assert_eq(experience.niveau, 4)
	assert_eq(experience.xp, 5)


func test_environ_4_monstres_pour_le_niveau_2() -> void:
	# 0,58 minute × 6 monstres par minute ≈ 3,5 monstres de niveau 1.
	var experience := Experience.new(config)
	var monstres := ceili(float(experience.xp_pour_niveau_suivant()) / Experience.xp_gagnee(1, 1, config))
	assert_eq(monstres, 4)
