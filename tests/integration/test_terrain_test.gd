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
	var bouton: Button = terrain.get_node("Interface/OutilsTest/BoutonPersonnage")
	var centre := bouton.get_global_rect().get_center()
	_toucher(0, centre, true)
	_glisser(0, centre + Vector2(0, 100), Vector2(0, 100))
	assert_eq(commandes.direction, Vector2.ZERO)


func test_le_bouton_change_de_personnage() -> void:
	var bouton: Button = terrain.get_node("Interface/OutilsTest/BoutonPersonnage")
	bouton.pressed.emit()
	assert_eq(joueur.personnage, IdentifiantsAssets.HEROS_FEMME)
	assert_false(joueur.modele().provisoire)
	bouton.pressed.emit()
	assert_eq(joueur.personnage, IdentifiantsAssets.HEROS_HOMME)


func test_bouton_test_niveau_et_fenetre_des_statistiques() -> void:
	var bouton_niveau: Button = terrain.get_node("Interface/OutilsTest/Niveau")
	var bouton_stats: Button = terrain.get_node("Interface/BoutonStatistiques")
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreStatistiques")
	bouton_niveau.pressed.emit()
	assert_eq(joueur.niveau(), 2)
	assert_eq(joueur.statistiques.points_libres, 4)
	assert_true(bouton_stats.get_node("Pastille").visible, "La pastille signale les points à répartir")

	bouton_stats.pressed.emit()
	assert_true(fenetre.visible)
	for i in 3:
		fenetre._modifier("force", true)
	fenetre._modifier("force", false)
	fenetre._modifier("agilite", true)
	assert_eq(joueur.statistiques.points_restants(), 1)
	fenetre._sur_valider()
	assert_eq(joueur.statistiques.valeur("force"), 2)
	assert_eq(joueur.statistiques.valeur("agilite"), 1)

	# La fenêtre ouverte empêche le joystick de démarrer dessous.
	var centre := fenetre.get_global_rect().get_center()
	_toucher(0, centre, true)
	_glisser(0, centre + Vector2(0, 100), Vector2(0, 100))
	assert_eq(commandes.direction, Vector2.ZERO)
	_toucher(0, centre, false)

	# Fermer abandonne les points en attente, jamais les points validés.
	fenetre._modifier("vitalite", true)
	fenetre.fermer()
	assert_false(fenetre.visible)
	assert_eq(joueur.statistiques.points_restants(), 1)
	assert_eq(joueur.statistiques.valeur("force"), 2)


func test_le_bouton_arme_fait_defiler_les_cinq_armes() -> void:
	var bouton: Button = terrain.get_node("Interface/OutilsTest/Arme")
	var vues := {}
	for i in 5:
		vues[joueur.id_arme] = true
		bouton.pressed.emit()
	assert_eq(vues.size(), 5)
	assert_eq(joueur.id_arme, Config.jeu.arme_depart(), "On revient à l'arme de départ")
	assert_eq(bouton.text, "Épée et bouclier")


func test_le_sac_contient_une_arme_de_chaque_type_au_depart() -> void:
	assert_eq(joueur.inventaire.nombre_objets(), 5)
	var types := {}
	for i in 5:
		types[joueur.inventaire.objet(i).type_arme] = true
	assert_eq(types.size(), 5)


func test_bouton_butin_et_fenetre_du_sac() -> void:
	var bouton_butin: Button = terrain.get_node("Interface/OutilsTest/Butin")
	var bouton_sac: Button = terrain.get_node("Interface/BoutonSac")
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreSac")
	bouton_butin.pressed.emit()
	assert_eq(joueur.inventaire.nombre_objets(), 11, "Un objet de chaque rareté en plus")
	bouton_sac.pressed.emit()
	assert_true(fenetre.visible)
	fenetre._choisir(10)
	var fiche: FicheObjet = fenetre._fiche
	await wait_physics_frames(1)
	assert_gt(fiche.get_child_count(), 3, "La fiche montre l'objet touché")
	assert_eq((fiche.get_child(0) as Label).text, joueur.inventaire.objet(10).nom)
	fenetre.fermer_fenetre()
	assert_false(fenetre.visible)


func test_sac_plein_l_objet_est_recycle() -> void:
	var hasard := RandomNumberGenerator.new()
	while not joueur.inventaire.est_plein():
		joueur.recevoir_objet(joueur.butin.creer_objet("objet.boucle_os", 1, "standard", hasard))
	var or_avant := joueur.inventaire.or_possede
	watch_signals(joueur)
	joueur.recevoir_objet(joueur.butin.creer_objet("objet.lame_guet", 10, "dore", hasard))
	assert_gt(joueur.inventaire.or_possede, or_avant)
	assert_eq(terrain.get_node("Interface/Annonces").get_child_count(), 1, "Un message prévient")
