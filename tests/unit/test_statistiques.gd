extends GutTest
## Répartition des points : + et −, validation définitive.

var stats: Statistiques


func before_each() -> void:
	stats = Statistiques.new()


func test_au_depart_aucun_point() -> void:
	assert_eq(stats.points_libres, 0)
	assert_false(stats.ajouter("force"))
	for nom in Statistiques.NOMS:
		assert_eq(stats.valeur(nom), 0)


func test_ajouter_puis_valider() -> void:
	stats.gagner_points(4)
	assert_true(stats.ajouter("force"))
	assert_true(stats.ajouter("force"))
	assert_true(stats.ajouter("agilite"))
	assert_eq(stats.points_restants(), 1)
	assert_eq(stats.valeur("force"), 0, "Pas encore validé")
	assert_eq(stats.valeur_apercu("force"), 2)
	stats.valider()
	assert_eq(stats.valeur("force"), 2)
	assert_eq(stats.valeur("agilite"), 1)
	assert_eq(stats.points_libres, 1, "Le point non dépensé se garde")


func test_on_ne_peut_pas_depasser_ses_points() -> void:
	stats.gagner_points(4)
	for i in 4:
		assert_true(stats.ajouter("vitalite"))
	assert_false(stats.ajouter("vitalite"))
	assert_eq(stats.points_restants(), 0)


func test_le_moins_ne_retire_que_les_points_en_attente() -> void:
	stats.gagner_points(4)
	stats.ajouter("force")
	stats.valider()
	assert_false(stats.retirer("force"), "Un point validé est définitif")
	stats.ajouter("force")
	assert_true(stats.retirer("force"))
	assert_eq(stats.valeur("force"), 1)


func test_annuler() -> void:
	stats.gagner_points(4)
	stats.ajouter("intelligence")
	stats.annuler()
	assert_eq(stats.valeur_apercu("intelligence"), 0)
	assert_eq(stats.points_restants(), 4)


func test_apercu_compte_les_points_en_attente() -> void:
	stats.gagner_points(4)
	stats.ajouter("force")
	assert_eq(stats.apercu().valeur("force"), 1)
	assert_eq(stats.valeur("force"), 0)


func test_joueur_moyen_un_point_par_statistique_et_par_niveau() -> void:
	var reference := Statistiques.joueur_moyen(11, ConfigJeu.charger())
	for nom in Statistiques.NOMS:
		assert_eq(reference.valeur(nom), 10)
