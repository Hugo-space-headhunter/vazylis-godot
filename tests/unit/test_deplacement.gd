extends GutTest
## Allure et vitesse du personnage selon la poussée du joystick.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func test_joystick_relache_ou_dans_la_zone_morte() -> void:
	assert_eq(Deplacement.allure(0.0, config), Deplacement.Allure.ARRET)
	assert_eq(Deplacement.allure(config.zone_morte_joystick() * 0.9, config), Deplacement.Allure.ARRET)
	assert_eq(Deplacement.vitesse(0.0, config), 0.0)


func test_pousse_a_moitie_on_marche() -> void:
	var poussee := (config.zone_morte_joystick() + config.seuil_course_joystick()) / 2.0
	assert_eq(Deplacement.allure(poussee, config), Deplacement.Allure.MARCHE)
	assert_eq(Deplacement.vitesse(poussee, config), config.vitesse_marche())


func test_pousse_a_fond_on_court() -> void:
	assert_eq(Deplacement.allure(1.0, config), Deplacement.Allure.COURSE)
	assert_eq(Deplacement.vitesse(1.0, config), config.vitesse_course())
	assert_gt(config.vitesse_course(), config.vitesse_marche())


func test_animations_standard() -> void:
	assert_eq(Deplacement.animation(Deplacement.Allure.ARRET), "idle")
	assert_eq(Deplacement.animation(Deplacement.Allure.MARCHE), "walk")
	assert_eq(Deplacement.animation(Deplacement.Allure.COURSE), "run")


func test_vitesse_animation_normale_a_la_vitesse_de_reference() -> void:
	assert_almost_eq(Deplacement.vitesse_animation(Deplacement.Allure.MARCHE,
		config.vitesse_reference_marche(), config), 1.0, 0.001)
	assert_almost_eq(Deplacement.vitesse_animation(Deplacement.Allure.COURSE,
		config.vitesse_reference_course() / 2.0, config), 0.5, 0.001)


func test_direction_au_sol_suit_la_camera() -> void:
	# Joystick vers le haut, caméra non tournée : on avance vers -Z (devant la caméra).
	assert_almost_eq(Deplacement.direction_au_sol(Vector2(0, -1), 0.0), Vector3(0, 0, -1), Vector3.ONE * 0.001)
	# Joystick vers la droite : on va vers +X.
	assert_almost_eq(Deplacement.direction_au_sol(Vector2(1, 0), 0.0), Vector3(1, 0, 0), Vector3.ONE * 0.001)
	# Caméra tournée d'un quart de tour : « devant » devient -X.
	assert_almost_eq(Deplacement.direction_au_sol(Vector2(0, -1), PI / 2.0), Vector3(-1, 0, 0), Vector3.ONE * 0.001)
	assert_eq(Deplacement.direction_au_sol(Vector2.ZERO, 0.0), Vector3.ZERO)
