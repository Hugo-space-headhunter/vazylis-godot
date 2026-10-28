extends GutTest
## Puissance d'un item, raretés et taux d'amélioration.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func test_exemples_du_game_design() -> void:
	# « Un transcendant niveau 50 (puissance 125) surpasse un standard niveau 80 (80),
	#   puis se fait dépasser par un épique niveau 110 (192). »
	assert_eq(PuissanceItem.calculer(50, "transcendant", config), 125)
	assert_eq(PuissanceItem.calculer(80, "standard", config), 80)
	assert_eq(PuissanceItem.calculer(110, "epique", config), 192)


func test_bonus_amelioration_ajoute() -> void:
	assert_eq(PuissanceItem.calculer(80, "standard", config, 7), 87)


func test_rarete_inconnue_donne_zero() -> void:
	assert_eq(PuissanceItem.calculer(10, "violet", config), 0)
	assert_push_error("rareté inconnue")


func test_six_raretes_dans_l_ordre() -> void:
	assert_eq(config.ids_raretes(), PackedStringArray(
		["standard", "argente", "dore", "epique", "mythique", "transcendant"]))


func test_multiplicateurs_croissants() -> void:
	var precedent := 0.0
	for rarete in config.ids_raretes():
		assert_gt(config.multiplicateur_rarete(rarete), precedent, rarete)
		precedent = config.multiplicateur_rarete(rarete)


func test_taux_amelioration() -> void:
	var attendus := [1.0, 1.0, 0.9, 0.8, 0.7, 0.45, 0.35, 0.2, 0.12, 0.06]
	assert_eq(config.palier_max_amelioration(), 10)
	for palier in range(1, 11):
		assert_almost_eq(config.taux_reussite_amelioration(palier), attendus[palier - 1], 0.0001,
			"Palier +%d" % palier)
