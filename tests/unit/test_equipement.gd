extends GutTest
## Objets portés : emplacements, échange avec le sac, totaux.

var config: ConfigJeu
var butin: Butin
var hasard: RandomNumberGenerator


func before_all() -> void:
	config = ConfigJeu.charger()


func before_each() -> void:
	butin = Butin.new(config)
	hasard = RandomNumberGenerator.new()
	hasard.seed = 11


func _objet(famille: String, niveau: int = 10, rarete: String = "standard") -> Objet:
	return butin.creer_objet(famille, niveau, rarete, hasard)


func test_equiper_et_remplacer() -> void:
	var equipement := Equipement.new()
	var premiere := _objet("objet.tunique_paysan")
	assert_null(equipement.equiper(premiere))
	var seconde := _objet("objet.brigandine_rodeur")
	assert_eq(equipement.equiper(seconde), premiere, "L'ancien plastron revient")
	assert_eq(equipement.objet("plastron"), seconde)


func test_un_objet_ne_va_que_dans_son_emplacement() -> void:
	var equipement := Equipement.new()
	var bottes := _objet("objet.bottes_paysan")
	assert_false(equipement.accepte("casque", bottes))
	assert_true(equipement.accepte("bottes", bottes))
	assert_eq(equipement.equiper(bottes, "casque"), bottes)
	assert_push_error("ne va pas")
	assert_null(equipement.objet("casque"))


func test_deux_boucles_d_oreilles() -> void:
	var equipement := Equipement.new()
	equipement.equiper(_objet("objet.boucle_os"))
	equipement.equiper(_objet("objet.boucle_os"))
	assert_not_null(equipement.objet("boucle_oreille_1"))
	assert_not_null(equipement.objet("boucle_oreille_2"))


func test_totaux_des_objets_portes() -> void:
	var equipement := Equipement.new()
	var plastron := _objet("objet.tunique_paysan", 20, "epique")
	var collier := _objet("objet.amulette_lucioles", 20, "dore")
	equipement.equiper(plastron)
	equipement.equiper(collier)
	assert_almost_eq(equipement.armure_totale(), plastron.armure, 0.001)
	var total := 0
	for valeur in equipement.statistiques_totales().values():
		total += valeur
	var attendu := 0
	for valeur in plastron.statistiques.values() + collier.statistiques.values():
		attendu += valeur
	assert_eq(total, attendu)
	assert_eq(equipement.bonus_totaux().size() > 0, true)


func test_sauvegarde_de_l_equipement() -> void:
	var equipement := Equipement.new()
	equipement.equiper(_objet("objet.hache_bucheron", 5, "mythique"))
	var copie := Equipement.depuis_dictionnaire(JSON.parse_string(JSON.stringify(equipement.vers_dictionnaire())), config)
	assert_eq(copie.arme().nom, "Hache de bûcheron")
	assert_eq(copie.arme().rarete, "mythique")


func test_statistiques_avec_les_objets() -> void:
	var stats := Statistiques.new()
	stats.valeurs["force"] = 4
	var total := stats.avec_bonus({"force": 6, "agilite": 2})
	assert_eq(total.valeur("force"), 10)
	assert_eq(total.valeur("agilite"), 2)
	assert_eq(stats.valeur("force"), 4, "Les points du joueur ne changent pas")
