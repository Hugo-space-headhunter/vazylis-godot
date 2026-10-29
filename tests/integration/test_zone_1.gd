extends GutTest
## Zone 1 : champions, sous-boss qui invoque, mode AFK, et le monde (Vazylis et les Prés).

const SCENE_JOUEUR := preload("res://scenes/personnages/joueur.tscn")
const SCENE_MONSTRE := preload("res://scenes/monstres/monstre.tscn")

var arene: Node3D
var joueur: Joueur


func before_each() -> void:
	arene = Node3D.new()
	var sol := StaticBody3D.new()
	var forme := CollisionShape3D.new()
	forme.shape = BoxShape3D.new()
	(forme.shape as BoxShape3D).size = Vector3(60, 1, 60)
	forme.position.y = -0.5
	sol.add_child(forme)
	arene.add_child(sol)
	joueur = SCENE_JOUEUR.instantiate()
	arene.add_child(joueur)
	add_child_autofree(arene)
	await wait_physics_frames(3)


func _monstre(id: String, niveau: int, point: Vector3, champion: bool = false) -> Monstre:
	var monstre: Monstre = SCENE_MONSTRE.instantiate()
	monstre.initialiser(id, niveau, point, joueur, champion)
	arene.add_child(monstre)
	return monstre


func _monstres_vivants() -> Array:
	return get_tree().get_nodes_in_group(Monstre.GROUPE)


func test_un_champion_est_plus_gros_avec_une_aura() -> void:
	var normal := _monstre("monstre.corbac", 5, Vector3(-3, 0, -3))
	var champion := _monstre("monstre.corbac", 5, Vector3(3, 0, -3), true)
	await wait_physics_frames(2)
	assert_eq(champion.rang, Combat.RANG_CHAMPION)
	assert_almost_eq(champion.pv_max, normal.pv_max * 5.0, 0.01)
	assert_true(champion.has_node("Aura"))
	assert_false(normal.has_node("Aura"))
	assert_gt(champion._modele.scale.x, normal._modele.scale.x * 1.3)
	assert_string_starts_with(champion._etiquette.text, "Champion")


func test_un_sous_boss_n_est_jamais_champion() -> void:
	var royal := _monstre("monstre.pomelin_royal", 10, Vector3(0, 0, -6), true)
	assert_eq(royal.rang, Combat.RANG_SOUS_BOSS)
	assert_almost_eq(royal.pv_max, Combat.pv_monstre(10, Config.jeu) * 6.0, 0.01)


func test_tuer_un_champion_donne_ses_recompenses() -> void:
	var champion := _monstre("monstre.cochonnet_suie", 1, Vector3(0, 0, 1), true)
	champion.pv = 1.0
	var avant := joueur.inventaire.nombre_objets()
	joueur.changer_mode(Joueur.Mode.COMBAT)
	await wait_until(func(): return not champion.est_vivant(), 5.0)
	var attendu := Experience.new(Config.jeu)
	attendu.ajouter_xp(Experience.xp_gagnee(1, 1, Config.jeu, 5.0))
	assert_eq([joueur.experience.niveau, joueur.experience.xp], [attendu.niveau, attendu.xp], "5 fois l'XP d'un cochonnet")
	assert_gte(joueur.inventaire.nombre_objets(), avant + 2, "Un argenté et un doré")
	assert_between(joueur.inventaire.quantite("ressource.cuir"), 2, 4)


func test_le_pomelin_royal_invoque_des_pomelins_puis_les_renvoie() -> void:
	var royal := _monstre("monstre.pomelin_royal", 10, Vector3(0, 0, -3))
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	await wait_until(func(): return _monstres_vivants().size() >= 3, 16.0)
	assert_eq(_monstres_vivants().size(), 3, "2 Pomelins invoqués")
	assert_eq(royal.etat, Monstre.Etat.POURSUITE)
	await wait_until(func(): return _monstres_vivants().size() >= 5, 16.0)
	assert_eq(_monstres_vivants().size(), 5, "Au plus 4 Pomelins en même temps")
	# Le joueur s'enfuit loin : le sous-boss rentre et ses renforts disparaissent.
	joueur.global_position = Vector3(0, 0, 26)
	await wait_until(func(): return royal.etat != Monstre.Etat.POURSUITE, 12.0)
	await wait_physics_frames(3)
	assert_eq(_monstres_vivants().size(), 1)


func test_le_mode_afk_va_chercher_les_monstres_et_les_enchaine() -> void:
	joueur.statistiques.valeurs["force"] = 200
	_monstre("monstre.cochonnet_suie", 1, Vector3(5, 0, 0))
	_monstre("monstre.cochonnet_suie", 1, Vector3(-6, 0, 3))
	var royal := _monstre("monstre.pomelin_royal", 10, Vector3(0, 0, -25))
	watch_signals(joueur)
	joueur.activer_afk(true)
	assert_eq(joueur.mode, Joueur.Mode.COMBAT, "Le mode AFK sort les armes")
	assert_signal_emitted_with_parameters(joueur, "afk_change", [true])
	# Il ne reste que le sous-boss : les deux cochonnets sont tués (un monstre mort quitte le groupe).
	await wait_until(func(): return _monstres_vivants().size() == 1, 25.0)
	assert_eq(_monstres_vivants(), [royal], "Les deux cochonnets sont tués")
	assert_true(royal.est_vivant(), "Le mode AFK n'attaque pas un sous-boss de lui-même")
	assert_eq(royal.pv, royal.pv_max)
	# Sans monstre autour, il revient à son point de départ.
	var au_depart := func() -> bool: return Vector2(joueur.global_position.x, joueur.global_position.z).length() < 1.0
	await wait_until(au_depart, 6.0)
	assert_true(au_depart.call(), "Il revient à son point d'activation")


func test_le_joystick_reprend_la_main_en_mode_afk() -> void:
	_monstre("monstre.cochonnet_suie", 1, Vector3(8, 0, 0))
	joueur.activer_afk(true)
	joueur.joystick = Vector2(-1, 0)
	await wait_physics_frames(40)
	assert_lt(joueur.global_position.x, -1.0, "Il va où pousse le joystick")
	assert_true(joueur.afk, "Le mode AFK reste actif")
	joueur.changer_mode(Joueur.Mode.DEPLACEMENT)
	assert_false(joueur.afk, "Passer en mode déplacement coupe le mode AFK")


func test_mourir_ramene_au_point_de_retour_et_coupe_l_afk() -> void:
	joueur.definir_point_de_retour(Vector3(2, 0, 7))
	joueur.global_position = Vector3(-10, 0, -10)
	joueur.activer_afk(true)
	joueur.recevoir_degats(joueur.pv_max * 10.0, 1)
	assert_false(joueur.afk)
	await wait_until(func(): return joueur.est_vivant(), 5.0)
	assert_almost_eq(joueur.global_position.x, 2.0, 0.3)
	assert_almost_eq(joueur.global_position.z, 7.0, 0.3)
