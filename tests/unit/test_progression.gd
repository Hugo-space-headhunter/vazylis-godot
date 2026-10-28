extends GutTest
## Formule du temps cible par niveau et de l'XP requise.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func test_temps_cible_aux_reperes_du_game_design() -> void:
	# « environ 2 minutes au niveau 1, 5 minutes au niveau 20, 20 au niveau 100, 50 au niveau 200 »
	assert_almost_eq(Progression.minutes_cibles(1, config), 2.084, 0.001)
	assert_almost_eq(Progression.minutes_cibles(20, config), 5.0, 0.2)
	assert_almost_eq(Progression.minutes_cibles(100, config), 23.1, 0.1)
	assert_almost_eq(Progression.minutes_cibles(200, config), 50.0, 1.0)


func test_temps_cible_augmente_a_chaque_niveau() -> void:
	for niveau in range(1, 300):
		assert_lt(Progression.minutes_cibles(niveau, config), Progression.minutes_cibles(niveau + 1, config))


func test_temps_cumule_suit_le_tableau_des_reperes() -> void:
	# Tableau « Rythme cible » : 3 h 30 au niveau 40, 12 h 30 au 80, 28 h au 120, 50 h au 160, 80 h au 200.
	var reperes := {40: 3.5, 80: 12.5, 120: 28.0, 160: 50.0, 200: 80.0}
	for niveau: int in reperes:
		var heures := Progression.minutes_cumulees(niveau, config) / 60.0
		assert_almost_eq(heures, float(reperes[niveau]), float(reperes[niveau]) * 0.1,
			"Temps cumulé au niveau %d" % niveau)


func test_xp_requise() -> void:
	# Niveau 20 : 5,06 min × 6 monstres/min × 10 XP ≈ 304 XP.
	var attendu := roundi(Progression.minutes_cibles(20, config) * 6.0 * 10.0)
	assert_eq(Progression.xp_requise(20, 10.0, config), attendu)
	assert_almost_eq(float(Progression.xp_requise(20, 10.0, config)), 304.0, 2.0)


func test_xp_requise_continue_apres_200() -> void:
	assert_gt(Progression.xp_requise(500, 10.0, config), Progression.xp_requise(200, 10.0, config))
