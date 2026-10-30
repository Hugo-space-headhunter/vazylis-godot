extends GutTest
## La forge (amélioration +1 à +10) et le recyclage en matériaux.

var config: ConfigJeu
var hasard: RandomNumberGenerator
var butin: Butin
var forge: Forge


func before_all() -> void:
	config = ConfigJeu.charger()


func before_each() -> void:
	hasard = RandomNumberGenerator.new()
	hasard.seed = 7
	butin = Butin.new(config)
	forge = Forge.new(config)


func _riche() -> Inventaire:
	var inventaire := Inventaire.new(config)
	inventaire.ajouter_ressources({"ressource.fer": 100000, "ressource.chene": 100000, "ressource.cuir": 100000})
	inventaire.or_possede = 10000000
	return inventaire


func test_ce_que_rapporte_chaque_palier() -> void:
	assert_almost_eq(config.multiplicateur_amelioration(0), 1.0, 0.0001)
	assert_almost_eq(config.multiplicateur_amelioration(5), 1.25, 0.0001)
	assert_almost_eq(config.multiplicateur_amelioration(10), 1.65, 0.0001, "Un objet +10 vaut 1,65 fois sa version de départ")


func test_le_materiau_depend_du_type_d_objet() -> void:
	assert_eq(butin.creer_objet("objet.lame_guet", 5, "standard", hasard).materiau(config), "ressource.fer")
	assert_eq(butin.creer_objet("objet.arc_chasseur", 5, "standard", hasard).materiau(config), "ressource.chene")
	assert_eq(butin.creer_objet("objet.bottes_rodeur", 5, "standard", hasard).materiau(config), "ressource.cuir")
	assert_eq(butin.creer_objet("objet.capuche_rodeur", 5, "standard", hasard).materiau(config), "ressource.fer")
	assert_eq(butin.creer_objet("objet.amulette_lucioles", 5, "standard", hasard).materiau(config), "ressource.fer")


func test_le_prix_d_une_amelioration() -> void:
	# Exemple du plan : passer une arme de niveau 10 en +5 coûte 14 fer et 5 × sa puissance en or.
	var arme := butin.creer_objet("objet.hache_bucheron", 10, "standard", hasard)
	arme.amelioration = 4
	var prix := forge.cout(arme)
	assert_eq(prix["ressource"], "ressource.fer")
	assert_eq(prix["quantite"], 14)
	assert_eq(prix["or"], 5 * arme.puissance_de_depart(config))


func test_ameliorer_augmente_les_valeurs_et_la_puissance() -> void:
	var arme := butin.creer_objet("objet.lame_guet", 10, "dore", hasard)
	var degats := arme.degats
	var stats := arme.statistiques.duplicate()
	var puissance := arme.puissance(config)
	var inventaire := _riche()
	var fer := inventaire.quantite("ressource.fer")
	assert_eq(forge.ameliorer(arme, inventaire, hasard), Forge.Resultat.REUSSITE, "+1 est garanti")
	assert_eq(arme.amelioration, 1)
	assert_eq(arme.nom_affiche(), "Lame du Guet +1")
	assert_almost_eq(arme.degats, degats * 1.05, 0.001)
	for nom: String in stats:
		assert_eq(arme.statistiques[nom], roundi(int(stats[nom]) * 1.05))
	assert_lt(inventaire.quantite("ressource.fer"), fer, "Les matériaux sont payés")
	for i in 4:
		forge.ameliorer(arme, inventaire, hasard)
	arme.amelioration = 10
	arme.appliquer_amelioration(config)
	assert_almost_eq(arme.degats, degats * 1.65, 0.001)
	assert_gt(arme.puissance(config), puissance, "La puissance augmente avec l'amélioration")


func test_un_echec_garde_le_palier_mais_coute_les_materiaux() -> void:
	var inventaire := _riche()
	var echecs := 0
	for i in 100:
		var arme := butin.creer_objet("objet.lame_guet", 10, "standard", hasard)
		arme.amelioration = 9
		arme.appliquer_amelioration(config)
		var fer := inventaire.quantite("ressource.fer")
		if forge.ameliorer(arme, inventaire, hasard) == Forge.Resultat.ECHEC:
			echecs += 1
			assert_eq(arme.amelioration, 9, "Un échec ne fait jamais perdre de palier")
		assert_lt(inventaire.quantite("ressource.fer"), fer, "Les matériaux sont payés, réussite ou échec")
	assert_gt(echecs, 80, "+10 n'a que 6 % de chances")


func test_les_chances_de_reussite_suivent_la_config() -> void:
	var inventaire := _riche()
	var reussites := 0
	for i in 2000:
		var arme := butin.creer_objet("objet.hache_bucheron", 1, "standard", hasard)
		arme.amelioration = 5
		if forge.ameliorer(arme, inventaire, hasard) == Forge.Resultat.REUSSITE:
			reussites += 1
	assert_almost_eq(reussites / 2000.0, 0.45, 0.04, "+6 : 45 %")


func test_impossible_sans_assez_de_materiaux_ou_au_maximum() -> void:
	var arme := butin.creer_objet("objet.lame_guet", 10, "standard", hasard)
	var pauvre := Inventaire.new(config)
	assert_eq(forge.ameliorer(arme, pauvre, hasard), Forge.Resultat.IMPOSSIBLE)
	assert_eq(arme.amelioration, 0)
	arme.amelioration = 10
	assert_true(forge.est_au_maximum(arme))
	assert_eq(forge.ameliorer(arme, _riche(), hasard), Forge.Resultat.IMPOSSIBLE)


func test_un_objet_ameliore_est_sauvegarde() -> void:
	var arme := butin.creer_objet("objet.lame_guet", 12, "epique", hasard)
	arme.amelioration = 7
	arme.appliquer_amelioration(config)
	var relu := Objet.depuis_dictionnaire(JSON.parse_string(JSON.stringify(arme.vers_dictionnaire())), config)
	assert_eq(relu.amelioration, 7)
	assert_almost_eq(relu.degats, arme.degats, 0.001)
	assert_eq(relu.statistiques, arme.statistiques)
	assert_eq(relu.puissance(config), arme.puissance(config))
	# Une ancienne sauvegarde sans palier se relit comme un objet +0.
	var ancien := arme.vers_dictionnaire()
	ancien.erase("amelioration")
	assert_eq(Objet.depuis_dictionnaire(ancien, config).amelioration, 0)


func test_le_recyclage_rend_des_materiaux() -> void:
	var inventaire := Inventaire.new(config)
	var bottes := butin.creer_objet("objet.bottes_paysan", 15, "dore", hasard)
	assert_eq(inventaire.materiaux_recyclage(bottes), {"ressource.cuir": 4}, "Doré niveau 15 : 1 + 2 + 1")
	var or_gagne := inventaire.recycler_objet(bottes)
	assert_gt(or_gagne, 0)
	assert_eq(inventaire.quantite("ressource.cuir"), 4)


func test_le_recyclage_automatique_filtre_par_materiau() -> void:
	var filtre := RecyclageAuto.new()
	filtre.regler(true, "epique")
	var arc := butin.creer_objet("objet.arc_chasseur", 3, "standard", hasard)
	var hache := butin.creer_objet("objet.hache_bucheron", 3, "standard", hasard)
	assert_true(filtre.doit_recycler(arc, config))
	filtre.cocher_materiau("ressource.chene", false)
	assert_false(filtre.doit_recycler(arc, config), "Le chêne n'est plus recyclé")
	assert_true(filtre.doit_recycler(hache, config), "Le fer l'est toujours")
	var relu := RecyclageAuto.depuis_dictionnaire(JSON.parse_string(JSON.stringify(filtre.vers_dictionnaire())))
	assert_false(relu.doit_recycler(arc, config))
