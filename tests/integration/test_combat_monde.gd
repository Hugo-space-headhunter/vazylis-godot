extends GutTest
## Combat dans une petite arène : un joueur, un monstre, un sol.

const SCENE_JOUEUR := preload("res://scenes/personnages/joueur.tscn")
const SCENE_MONSTRE := preload("res://scenes/monstres/monstre.tscn")

var arene: Node3D
var joueur: Joueur


func before_each() -> void:
	arene = Node3D.new()
	var sol := StaticBody3D.new()
	var forme := CollisionShape3D.new()
	forme.shape = BoxShape3D.new()
	(forme.shape as BoxShape3D).size = Vector3(40, 1, 40)
	forme.position.y = -0.5
	sol.add_child(forme)
	arene.add_child(sol)
	joueur = SCENE_JOUEUR.instantiate()
	arene.add_child(joueur)
	add_child_autofree(arene)
	await wait_physics_frames(3)


## Porte un objet standard de niveau 1 de cette famille.
func _equiper(famille: String) -> Objet:
	var objet := joueur.butin.creer_objet(famille, 1, "standard", RandomNumberGenerator.new())
	joueur.equiper_objet(objet)
	return objet


func _monstre(id: String, niveau: int, point: Vector3) -> Monstre:
	var monstre: Monstre = SCENE_MONSTRE.instantiate()
	monstre.initialiser(id, niveau, point, joueur)
	arene.add_child(monstre)
	return monstre


func test_en_mode_deplacement_on_ne_frappe_pas() -> void:
	var cochonnet := _monstre("monstre.cochonnet_suie", 1, Vector3(0, 0, 1.0))
	await wait_physics_frames(120)
	assert_eq(cochonnet.pv, cochonnet.pv_max)


func test_en_mode_combat_on_tue_un_cochonnet_et_on_gagne_de_l_xp() -> void:
	var cochonnet := _monstre("monstre.cochonnet_suie", 1, Vector3(0, 0, 1.0))
	joueur.changer_mode(Joueur.Mode.COMBAT)
	await wait_physics_frames(60)
	assert_lt(cochonnet.pv, cochonnet.pv_max, "Le cochonnet devrait avoir été frappé")
	assert_eq(cochonnet.etat, Monstre.Etat.POURSUITE, "Un passif frappé riposte")
	# Environ 10 à 15 secondes à niveau égal, sans armure ni statistiques : on laisse 25 secondes.
	await wait_until(func(): return not cochonnet.est_vivant(), 25.0)
	assert_false(cochonnet.est_vivant())
	assert_eq(joueur.experience.xp, Experience.xp_gagnee(1, 1, Config.jeu))
	assert_lt(joueur.pv, joueur.pv_max, "Le cochonnet a riposté")


func test_l_arme_change_de_place_selon_le_mode() -> void:
	assert_eq(joueur._armes["main_droite"].get_parent().name, "Attache_dos")
	assert_eq(joueur._armes["main_gauche"].get_parent().name, "Attache_dos")
	joueur.changer_mode(Joueur.Mode.COMBAT)
	assert_eq(joueur._armes["main_droite"].get_parent().name, "Attache_main_droite")
	assert_eq(joueur._armes["main_gauche"].get_parent().name, "Attache_main_gauche")


func test_un_pomelin_charge_le_joueur() -> void:
	var pomelin := _monstre("monstre.pomelin", 7, Vector3(0, 0, 4.5))
	await wait_until(func(): return joueur.pv < joueur.pv_max, 5.0)
	assert_lt(joueur.pv, joueur.pv_max, "Le pomelin aurait dû venir mordre le joueur")
	assert_eq(pomelin.etat, Monstre.Etat.POURSUITE)


func test_un_passif_ne_charge_pas() -> void:
	_monstre("monstre.corbac", 4, Vector3(0, 0, 2.5))
	await wait_physics_frames(180)
	assert_eq(joueur.pv, joueur.pv_max)


func test_mort_et_retour_au_depart() -> void:
	_equiper("objet.hache_bucheron")
	joueur.recevoir_degats(joueur.pv_max * 10.0, 1)
	assert_false(joueur.est_vivant())
	await wait_until(func(): return joueur.est_vivant(), 5.0)
	assert_true(joueur.est_vivant())
	assert_eq(joueur.pv, joueur.pv_max)


func test_monter_de_niveau_rend_la_vie_et_l_augmente() -> void:
	var avant := joueur.pv_max
	_equiper("objet.hache_bucheron")
	joueur.recevoir_degats(10.0, 1)
	joueur.gagner_xp(joueur.experience.xp_pour_niveau_suivant())
	assert_eq(joueur.niveau(), 2)
	assert_gt(joueur.pv_max, avant)
	assert_eq(joueur.pv, joueur.pv_max)


func test_monter_de_niveau_donne_4_points() -> void:
	joueur.gagner_xp(joueur.experience.xp_pour_niveau_suivant())
	assert_eq(joueur.statistiques.points_libres, 4)


func test_valider_de_la_vitalite_augmente_la_vie() -> void:
	joueur.gagner_xp(joueur.experience.xp_pour_niveau_suivant())
	var avant := joueur.pv_max
	for i in 4:
		joueur.statistiques.ajouter("vitalite")
	assert_eq(joueur.pv_max, avant, "Pas avant la validation")
	joueur.statistiques.valider()
	assert_almost_eq(joueur.pv_max, avant + 48.0, 0.001)
	assert_almost_eq(joueur.pv, joueur.pv_max, 0.001)


func test_chaque_arme_affiche_ses_modeles() -> void:
	for famille in Config.jeu.ids_familles_objets():
		var definition := Config.jeu.famille_objet(famille)
		if definition["emplacement"] != "arme":
			continue
		_equiper(famille)
		assert_eq(joueur.id_arme, definition["type_arme"], famille)
		assert_eq(joueur._armes.has("main_droite"), not str(definition["modele_main_droite"]).is_empty(), famille)
		assert_eq(joueur._armes.has("main_gauche"), not str(definition["modele_main_gauche"]).is_empty(), famille)


func test_l_arc_tue_de_loin() -> void:
	_equiper("objet.arc_chasseur")
	joueur.changer_mode(Joueur.Mode.COMBAT)
	var cochonnet := _monstre("monstre.cochonnet_suie", 1, Vector3(0, 0, 6.0))
	await wait_until(func(): return cochonnet.pv < cochonnet.pv_max, 5.0)
	assert_lt(cochonnet.pv, cochonnet.pv_max, "La flèche aurait dû toucher à 6 mètres")


func test_le_bouclier_bloque_parfois() -> void:
	_equiper("objet.epee_ecu_milicien")
	var touches := 0
	for i in 400:
		var avant := joueur.pv
		joueur.recevoir_degats(1.0, 1)
		if joueur.pv < avant:
			touches += 1
		joueur.pv = joueur.pv_max
	assert_between(touches, 320, 390, "Environ 90 % des coups passent")


func test_un_monstre_tue_lache_son_butin_dans_le_sac() -> void:
	joueur.butin.monstres_sans_dore = 10000
	var avant := joueur.inventaire.nombre_objets()
	var cochonnet := _monstre("monstre.cochonnet_suie", 2, Vector3(0, 0, 1.0))
	joueur.changer_mode(Joueur.Mode.COMBAT)
	await wait_until(func(): return not cochonnet.est_vivant(), 35.0)
	assert_false(cochonnet.est_vivant())
	assert_gt(joueur.inventaire.nombre_objets(), avant, "La garantie donne au moins un doré")
	var dernier := joueur.inventaire.objet(joueur.inventaire.nombre_objets() - 1)
	assert_eq(dernier.niveau, 2, "L'objet a le niveau du monstre")


func test_l_equipement_se_voit_sur_le_personnage() -> void:
	var squelette := joueur.modele().squelette()
	var avant := squelette.get_child_count()
	var hasard := RandomNumberGenerator.new()
	joueur.equiper_objet(joueur.butin.creer_objet("objet.brigandine_rodeur", 1, "epique", hasard))
	# La brigandine et son épaulière sont cousues au squelette.
	assert_gt(squelette.get_child_count(), avant + 1)
	var morceaux := joueur._habillage.nombre_de_morceaux()
	joueur.equiper_objet(joueur.butin.creer_objet("objet.cape_voyage", 1, "standard", hasard))
	assert_eq(joueur._habillage.nombre_de_morceaux(), morceaux + 1, "La cape s'ajoute")
	# La peau recule sous le plastron (le maillage de la peau a changé).
	var peau := squelette.find_child("SuperHero_Male", false, false) as MeshInstance3D
	assert_ne(peau.mesh, joueur._habillage._peau_origine)
	# Changer de personnage garde la tenue.
	joueur.changer_personnage(IdentifiantsAssets.HEROS_FEMME)
	assert_eq(joueur._habillage.nombre_de_morceaux(), morceaux + 1)


func test_exporter_puis_importer_la_partie() -> void:
	var hasard := RandomNumberGenerator.new()
	joueur.gagner_xp(joueur.experience.xp_pour_niveau_suivant() * 3)
	joueur.statistiques.ajouter("force")
	joueur.statistiques.valider()
	joueur.equiper_objet(joueur.butin.creer_objet("objet.hache_bucheron", 3, "epique", hasard))
	joueur.equiper_objet(joueur.butin.creer_objet("objet.tunique_paysan", 3, "dore", hasard))
	joueur.inventaire.or_possede = 77
	joueur.changer_personnage(IdentifiantsAssets.HEROS_FEMME)
	var texte := JSON.stringify(joueur.exporter_partie())

	# Un nouveau joueur reprend la partie.
	var autre: Joueur = SCENE_JOUEUR.instantiate()
	arene.add_child(autre)
	await wait_physics_frames(2)
	autre.importer_partie(Partie.depuis_dictionnaire(JSON.parse_string(texte), Config.jeu))
	assert_eq(autre.niveau(), joueur.niveau())
	assert_eq(autre.statistiques.valeur("force"), 1)
	assert_eq(autre.id_arme, "arme.hache_deux_mains")
	assert_eq(autre.equipement.objet("plastron").rarete, "dore")
	assert_eq(autre.inventaire.or_possede, 77)
	assert_eq(autre.personnage, IdentifiantsAssets.HEROS_FEMME)
	assert_almost_eq(autre.pv_max, joueur.pv_max, 0.001)


func test_pendant_les_tests_la_sauvegarde_est_eteinte() -> void:
	assert_false(Sauvegarde.active, "Les tests ne doivent jamais toucher à la partie de Hugo")


func test_une_arme_a_deux_mains_traine_dans_la_main_et_se_prend_a_deux_mains_pour_frapper() -> void:
	_equiper("objet.lame_guet")
	assert_true(joueur._prise.est_installee(), "La main gauche rejoint la poignée d'une arme à deux mains")
	joueur.changer_mode(Joueur.Mode.COMBAT)
	var lame: ModeleAsset = joueur._armes["main_droite"]
	assert_eq(lame.get_parent().name, "Attache_main_droite")
	assert_eq(lame._variante, Joueur.VARIANTE_REPOS, "Au repos, l'arme traîne")
	assert_eq(joueur._prise.tenue, PriseDeuxMains.Tenue.AUCUNE)
	joueur._prendre_arme_deux_mains()
	assert_eq(lame._variante, "", "Pour frapper, l'arme se lève")
	assert_eq(joueur._prise.tenue, PriseDeuxMains.Tenue.ATTAQUE)
	joueur._reposer_arme_deux_mains()
	assert_eq(lame._variante, Joueur.VARIANTE_REPOS)
	assert_eq(joueur._prise.tenue, PriseDeuxMains.Tenue.AUCUNE)


func test_une_arme_a_une_main_n_installe_pas_la_prise_a_deux_mains() -> void:
	assert_false(joueur._prise.est_installee())
	_equiper("objet.lame_guet")
	_equiper("objet.arc_chasseur")
	assert_false(joueur._prise.est_installee())
	assert_true(joueur._tir.est_installe(), "L'arc installe la main qui tire la corde")


func test_les_coups_s_enchainent_a_tour_de_role() -> void:
	var animations: Array = joueur.arme["animations_attaque"]
	var jouees := []
	for i in animations.size() + 1:
		jouees.append(joueur._animation_d_attaque())
	assert_eq(jouees.slice(0, animations.size()), animations)
	assert_eq(jouees[-1], animations[0], "Après le dernier coup, on recommence au premier")


func test_un_coup_qui_porte_fait_un_arret_sur_image_bref() -> void:
	_equiper("objet.lame_guet")
	joueur._ressentir_l_impact(false)
	assert_lt(Engine.time_scale, 1.0, "Coup lourd : le temps ralentit")
	await wait_seconds(0.3, "Le temps reprend")
	assert_eq(Engine.time_scale, 1.0)


func test_la_cape_flotte_et_l_amulette_se_balance() -> void:
	_equiper("objet.cape_voyage")
	_equiper("objet.amulette_lucioles")
	await wait_physics_frames(2)
	var tissus := joueur.find_children("*", "Tissu", true, false)
	assert_eq(tissus.size(), 1, "La cape a son tissu animé")
	var tissu: Tissu = tissus[0]
	assert_eq(tissu.setting_count, 3, "Trois colonnes d'os dans la cape")
	assert_gt(tissu.get_child_count(), 0, "Des capsules protègent le corps")
	assert_eq(joueur.find_children("*", "Pendule", true, false).size(), 1, "L'amulette a son pendule")


func test_l_amulette_prend_du_retard_quand_on_court() -> void:
	_equiper("objet.amulette_lucioles")
	var pendule: Pendule = joueur.find_children("*", "Pendule", true, false)[0]
	joueur.joystick = Vector2(0, -1)
	await wait_physics_frames(10)
	assert_gt(pendule.angle.length(), 0.01, "En démarrant, l'amulette bascule")
