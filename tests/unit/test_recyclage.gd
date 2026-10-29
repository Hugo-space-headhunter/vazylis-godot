extends GutTest
## Recyclage automatique par filtres.

var config: ConfigJeu
var butin: Butin
var hasard: RandomNumberGenerator


func before_all() -> void:
	config = ConfigJeu.charger()


func before_each() -> void:
	butin = Butin.new(config)
	hasard = RandomNumberGenerator.new()


func _objet(famille: String, rarete: String) -> Objet:
	return butin.creer_objet(famille, 5, rarete, hasard)


func test_eteint_on_ne_recycle_rien() -> void:
	var filtre := RecyclageAuto.new()
	assert_false(filtre.doit_recycler(_objet("objet.lame_guet", "standard"), config))


func test_sous_dore_on_recycle_standard_et_argente() -> void:
	var filtre := RecyclageAuto.new()
	filtre.regler(true, "dore")
	assert_true(filtre.doit_recycler(_objet("objet.lame_guet", "standard"), config))
	assert_true(filtre.doit_recycler(_objet("objet.tunique_paysan", "argente"), config))
	assert_false(filtre.doit_recycler(_objet("objet.tunique_paysan", "dore"), config))
	assert_false(filtre.doit_recycler(_objet("objet.boucle_os", "transcendant"), config))


func test_par_type_d_objet() -> void:
	var filtre := RecyclageAuto.new()
	filtre.regler(true, "epique")
	filtre.cocher("bijou", false)
	assert_false(filtre.doit_recycler(_objet("objet.amulette_lucioles", "standard"), config), "Les bijoux sont décochés")
	assert_true(filtre.doit_recycler(_objet("objet.bottes_rodeur", "standard"), config))
	assert_eq(RecyclageAuto.type_de(_objet("objet.arc_chasseur", "standard")), "arme")
	assert_eq(RecyclageAuto.type_de(_objet("objet.cape_voyage", "standard")), "armure")


func test_sauvegarde_des_filtres() -> void:
	var filtre := RecyclageAuto.new()
	filtre.regler(true, "mythique")
	filtre.cocher("arme", false)
	var copie := RecyclageAuto.depuis_dictionnaire(JSON.parse_string(JSON.stringify(filtre.vers_dictionnaire())))
	assert_true(copie.actif)
	assert_eq(copie.rarete_limite, "mythique")
	assert_false(copie.types["arme"])
