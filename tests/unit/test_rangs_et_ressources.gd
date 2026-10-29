extends GutTest
## Monstres champions et sous-boss (vie, dégâts, XP, butin) et ressources rangées dans le sac.

var config: ConfigJeu
var hasard: RandomNumberGenerator


func before_all() -> void:
	config = ConfigJeu.charger()


func before_each() -> void:
	hasard = RandomNumberGenerator.new()
	hasard.seed = 61


func test_un_champion_a_5_fois_plus_de_vie_et_frappe_2_fois_plus_fort() -> void:
	var normal := Combat.pv_monstre(5, config)
	assert_almost_eq(Combat.pv_monstre(5, config, Combat.RANG_CHAMPION), normal * 5.0, 0.01)
	var coup := Combat.degats_monstre(5, 5, false, 1.5, config)
	assert_almost_eq(Combat.degats_monstre(5, 5, false, 1.5, config, Combat.RANG_CHAMPION), coup * 2.0, 0.01)


func test_un_sous_boss_se_tue_en_1_minute_et_tue_en_20_secondes() -> void:
	# Un monstre : 10 s pour le tuer, 60 s pour être tué.
	var normal := Combat.pv_monstre(10, config)
	assert_almost_eq(Combat.pv_monstre(10, config, Combat.RANG_SOUS_BOSS), normal * 6.0, 0.01)
	var coup := Combat.degats_monstre(10, 10, false, 1.8, config)
	assert_almost_eq(Combat.degats_monstre(10, 10, false, 1.8, config, Combat.RANG_SOUS_BOSS), coup * 3.0, 0.01)


func test_xp_des_champions_et_des_sous_boss() -> void:
	var xp := Experience.xp_gagnee(8, 8, config)
	assert_eq(Experience.xp_gagnee(8, 8, config, Combat.multiplicateur_xp(Combat.RANG_CHAMPION, config)), xp * 5)
	assert_eq(Experience.xp_gagnee(8, 8, config, Combat.multiplicateur_xp(Combat.RANG_SOUS_BOSS, config)), xp * 6)
	assert_eq(Combat.multiplicateur_xp(Combat.RANG_NORMAL, config), 1.0)


func test_un_monstre_lache_sa_ressource_une_fois_sur_trois() -> void:
	var butin := Butin.new(config)
	var fois := 0
	var total := 0
	for i in 10000:
		var gains: Dictionary = butin.tirer(Combat.RANG_NORMAL, 3, 1, hasard, "ressource.cuir")
		if gains["ressources"].has("ressource.cuir"):
			fois += 1
			var quantite: int = gains["ressources"]["ressource.cuir"]
			assert_between(quantite, 1, 3)
			total += quantite
	assert_almost_eq(fois / 10000.0, 0.35, 0.02)
	assert_almost_eq(total / float(fois), 2.0, 0.1, "En moyenne 2 unités")


func test_un_champion_lache_toujours_un_argente_un_dore_et_des_ressources() -> void:
	var butin := Butin.new(config)
	for i in 50:
		var gains: Dictionary = butin.tirer(Combat.RANG_CHAMPION, 6, 1, hasard, "ressource.cuir")
		var raretes := []
		for objet: Objet in gains["objets"]:
			raretes.append(objet.rarete)
			assert_eq(objet.niveau, 6)
		assert_has(raretes, "argente")
		assert_has(raretes, "dore")
		assert_does_not_have(raretes, "standard")
		assert_between(int(gains["ressources"]["ressource.cuir"]), 2, 4)
	assert_eq(butin.monstres_sans_dore, 0, "Le doré du champion remet la garantie à zéro")


func test_un_sous_boss_lache_un_epique_au_plus_tard_a_sa_12e_victoire() -> void:
	var butin := Butin.new(config)
	var sans_epique := 0
	var lueurs := 0
	for i in 600:
		var gains: Dictionary = butin.tirer(Combat.RANG_SOUS_BOSS, 10, 1, hasard, "ressource.chene", "monstre.pomelin_royal")
		var epique := false
		for objet: Objet in gains["objets"]:
			epique = epique or objet.rarete == "epique"
		sans_epique = 0 if epique else sans_epique + 1
		assert_lt(sans_epique, 12, "Jamais 12 victoires de suite sans épique")
		assert_true(gains["ressources"].has("ressource.chene"), "Toujours des ressources")
		if gains["ressources"].has("ressource.lueur_familier"):
			lueurs += 1
	assert_almost_eq(lueurs / 600.0, 0.6, 0.06, "60 % de ressources de familier")
	assert_eq(butin.monstres_sans_dore, 0, "Les sous-boss ne comptent pas dans la garantie des monstres")


func test_la_garantie_de_chaque_sous_boss_est_a_part() -> void:
	var butin := Butin.new(config)
	butin.victoires_sans_epique["monstre.pomelin_royal"] = 11
	var gains: Dictionary = butin.tirer(Combat.RANG_SOUS_BOSS, 10, 1, hasard, "", "monstre.pomelin_royal")
	var raretes := []
	for objet: Objet in gains["objets"]:
		raretes.append(objet.rarete)
	assert_has(raretes, "epique")
	assert_eq(butin.victoires_sans_epique["monstre.pomelin_royal"], 0)
	butin.tirer(Combat.RANG_SOUS_BOSS, 20, 1, hasard, "", "monstre.autre_sous_boss")
	assert_true(butin.victoires_sans_epique.has("monstre.autre_sous_boss"))


func test_les_ressources_ne_prennent_pas_de_case() -> void:
	var inventaire := Inventaire.new(config)
	watch_signals(inventaire)
	inventaire.ajouter_ressources({"ressource.fer": 3})
	inventaire.ajouter_ressources({"ressource.fer": 2, "ressource.cuir": 1})
	assert_eq(inventaire.quantite("ressource.fer"), 5)
	assert_eq(inventaire.quantite("ressource.cuir"), 1)
	assert_eq(inventaire.quantite("ressource.chene"), 0)
	assert_eq(inventaire.nombre_objets(), 0)
	assert_signal_emit_count(inventaire, "change", 2)


func test_les_ressources_et_la_garantie_des_sous_boss_sont_sauvegardees() -> void:
	var partie := Partie.new()
	partie.inventaire = Inventaire.new(config)
	partie.inventaire.ajouter_ressources({"ressource.chene": 12, "ressource.lueur_familier": 2})
	partie.victoires_sans_epique = {"monstre.pomelin_royal": 7}
	var relue := Partie.depuis_dictionnaire(JSON.parse_string(JSON.stringify(partie.vers_dictionnaire())), config)
	assert_eq(relue.inventaire.quantite("ressource.chene"), 12)
	assert_eq(relue.inventaire.quantite("ressource.lueur_familier"), 2)
	assert_eq(relue.victoires_sans_epique["monstre.pomelin_royal"], 7)


func test_une_ancienne_sauvegarde_sans_ressources_se_relit() -> void:
	var partie := Partie.new()
	partie.inventaire = Inventaire.new(config)
	var donnees := partie.vers_dictionnaire()
	donnees["sac"].erase("ressources")
	donnees["garantie"].erase("victoires_sans_epique")
	donnees["sac"]["ressources"] = {"ressource.disparue": 4}
	var relue := Partie.depuis_dictionnaire(donnees, config)
	assert_not_null(relue)
	assert_true(relue.inventaire.ressources.is_empty(), "Une ressource inconnue est ignorée")
	assert_true(relue.victoires_sans_epique.is_empty())


func test_chaque_monstre_lache_une_ressource_qui_existe() -> void:
	for id in config._fichier("monstres").get_sections():
		var ressource := str(config.monstre(id).get("ressource", ""))
		assert_true(ressource in config.ids_ressources(), "%s : ressource « %s » inconnue" % [id, ressource])
