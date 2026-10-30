extends GutTest
## Butin des monstres, création des objets et sac à dos.

var config: ConfigJeu
var hasard: RandomNumberGenerator


func before_all() -> void:
	config = ConfigJeu.charger()


func before_each() -> void:
	hasard = RandomNumberGenerator.new()
	hasard.seed = 2026


func test_taux_de_butin_des_monstres() -> void:
	var butin := Butin.new(config)
	var compte := {"standard": 0, "argente": 0, "dore": 0, "epique": 0}
	var kills := 40000
	for i in kills:
		for objet in butin.tirer_monstre(5, 1, hasard):
			compte[objet.rarete] += 1
	assert_almost_eq(compte["standard"] / float(kills), 0.08, 0.005)
	assert_almost_eq(compte["argente"] / float(kills), 0.03, 0.004)
	# Doré : 0,5 % plus la garantie (au plus un doré tous les 250 monstres).
	assert_between(compte["dore"] / float(kills), 0.005, 0.008)
	assert_between(compte["epique"], 10, 60)


func test_une_soiree_de_3_heures() -> void:
	# Game design : environ 85 standards, 50 argentés, 15 dorés en 3 h (avec les sous-boss).
	# Avec 6 monstres par minute : 1080 monstres, sans les sous-boss.
	var butin := Butin.new(config)
	var compte := {"standard": 0, "argente": 0, "dore": 0, "epique": 0}
	for i in 1080:
		for objet in butin.tirer_monstre(5, 1, hasard):
			compte[objet.rarete] += 1
	assert_between(compte["standard"], 65, 110)
	assert_between(compte["argente"], 20, 50)
	assert_between(compte["dore"], 4, 12)


func test_garantie_doree_apres_250_monstres() -> void:
	var butin := Butin.new(config)
	butin.monstres_sans_dore = 249
	var objets := butin.tirer_monstre(5, 1, hasard)
	assert_true(objets.any(func(o: Objet) -> bool: return o.rarete == "dore" or o.rarete == "epique"))
	assert_eq(butin.monstres_sans_dore, 0)


func test_garantie_epique_apres_2000_monstres() -> void:
	var butin := Butin.new(config)
	butin.monstres_sans_epique = 1999
	var objets := butin.tirer_monstre(5, 1, hasard)
	assert_true(objets.any(func(o: Objet) -> bool: return o.rarete == "epique"))
	assert_eq(butin.monstres_sans_epique, 0)
	assert_eq(butin.monstres_sans_dore, 0, "Un épique compte aussi comme un doré")


func test_une_arme_parfaite_a_les_degats_de_la_formule() -> void:
	var butin := Butin.new(config)
	for i in 200:
		var objet := butin.creer_objet("objet.hache_bucheron", 10, "dore", hasard)
		# (10 + 3 × 10) × 1,45 × 1,45 (hache), entre 70 % et 100 %.
		var maximum := 40.0 * 1.45 * 1.45
		assert_between(objet.degats, maximum * 0.7 - 0.001, maximum + 0.001)
		assert_eq(objet.armure, 0.0)
		assert_between(objet.statistiques.size(), 1, 2)
		assert_eq(objet.bonus.size(), 2, "Un doré a 2 bonus en %")
		assert_between(objet.qualite, 0.7, 1.0)


func test_armure_selon_l_emplacement() -> void:
	var butin := Butin.new(config)
	var plastron := butin.creer_objet("objet.tunique_paysan", 20, "standard", hasard)
	var gants := butin.creer_objet("objet.manches_paysan", 20, "standard", hasard)
	assert_between(plastron.armure, 20.0 * 0.7, 20.0)
	assert_between(gants.armure, 20.0 * 0.4 * 0.7, 20.0 * 0.4)
	assert_eq(plastron.bonus.size(), 0, "Un standard n'a pas de bonus en %")


func test_les_bijoux_n_ont_pas_d_armure_mais_plus_de_statistiques() -> void:
	var butin := Butin.new(config)
	for i in 100:
		var collier := butin.creer_objet("objet.amulette_lucioles", 30, "transcendant", hasard)
		assert_eq(collier.armure, 0.0)
		assert_between(collier.statistiques.size(), 2, 3)
		assert_eq(collier.bonus.size(), 5)
		for nom: String in collier.statistiques:
			# 0,5 × puissance (30 × 2,5 = 75)
			assert_between(collier.statistiques[nom], 26, 38)


func test_le_niveau_de_l_objet_suit_le_monstre() -> void:
	var butin := Butin.new(config)
	butin.monstres_sans_dore = 249
	for objet in butin.tirer_monstre(17, 1, hasard):
		assert_eq(objet.niveau, 17)


func test_toutes_les_familles_ont_leurs_modeles() -> void:
	assert_eq(config.ids_familles_objets().size(), 32, "17 objets de la zone 1 et 15 pièces de panoplie")
	var butin := Butin.new(config)
	for famille in config.ids_familles_objets():
		var objet := butin.creer_objet(famille, 1, "standard", hasard)
		for femme in [false, true]:
			var modele := objet.modele(config, femme)
			assert_true(CatalogueAssets.contient(modele), "%s : modèle « %s »" % [famille, modele])
		if objet.est_arme():
			assert_true(config.ids_armes().has(objet.type_arme), famille)


func test_sauvegarde_d_un_objet() -> void:
	var butin := Butin.new(config)
	var objet := butin.creer_objet("objet.arc_chasseur", 12, "epique", hasard)
	var copie := Objet.depuis_dictionnaire(JSON.parse_string(JSON.stringify(objet.vers_dictionnaire())), config)
	assert_eq(copie.nom, "Arc de chasseur")
	assert_eq(copie.niveau, 12)
	assert_eq(copie.rarete, "epique")
	assert_almost_eq(copie.degats, objet.degats, 0.0001)
	assert_eq(copie.bonus.size(), 3)


func test_le_sac_a_40_cases() -> void:
	var sac := Inventaire.new(config)
	var butin := Butin.new(config)
	assert_eq(sac.nombre_cases(), 40)
	for i in 40:
		assert_eq(sac.ajouter(butin.creer_objet("objet.boucle_os", 1, "standard", hasard)), i)
	assert_true(sac.est_plein())
	assert_eq(sac.ajouter(butin.creer_objet("objet.boucle_os", 1, "standard", hasard)), -1)
	sac.retirer(7)
	assert_eq(sac.nombre_objets(), 39)
	assert_eq(sac.ajouter(butin.creer_objet("objet.boucle_os", 1, "standard", hasard)), 7)


func test_recycler_rapporte_deux_fois_la_puissance() -> void:
	var sac := Inventaire.new(config)
	var butin := Butin.new(config)
	sac.ajouter(butin.creer_objet("objet.lame_guet", 50, "transcendant", hasard))
	assert_eq(sac.recycler(0), 250)
	assert_eq(sac.or_possede, 250)
	assert_null(sac.objet(0))
