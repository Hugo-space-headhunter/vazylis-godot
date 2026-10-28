class_name Deplacement
extends RefCounted
## Règles de déplacement du personnage selon la poussée du joystick.

enum Allure { ARRET, MARCHE, COURSE }


## Allure selon la poussée du joystick (0 = relâché, 1 = poussé à fond).
static func allure(poussee: float, config: ConfigJeu) -> Allure:
	if poussee < config.zone_morte_joystick():
		return Allure.ARRET
	if poussee < config.seuil_course_joystick():
		return Allure.MARCHE
	return Allure.COURSE


## Vitesse visée, en mètres par seconde.
static func vitesse(poussee: float, config: ConfigJeu) -> float:
	match allure(poussee, config):
		Allure.MARCHE:
			return config.vitesse_marche()
		Allure.COURSE:
			return config.vitesse_course()
	return 0.0


## Animation standard correspondant à l'allure.
static func animation(une_allure: Allure) -> String:
	match une_allure:
		Allure.MARCHE:
			return "walk"
		Allure.COURSE:
			return "run"
	return "idle"


## Vitesse de lecture de l'animation pour que les pas collent au déplacement.
static func vitesse_animation(une_allure: Allure, vitesse_actuelle: float, config: ConfigJeu) -> float:
	match une_allure:
		Allure.MARCHE:
			return vitesse_actuelle / config.vitesse_reference_marche()
		Allure.COURSE:
			return vitesse_actuelle / config.vitesse_reference_course()
	return 1.0


## Direction de déplacement au sol, d'après le joystick et l'orientation de la caméra.
## joystick : x vers la droite, y vers le bas de l'écran. angle_camera : rotation Y de la caméra.
static func direction_au_sol(joystick: Vector2, angle_camera: float) -> Vector3:
	if joystick.is_zero_approx():
		return Vector3.ZERO
	var direction := Vector3(joystick.x, 0.0, joystick.y).normalized()
	return direction.rotated(Vector3.UP, angle_camera)
