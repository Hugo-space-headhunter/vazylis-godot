extends GutTest
## Terrain de test : on simule des doigts sur l'écran et on vérifie que le personnage réagit.

const SCENE := "res://scenes/monde/terrain_test.tscn"

var terrain: Node3D
var joueur: Joueur
var commandes: CommandesTactiles
var camera: CameraSuiveuse


func before_each() -> void:
	terrain = load(SCENE).instantiate()
	add_child_autofree(terrain)
	joueur = terrain.get_node("Joueur")
	commandes = terrain.get_node("Interface/CommandesTactiles")
	camera = terrain.get_node("CameraSuiveuse")
	await wait_physics_frames(5)


func _toucher(index: int, position_ecran: Vector2, appuye: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position_ecran
	event.pressed = appuye
	commandes._input(event)


func _glisser(index: int, position_ecran: Vector2, relatif: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position_ecran
	event.relative = relatif
	commandes._input(event)


func test_au_depart_le_personnage_est_au_repos() -> void:
	assert_eq(joueur.modele().animation_en_cours(), "idle")
	assert_false(joueur.modele().provisoire)


func test_pousser_le_joystick_a_fond_fait_courir_vers_l_avant() -> void:
	var depart := joueur.global_position
	_toucher(0, Vector2(360, 500), true)
	_glisser(0, Vector2(360, 300), Vector2(0, -200))
	assert_almost_eq(commandes.direction.length(), 1.0, 0.001)
	await wait_physics_frames(40)
	assert_lt(joueur.global_position.z, depart.z - 1.0, "Le personnage devrait avancer vers -Z")
	assert_eq(joueur.modele().animation_en_cours(), "run")

	_toucher(0, Vector2(360, 300), false)
	assert_eq(commandes.direction, Vector2.ZERO)
	await wait_physics_frames(20)
	assert_eq(joueur.modele().animation_en_cours(), "idle")
	assert_almost_eq(Vector3(joueur.velocity.x, 0, joueur.velocity.z).length(), 0.0, 0.01)


func test_pousser_un_peu_fait_marcher() -> void:
	_toucher(0, Vector2(360, 500), true)
	_glisser(0, Vector2(400, 500), Vector2(40, 0))
	await wait_physics_frames(20)
	assert_eq(joueur.modele().animation_en_cours(), "walk")
	assert_gt(joueur.global_position.x, 0.1, "Le personnage devrait aller vers la droite")


func test_deuxieme_doigt_tourne_la_camera() -> void:
	var angle_depart := camera.angle()
	_toucher(0, Vector2(200, 500), true)
	_toucher(1, Vector2(500, 400), true)
	_glisser(1, Vector2(600, 400), Vector2(100, 0))
	assert_ne(camera.angle(), angle_depart)
	assert_eq(commandes.direction, Vector2.ZERO, "Le deuxième doigt ne doit pas bouger le joystick")


func test_toucher_le_bouton_ne_lance_pas_le_joystick() -> void:
	var bouton: Button = terrain.get_node("Interface/BoutonPersonnage")
	var centre := bouton.get_global_rect().get_center()
	_toucher(0, centre, true)
	_glisser(0, centre + Vector2(0, 100), Vector2(0, 100))
	assert_eq(commandes.direction, Vector2.ZERO)


func test_le_bouton_change_de_personnage() -> void:
	var bouton: Button = terrain.get_node("Interface/BoutonPersonnage")
	bouton.pressed.emit()
	assert_eq(joueur.personnage, IdentifiantsAssets.HEROS_FEMME)
	assert_false(joueur.modele().provisoire)
	bouton.pressed.emit()
	assert_eq(joueur.personnage, IdentifiantsAssets.HEROS_HOMME)
