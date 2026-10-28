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
	# Environ 10 secondes à niveau égal : on laisse 16 secondes.
	await wait_until(func(): return not cochonnet.est_vivant(), 16.0)
	assert_false(cochonnet.est_vivant())
	assert_eq(joueur.experience.xp, Experience.xp_gagnee(1, 1, Config.jeu))
	assert_lt(joueur.pv, joueur.pv_max, "Le cochonnet a riposté")


func test_l_arme_change_de_place_selon_le_mode() -> void:
	assert_eq(joueur._arme.get_parent().name, "Attache_dos")
	joueur.changer_mode(Joueur.Mode.COMBAT)
	assert_eq(joueur._arme.get_parent().name, "Attache_main_droite")


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
	joueur.recevoir_degats(roundi(joueur.pv_max))
	assert_false(joueur.est_vivant())
	await wait_until(func(): return joueur.est_vivant(), 5.0)
	assert_true(joueur.est_vivant())
	assert_eq(joueur.pv, joueur.pv_max)


func test_monter_de_niveau_rend_la_vie_et_l_augmente() -> void:
	var avant := joueur.pv_max
	joueur.recevoir_degats(10)
	joueur.gagner_xp(joueur.experience.xp_pour_niveau_suivant())
	assert_eq(joueur.niveau(), 2)
	assert_gt(joueur.pv_max, avant)
	assert_eq(joueur.pv, joueur.pv_max)
