extends GutTest
## Panoplies de la zone 1 : pièces, paliers de bonus et pièces lâchées par les sous-boss.

var config: ConfigJeu
var hasard: RandomNumberGenerator
var butin: Butin


func before_all() -> void:
	config = ConfigJeu.charger()


func before_each() -> void:
	hasard = RandomNumberGenerator.new()
	hasard.seed = 73
	butin = Butin.new(config)


func _porter(equipement: Equipement, familles: Array) -> void:
	for famille: String in familles:
		equipement.equiper(butin.creer_objet(famille, 10, "standard", hasard))


func test_les_4_panoplies_de_la_zone_1() -> void:
	assert_eq(config.ids_panoplies().size(), 4)
	var attendu := {"panoplie.couronne_verger": 3, "panoplie.epines_gueule_fleur": 4, "panoplie.rempart_guet": 4, "panoplie.lame_krag": 4}
	for id: String in attendu:
		assert_eq(Panoplies.nombre_de_pieces(id, config), attendu[id], id)
		var sous_boss := str(config.panoplie(id)["sous_boss"])
		assert_true(sous_boss in config.ids_monstres(), "%s : sous-boss %s" % [id, sous_boss])
		assert_eq(config.panoplie_du_sous_boss(sous_boss), id)


func test_les_pieces_ne_tombent_pas_des_monstres_ordinaires() -> void:
	for i in 300:
		var famille := butin.tirer_famille(1, hasard)
		assert_eq(str(config.famille_objet(famille).get("panoplie", "")), "", famille)


func test_deux_pieces_donnent_le_premier_palier() -> void:
	var equipement := Equipement.new()
	_porter(equipement, ["objet.coiffe_verger"])
	assert_eq(Panoplies.bonus(equipement, config)["statistiques"], {}, "Une seule pièce : rien")
	_porter(equipement, ["objet.bottes_verger"])
	var bonus := Panoplies.bonus(equipement, config)
	assert_eq(bonus["statistiques"], {"vitalite": 15})
	assert_eq(bonus["effets"], [])
	var sans := 0
	for objet: Objet in equipement.objets.values():
		sans += int(objet.statistiques.get("vitalite", 0))
	assert_eq(int(equipement.statistiques_totales(config).get("vitalite", 0)), sans + 15)
	assert_eq(int(equipement.statistiques_totales().get("vitalite", 0)), sans, "Sans config : les objets seuls")


func test_la_panoplie_complete_donne_son_effet() -> void:
	var equipement := Equipement.new()
	_porter(equipement, ["objet.coiffe_verger", "objet.bottes_verger", "objet.ceinture_verger"])
	var bonus := Panoplies.bonus(equipement, config)
	assert_eq(bonus["effets"], ["regain"])
	assert_almost_eq(float(bonus["bonus"]["vie"]), 0.05, 0.0001)
	assert_eq(equipement.effets(config), ["regain"])


func test_les_premiers_paliers_de_plusieurs_panoplies_se_cumulent() -> void:
	var equipement := Equipement.new()
	_porter(equipement, ["objet.heaume_guet", "objet.cuirasse_guet", "objet.gants_epines", "objet.bottes_epines"])
	var bonus := Panoplies.bonus(equipement, config)
	assert_eq(bonus["statistiques"], {"vitalite": 20, "agilite": 15})
	assert_eq(bonus["effets"], [])


func test_un_sous_boss_lache_des_pieces_de_sa_panoplie() -> void:
	var pieces := 0
	var total := 0
	for i in 300:
		var gains: Dictionary = butin.tirer(Combat.RANG_SOUS_BOSS, 30, 1, hasard, "", "monstre.gardien_sans_visage")
		for objet: Objet in gains["objets"]:
			total += 1
			var panoplie := objet.panoplie(config)
			assert_true(panoplie in ["", "panoplie.rempart_guet"], "Seulement sa propre panoplie")
			if panoplie == "panoplie.rempart_guet":
				pieces += 1
	assert_almost_eq(pieces / float(total), 0.5, 0.07, "Environ la moitié des objets")


func test_les_paliers_se_lisent_en_clair() -> void:
	var paliers: Array = config.panoplie("panoplie.couronne_verger")["paliers"]
	assert_eq(Panoplies.decrire_palier(paliers[0], config), "2 pièces : +15 Vitalité")
	assert_eq(Panoplies.decrire_palier(paliers[1], config), "3 pièces : +5 % vie, Regain (Régénère 1 % de vie par seconde hors combat)")
