extends GutTest
## Formule du temps cible par niveau et de l'XP requise.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func test_temps_cible_aux_reperes_du_game_design() -> void:
	# « environ 35 secondes au niveau 1, 3,5 minutes au niveau 20, 22 au niveau 100, 49 au niveau 200 »
	assert_almost_eq(Progression.minutes_cibles(1, config), 0.584, 0.001)
	assert_almost_eq(Progression.minutes_cibles(20, config), 3.56, 0.05)
	assert_almost_eq(Progression.minutes_cibles(100, config), 21.6, 0.1)
	assert_almost_eq(Progression.minutes_cibles(200, config), 49.0, 0.1)


func test_temps_cible_augmente_a_chaque_niveau() -> void:
	for niveau in range(1, 300):
		assert_lt(Progression.minutes_cibles(niveau, config), Progression.minutes_cibles(niveau + 1, config))


func test_temps_cumule_suit_le_tableau_des_reperes() -> void:
	# Tableau « Rythme cible » : 2 h 30 au niveau 40, 10 h 30 au 80, 25 h au 120, 47 h au 160, 75 h au 200.
	var reperes := {40: 2.5, 80: 10.5, 120: 25.0, 160: 47.0, 200: 75.0}
	for niveau: int in reperes:
		var heures := Progression.minutes_cumulees(niveau, config) / 60.0
		assert_almost_eq(heures, float(reperes[niveau]), float(reperes[niveau]) * 0.1,
			"Temps cumulé au niveau %d" % niveau)


func test_xp_requise() -> void:
	# Niveau 20 : 3,56 min × 6 monstres/min × 10 XP ≈ 214 XP.
	var attendu := roundi(Progression.minutes_cibles(20, config) * 6.0 * 10.0)
	assert_eq(Progression.xp_requise(20, 10.0, config), attendu)
	assert_almost_eq(float(Progression.xp_requise(20, 10.0, config)), 214.0, 2.0)


func test_xp_requise_continue_apres_200() -> void:
	assert_gt(Progression.xp_requise(500, 10.0, config), Progression.xp_requise(200, 10.0, config))
