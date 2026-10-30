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
	# Une hache plutôt que l'épée et l'écu de départ : le bouclier bloquerait des coups au hasard.
	joueur.equiper_objet(joueur.butin.creer_objet("objet.hache_bucheron", 1, "standard", RandomNumberGenerator.new()))


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


func test_la_ronce_gueule_ne_bouge_pas_et_fouette_a_portee() -> void:
	var ronce := _monstre("monstre.ronce_gueule", 14, Vector3(0, 0, -2.2))
	await wait_physics_frames(60)
	assert_eq(ronce.etat, Monstre.Etat.POURSUITE, "Le joueur est à portée")
	assert_lt(joueur.pv, joueur.pv_max, "Elle fouette à 2,2 m")
	assert_almost_eq(ronce.global_position.z, -2.2, 0.05, "Elle ne bouge pas")
	joueur.global_position = Vector3(0, 0, 4)
	joueur.pv = joueur.pv_max
	await wait_physics_frames(120)
	assert_eq(joueur.pv, joueur.pv_max, "Hors de portée, elle ne peut rien")
	assert_almost_eq(ronce.global_position.z, -2.2, 0.05)


func test_le_gobelin_chapardeur_frappe_puis_recule() -> void:
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	var gobelin := _monstre("monstre.gobelin_chapardeur", 11, Vector3(0, 0, -4))
	await wait_until(func(): return joueur.pv < joueur.pv_max, 5.0)
	assert_lt(joueur.pv, joueur.pv_max, "Il a frappé")
	await wait_physics_frames(25)
	assert_gt(Vector2(gobelin.global_position.x, gobelin.global_position.z).length(), 1.8, "Puis il recule")


func test_le_gobelin_chaman_lance_des_boules_a_distance() -> void:
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	var chaman := _monstre("monstre.gobelin_chaman", 17, Vector3(0, 0, -6))
	await wait_until(func(): return not arene.find_children("*", "BouleMagique", true, false).is_empty(), 4.0)
	assert_false(arene.find_children("*", "BouleMagique", true, false).is_empty(), "Une boule est lancée")
	await wait_until(func(): return joueur.pv < joueur.pv_max, 3.0)
	assert_lt(joueur.pv, joueur.pv_max, "La boule touche")
	assert_gt(Vector2(chaman.global_position.x, chaman.global_position.z).length(), 3.0, "Il reste à distance")


func test_la_gueule_fleur_annonce_son_attaque_de_zone() -> void:
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	var fleur := _monstre("monstre.gueule_fleur", 20, Vector3(0, 0, -3.8))
	assert_eq(fleur.rang, Combat.RANG_SOUS_BOSS)
	await wait_until(func(): return fleur.has_node("AttaqueDeZone"), 8.0)
	assert_true(fleur.has_node("AttaqueDeZone"), "Un cercle rouge annonce l'attaque")
	# Le joueur s'écarte du cercle (et de la morsure) avant la fin du préavis : il n'est pas touché.
	joueur.global_position = Vector3(0, 0, 6)
	await wait_physics_frames(2)
	joueur.pv = joueur.pv_max
	await wait_until(func(): return not fleur.has_node("AttaqueDeZone"), 3.0)
	await wait_physics_frames(2)
	assert_eq(joueur.pv, joueur.pv_max, "S'écarter évite l'attaque de zone")
	assert_almost_eq(fleur.global_position.z, -3.8, 0.05, "Ancrée au sol")


func test_le_gargouillon_est_tres_resistant() -> void:
	var gargouillon := _monstre("monstre.gargouillon", 22, Vector3(0, 0, -6))
	assert_almost_eq(gargouillon.pv_max, Combat.pv_monstre(22, Config.jeu) * 1.6, 0.01)


func test_frapper_un_rat_attire_la_meute() -> void:
	var rats := []
	for i in 4:
		var rat := _monstre("monstre.rat_cryptes", 24, Vector3(-2 + i * 1.3, 0, -12))
		rats.append(rat)
	var loin := _monstre("monstre.rat_cryptes", 24, Vector3(20, 0, -12))
	await wait_physics_frames(2)
	rats[0].recevoir_coup(1, false)
	for rat: Monstre in rats:
		assert_eq(rat.etat, Monstre.Etat.POURSUITE, "Toute la meute charge")
	assert_eq(loin.etat, Monstre.Etat.ERRANCE, "Un rat loin de la meute ne bouge pas")


func test_l_ecuyer_creux_pare_parfois() -> void:
	var ecuyer := _monstre("monstre.ecuyer_creux", 27, Vector3(0, 0, -6))
	await wait_physics_frames(2)
	var pares := 0
	for i in 400:
		ecuyer.pv = ecuyer.pv_max
		ecuyer.recevoir_coup(1, false)
		if ecuyer.pv == ecuyer.pv_max:
			pares += 1
	assert_between(pares, 40, 85, "Environ 15 % des coups parés")


func test_le_gardien_bloque_de_face_mais_pas_de_dos() -> void:
	var gardien := _monstre("monstre.gardien_sans_visage", 30, Vector3(0, 0, -10))
	await wait_physics_frames(2)
	assert_eq(gardien.rang, Combat.RANG_SOUS_BOSS)
	assert_eq(gardien.find_children("*", "ModeleAsset", true, false).size(), 3, "Le Gardien et son épée et son bouclier")
	var compter := func() -> int:
		var bloques := 0
		for i in 300:
			gardien.pv = gardien.pv_max
			gardien.recevoir_coup(1, false)
			if gardien.pv == gardien.pv_max:
				bloques += 1
		return bloques
	# Il regarde vers le joueur (vers +Z) : la moitié des coups est bloquée.
	gardien._modele.rotation.y = 0.0
	assert_between(compter.call(), 110, 190, "De face, il bloque environ un coup sur deux")
	# De dos : aucun blocage.
	gardien._modele.rotation.y = PI
	assert_eq(compter.call(), 0, "De dos, rien n'est bloqué")


func test_le_gardien_tourne_lentement() -> void:
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	var gardien := _monstre("monstre.gardien_sans_visage", 30, Vector3(0, 0, -1.8))
	await wait_physics_frames(2)
	gardien._modele.rotation.y = PI
	gardien.etat = Monstre.Etat.POURSUITE
	await wait_physics_frames(30)
	assert_gt(absf(angle_difference(gardien._modele.rotation.y, 0.0)), deg_to_rad(90.0), "En une demi-seconde, il n'a pas encore fait demi-tour")


func test_le_loup_morbide_tourne_autour_du_joueur() -> void:
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	var loup := _monstre("monstre.loup_morbide", 34, Vector3(0, 0, -5))
	await wait_until(func(): return joueur.pv < joueur.pv_max, 5.0)
	var angle_depart := Vector2(loup.global_position.x, loup.global_position.z).angle()
	await wait_physics_frames(40)
	var angle_apres := Vector2(loup.global_position.x, loup.global_position.z).angle()
	assert_gt(absf(angle_difference(angle_depart, angle_apres)), deg_to_rad(20.0), "Entre deux morsures, il change d'angle autour du joueur")
	assert_lt(Vector2(loup.global_position.x, loup.global_position.z).length(), 3.5, "Il reste tout près")


func test_le_villageois_corrompu_tient_une_hache() -> void:
	var villageois := _monstre("monstre.villageois_corrompu", 37, Vector3(0, 0, -8))
	await wait_physics_frames(2)
	assert_eq(villageois.find_children("*", "ModeleAsset", true, false).size(), 2, "Le villageois et sa hache")


func test_krag_enrage_sous_la_moitie_de_sa_vie() -> void:
	var krag := _monstre("monstre.krag", 40, Vector3(0, 0, -8))
	await wait_physics_frames(2)
	assert_eq(krag.rang, Combat.RANG_SOUS_BOSS)
	krag.recevoir_coup(int(krag.pv_max * 0.3), false)
	assert_false(krag.enrage, "Encore calme à 70 % de vie")
	krag.recevoir_coup(int(krag.pv_max * 0.25), false)
	assert_true(krag.enrage, "Enragé sous la moitié de sa vie")
	# Il frappe 1,6 fois plus vite.
	joueur.pv_max = 1.0e9
	joueur.pv = joueur.pv_max
	krag.global_position = Vector3(0, 0, -1.5)
	await wait_until(func(): return joueur.pv < joueur.pv_max, 4.0)
	assert_almost_eq(krag._recharge_attaque, 1.8 / 1.6, 0.1)
	# Rentré chez lui, il se calme.
	krag.etat = Monstre.Etat.RETOUR
	await wait_physics_frames(2)
	assert_false(krag.enrage)


func test_les_pomelins_noircis_chargent_en_meute() -> void:
	var meute := []
	for i in 3:
		meute.append(_monstre("monstre.pomelin_noirci", 31, Vector3(-1.5 + i * 1.5, 0, -12)))
	await wait_physics_frames(2)
	meute[1]._engager()
	for pomelin: Monstre in meute:
		assert_eq(pomelin.etat, Monstre.Etat.POURSUITE)
