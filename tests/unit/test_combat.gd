extends GutTest
## Formules de combat avec les statistiques, affinités des armes et calibrage des monstres.

var config: ConfigJeu
var sans_points: Statistiques


func before_all() -> void:
	config = ConfigJeu.charger()
	sans_points = Statistiques.new()


func _stats(force: int, agilite: int, vitalite: int, intelligence: int = 0) -> Statistiques:
	var stats := Statistiques.new()
	stats.valeurs = {"force": force, "agilite": agilite, "vitalite": vitalite, "intelligence": intelligence}
	return stats


func _arme(id: String) -> Dictionary:
	return config.arme(id)


func test_degats_de_l_arme_selon_son_type() -> void:
	# (10 + 3 × 10) × standard × multiplicateur du type
	assert_almost_eq(Combat.degats_arme(10, _arme("arme.epee_bouclier"), config), 36.0, 0.001)
	assert_almost_eq(Combat.degats_arme(10, _arme("arme.dagues"), config), 26.0, 0.001)
	assert_almost_eq(Combat.degats_arme(10, _arme("arme.hache_deux_mains"), config), 58.0, 0.001)


func test_force_et_affinite() -> void:
	# Épée à deux mains niveau 10 : (54 + 2 × 20 Force) × (1 + 0,3 % × 20) = 94 × 1,06
	var stats := _stats(20, 0, 0)
	assert_almost_eq(Combat.degats_coup(10, stats, _arme("arme.epee_deux_mains"), config), 99.64, 0.01)
	# Les dagues ont l'Agilité pour affinité : la Force ajoute des dégâts mais pas de bonus d'affinité.
	assert_almost_eq(Combat.degats_coup(10, stats, _arme("arme.dagues"), config), 66.0, 0.01)


func test_critique_selon_agilite_et_arme() -> void:
	assert_almost_eq(Combat.chance_critique(sans_points, _arme("arme.epee_bouclier"), config), 0.05, 0.0001)
	assert_almost_eq(Combat.chance_critique(_stats(0, 100, 0), _arme("arme.epee_bouclier"), config), 0.15, 0.0001)
	# Dagues : +10 %.
	assert_almost_eq(Combat.chance_critique(_stats(0, 100, 0), _arme("arme.dagues"), config), 0.25, 0.0001)
	# Plafond à 60 %.
	assert_almost_eq(Combat.chance_critique(_stats(0, 2000, 0), _arme("arme.dagues"), config), 0.6, 0.0001)
	assert_eq(Combat.multiplicateur_critique(_arme("arme.epee_deux_mains")), 2.0)
	assert_eq(Combat.multiplicateur_critique(_arme("arme.dagues")), 1.5)


func test_vitesse_d_attaque_plafonnee() -> void:
	assert_almost_eq(Combat.vitesse_attaque(sans_points, _arme("arme.dagues"), config), 1.6, 0.0001)
	assert_almost_eq(Combat.vitesse_attaque(_stats(0, 100, 0), _arme("arme.dagues"), config), 1.6 * 1.4, 0.0001)
	assert_almost_eq(Combat.vitesse_attaque(_stats(0, 1000, 0), _arme("arme.dagues"), config), 1.6 * 2.5, 0.0001)


func test_vie_defense_et_mana() -> void:
	var stats := _stats(0, 0, 10, 8)
	assert_almost_eq(Combat.pv_joueur(10, stats, config), 100.0 + 150.0 + 120.0, 0.001)
	# Bouclier : 2 par niveau, plus 0,5 par point de Vitalité.
	assert_almost_eq(Combat.defense_joueur(10, stats, _arme("arme.epee_bouclier"), config), 25.0, 0.001)
	assert_almost_eq(Combat.defense_joueur(10, stats, _arme("arme.arc"), config), 5.0, 0.001)
	assert_almost_eq(Combat.mana(stats, config), 40.0, 0.001)


func test_reduction_des_degats() -> void:
	assert_eq(Combat.reduction(0.0, 10, config), 0.0)
	assert_almost_eq(Combat.reduction(500.0, 10, config), 0.5, 0.0001)
	assert_almost_eq(Combat.reduction(100000.0, 10, config), 0.75, 0.0001)
	assert_eq(Combat.degats_subis(100.0, 10, 500.0, config), 50)


func test_la_hache_ignore_15_pourcent_de_la_defense() -> void:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = 1
	var hache := _arme("arme.hache_deux_mains").duplicate()
	hache["bonus_critique"] = -1.0
	var avec := Combat.coup_joueur(10, sans_points, hache, 500.0, 10, config, hasard)
	var sans_bonus := hache.duplicate()
	sans_bonus["ignore_defense"] = 0.0
	var sans := Combat.coup_joueur(10, sans_points, sans_bonus, 500.0, 10, config, hasard)
	assert_gt(avec["degats"], sans["degats"])


func test_le_bouclier_bloque_environ_10_pourcent() -> void:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = 7
	var blocages := 0
	for i in 10000:
		if Combat.bloque(_arme("arme.epee_bouclier"), hasard):
			blocages += 1
	assert_almost_eq(blocages / 10000.0, 0.1, 0.01)
	assert_false(Combat.bloque(_arme("arme.hache_deux_mains"), hasard))


func test_sans_points_les_armes_ont_une_force_proche() -> void:
	var reference := Combat.dps(10, sans_points, _arme("arme.epee_bouclier"), config)
	for id in config.ids_armes():
		assert_almost_eq(Combat.dps(10, sans_points, _arme(id), config) / reference, 1.1, 0.15, id)


func test_un_build_force_frappe_plus_fort_a_deux_mains_un_build_agilite_aux_dagues() -> void:
	var force := _stats(36, 0, 0)
	var agilite := _stats(0, 36, 0)
	var epee := _arme("arme.epee_deux_mains")
	var dagues := _arme("arme.dagues")
	assert_gt(Combat.dps(10, force, epee, config), Combat.dps(10, agilite, epee, config))
	assert_gt(Combat.vitesse_attaque(agilite, dagues, config), Combat.vitesse_attaque(force, dagues, config))
	assert_gt(Combat.chance_critique(agilite, dagues, config), Combat.chance_critique(force, dagues, config))


func test_le_joueur_moyen_tue_un_monstre_de_son_niveau_en_10_secondes() -> void:
	for niveau in [1, 5, 10, 50]:
		var moyen := Combat.joueur_moyen(niveau, config)
		var dps := Combat.dps(niveau, moyen["statistiques"], moyen["arme"], config, moyen["degats_arme"])
		assert_almost_eq(Combat.pv_monstre(niveau, config) / dps, 10.0, 0.001, "Niveau %d" % niveau)


func test_le_joueur_moyen_porte_un_equipement_complet() -> void:
	var moyen := Combat.joueur_moyen(10, config)
	# Arme standard de niveau 10 de qualité moyenne (85 %) : 40 × 0,9 × 0,85.
	assert_almost_eq(moyen["degats_arme"], 30.6, 0.01)
	# Armure : 10 × (1 + 0,6 + 0,5 + 0,4 + 0,4 + 0,3) × 0,85.
	assert_almost_eq(moyen["armure"], 27.2, 0.01)
	# Points de niveau (9 par statistique) + points des objets.
	assert_gt((moyen["statistiques"] as Statistiques).valeur("force"), 9)


func test_un_agressif_tue_le_joueur_moyen_en_60_secondes() -> void:
	var intervalle := 1.5
	for niveau in [1, 10, 50]:
		var moyen := Combat.joueur_moyen(niveau, config)
		var stats: Statistiques = moyen["statistiques"]
		var defense := Combat.defense_joueur(niveau, stats, moyen["arme"], config, moyen["armure"])
		var brut := Combat.degats_monstre(niveau, niveau, false, intervalle, config)
		var dps_subis := brut * (1.0 - Combat.reduction(defense, niveau, config)) / intervalle
		assert_almost_eq(Combat.pv_joueur(niveau, stats, config) / dps_subis, 60.0, 0.01, "Niveau %d" % niveau)


func test_les_passifs_frappent_deux_fois_moins_fort() -> void:
	var agressif := Combat.degats_monstre(5, 5, false, 1.5, config)
	assert_almost_eq(Combat.degats_monstre(5, 5, true, 1.5, config), agressif * 0.5, 0.001)


func test_monstre_bien_plus_haut_frappe_plus_fort() -> void:
	var normal := Combat.degats_monstre(20, 15, false, 1.5, config)
	assert_almost_eq(normal, Combat.degats_monstre(20, 20, false, 1.5, config), 0.001)
	assert_almost_eq(Combat.degats_monstre(20, 12, false, 1.5, config), normal * 1.15, 0.001)


func test_coups_critiques_doublent_a_deux_mains() -> void:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = 42
	var epee := _arme("arme.epee_deux_mains")
	var normal := roundi(Combat.degats_coup(10, sans_points, epee, config))
	var critiques := 0
	for i in 10000:
		var coup := Combat.coup_joueur(10, sans_points, epee, 0.0, 10, config, hasard)
		if coup["critique"]:
			critiques += 1
			assert_eq(coup["degats"], normal * 2)
		else:
			assert_eq(coup["degats"], normal)
	assert_almost_eq(critiques / 10000.0, 0.05, 0.01)


func test_chaque_arme_est_complete() -> void:
	assert_eq(config.ids_armes().size(), 5)
	for id in config.ids_armes():
		var arme := _arme(id)
		assert_true(str(arme["affinite"]) in Statistiques.NOMS, id)
		for cle in ["modele_main_droite", "modele_main_gauche"]:
			var modele := str(arme[cle])
			assert_true(modele.is_empty() or CatalogueAssets.contient(modele), "%s : %s" % [id, modele])


func test_chaque_monstre_de_la_config_a_un_modele_au_catalogue() -> void:
	assert_eq(config.ids_monstres().size(), 3)
	for id in config.ids_monstres():
		var monstre := config.monstre(id)
		assert_true(CatalogueAssets.contient(str(monstre["modele"])), id)
		assert_true(monstre["comportement"] in ["passif", "agressif"], id)
		assert_lte(int(monstre["niveau_min"]), int(monstre["niveau_max"]), id)


func test_les_bonus_des_objets_comptent() -> void:
	var stats := _stats(0, 0, 0)
	var epee := _arme("arme.epee_bouclier")
	var bonus := {"degats": 0.1, "chance_critique": 0.05, "degats_critiques": 0.2, "vitesse_attaque": 0.1, "vie": 0.04}
	assert_almost_eq(Combat.degats_coup(10, stats, epee, config, 50.0, bonus), 55.0, 0.001)
	assert_almost_eq(Combat.chance_critique(stats, epee, config, bonus), 0.1, 0.0001)
	assert_almost_eq(Combat.multiplicateur_critique(epee, bonus), 1.7, 0.0001)
	assert_almost_eq(Combat.vitesse_attaque(stats, epee, config, bonus), 1.21, 0.0001)
	assert_almost_eq(Combat.pv_joueur(10, stats, config, bonus), 250.0 * 1.04, 0.001)
	assert_almost_eq(Combat.defense_joueur(10, stats, epee, config, 30.0), 50.0, 0.001)
