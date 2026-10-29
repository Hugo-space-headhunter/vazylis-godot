extends GutTest
## Mise en forme d'une partie pour la sauvegarde, et relecture.

var config: ConfigJeu


func before_all() -> void:
	config = ConfigJeu.charger()


func _partie_exemple() -> Partie:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = 5
	var butin := Butin.new(config)
	var partie := Partie.new()
	partie.personnage = IdentifiantsAssets.HEROS_FEMME
	partie.niveau = 12
	partie.xp = 340
	partie.statistiques.valeurs["force"] = 20
	partie.statistiques.valeurs["vitalite"] = 24
	partie.statistiques.points_libres = 4
	partie.inventaire = Inventaire.new(config)
	partie.inventaire.ajouter(butin.creer_objet("objet.arc_chasseur", 11, "epique", hasard))
	partie.inventaire.cases[7] = butin.creer_objet("objet.bottes_rodeur", 9, "dore", hasard)
	partie.inventaire.or_possede = 1234
	partie.equipement.equiper(butin.creer_objet("objet.lame_guet", 12, "mythique", hasard))
	partie.equipement.equiper(butin.creer_objet("objet.boucle_os", 10, "argente", hasard))
	partie.recyclage_auto.regler(true, "dore")
	partie.monstres_sans_dore = 123
	partie.monstres_sans_epique = 1500
	partie.sauvegarde_le = 1793250000.0
	return partie


func test_une_partie_relue_est_identique() -> void:
	var partie := _partie_exemple()
	var texte := JSON.stringify(partie.vers_dictionnaire())
	var relue := Partie.depuis_dictionnaire(JSON.parse_string(texte), config)
	assert_not_null(relue)
	assert_eq(relue.personnage, IdentifiantsAssets.HEROS_FEMME)
	assert_eq(relue.niveau, 12)
	assert_eq(relue.xp, 340)
	assert_eq(relue.statistiques.valeur("force"), 20)
	assert_eq(relue.statistiques.points_libres, 4)
	assert_eq(relue.inventaire.or_possede, 1234)
	assert_eq(relue.inventaire.objet(0).nom, "Arc de chasseur")
	assert_eq(relue.inventaire.objet(7).rarete, "dore", "Les objets gardent leur case")
	assert_null(relue.inventaire.objet(1))
	assert_eq(relue.equipement.arme().rarete, "mythique")
	assert_almost_eq(relue.equipement.arme().degats, partie.equipement.arme().degats, 0.0001)
	assert_not_null(relue.equipement.objet("boucle_oreille_1"))
	assert_true(relue.recyclage_auto.actif)
	assert_eq(relue.monstres_sans_epique, 1500)
	assert_eq(relue.sauvegarde_le, 1793250000.0)
	# Relire puis réécrire donne le même texte.
	assert_eq(JSON.stringify(relue.vers_dictionnaire()), texte)


func test_sauvegarde_vide_ou_d_une_autre_version() -> void:
	assert_null(Partie.depuis_dictionnaire(null, config))
	assert_null(Partie.depuis_dictionnaire({}, config))
	assert_null(Partie.depuis_dictionnaire({"version": 999}, config))


func test_un_objet_disparu_du_jeu_est_ignore() -> void:
	var donnees := _partie_exemple().vers_dictionnaire()
	donnees["sac"]["cases"][0]["famille"] = "objet.qui_n_existe_plus"
	var relue := Partie.depuis_dictionnaire(donnees, config)
	assert_not_null(relue)
	assert_null(relue.inventaire.objet(0))
	assert_not_null(relue.inventaire.objet(7))
