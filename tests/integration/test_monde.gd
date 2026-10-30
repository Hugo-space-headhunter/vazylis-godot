extends GutTest
## Le monde : on simule des doigts sur l'écran et on vérifie que le personnage réagit.

const SCENE := "res://scenes/monde/monde.tscn"

var terrain: Node3D
var joueur: Joueur
var commandes: CommandesTactiles
var camera: CameraSuiveuse


func before_each() -> void:
	terrain = load(SCENE).instantiate()
	add_child_autofree(terrain)
	joueur = terrain.get_node("Joueur")
	commandes = terrain.get_node("Interface/CommandesTactiles")
	camera = terrain.get_node("CameraSuiveuse")
	await wait_physics_frames(5)


func _toucher(index: int, position_ecran: Vector2, appuye: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position_ecran
	event.pressed = appuye
	commandes._input(event)


func _glisser(index: int, position_ecran: Vector2, relatif: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position_ecran
	event.relative = relatif
	commandes._input(event)


func test_au_depart_le_personnage_est_au_repos() -> void:
	assert_eq(joueur.modele().animation_en_cours(), "idle")
	assert_false(joueur.modele().provisoire)


func test_pousser_le_joystick_a_fond_fait_courir_vers_l_avant() -> void:
	var depart := joueur.global_position
	_toucher(0, Vector2(360, 500), true)
	_glisser(0, Vector2(360, 300), Vector2(0, -200))
	assert_almost_eq(commandes.direction.length(), 1.0, 0.001)
	await wait_physics_frames(40)
	assert_lt(joueur.global_position.z, depart.z - 1.0, "Le personnage devrait avancer vers -Z")
	assert_eq(joueur.modele().animation_en_cours(), "run")

	_toucher(0, Vector2(360, 300), false)
	assert_eq(commandes.direction, Vector2.ZERO)
	await wait_physics_frames(20)
	assert_eq(joueur.modele().animation_en_cours(), "idle")
	assert_almost_eq(Vector3(joueur.velocity.x, 0, joueur.velocity.z).length(), 0.0, 0.01)


func test_pousser_un_peu_fait_marcher() -> void:
	_toucher(0, Vector2(360, 500), true)
	_glisser(0, Vector2(400, 500), Vector2(40, 0))
	await wait_physics_frames(20)
	assert_eq(joueur.modele().animation_en_cours(), "walk")
	assert_gt(joueur.global_position.x, 0.1, "Le personnage devrait aller vers la droite")


func test_deuxieme_doigt_tourne_la_camera() -> void:
	var angle_depart := camera.angle()
	_toucher(0, Vector2(200, 500), true)
	_toucher(1, Vector2(500, 400), true)
	_glisser(1, Vector2(600, 400), Vector2(100, 0))
	assert_ne(camera.angle(), angle_depart)
	assert_eq(commandes.direction, Vector2.ZERO, "Le deuxième doigt ne doit pas bouger le joystick")


func test_toucher_le_bouton_ne_lance_pas_le_joystick() -> void:
	var bouton: Button = terrain.get_node("Interface/OutilsTest/BoutonPersonnage")
	var centre := bouton.get_global_rect().get_center()
	_toucher(0, centre, true)
	_glisser(0, centre + Vector2(0, 100), Vector2(0, 100))
	assert_eq(commandes.direction, Vector2.ZERO)


func test_le_bouton_change_de_personnage() -> void:
	var bouton: Button = terrain.get_node("Interface/OutilsTest/BoutonPersonnage")
	bouton.pressed.emit()
	assert_eq(joueur.personnage, IdentifiantsAssets.HEROS_FEMME)
	assert_false(joueur.modele().provisoire)
	bouton.pressed.emit()
	assert_eq(joueur.personnage, IdentifiantsAssets.HEROS_HOMME)


func test_bouton_test_niveau_et_fenetre_des_statistiques() -> void:
	var bouton_niveau: Button = terrain.get_node("Interface/OutilsTest/Niveau")
	var bouton_stats: Button = terrain.get_node("Interface/BoutonStatistiques")
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreStatistiques")
	bouton_niveau.pressed.emit()
	assert_eq(joueur.niveau(), 2)
	assert_eq(joueur.statistiques.points_libres, 4)
	assert_true(bouton_stats.get_node("Pastille").visible, "La pastille signale les points à répartir")

	bouton_stats.pressed.emit()
	assert_true(fenetre.visible)
	for i in 3:
		fenetre._modifier("force", true)
	fenetre._modifier("force", false)
	fenetre._modifier("agilite", true)
	assert_eq(joueur.statistiques.points_restants(), 1)
	fenetre._sur_valider()
	assert_eq(joueur.statistiques.valeur("force"), 2)
	assert_eq(joueur.statistiques.valeur("agilite"), 1)

	# La fenêtre ouverte empêche le joystick de démarrer dessous.
	var centre := fenetre.get_global_rect().get_center()
	_toucher(0, centre, true)
	_glisser(0, centre + Vector2(0, 100), Vector2(0, 100))
	assert_eq(commandes.direction, Vector2.ZERO)
	_toucher(0, centre, false)

	# Fermer abandonne les points en attente, jamais les points validés.
	fenetre._modifier("vitalite", true)
	fenetre.fermer()
	assert_false(fenetre.visible)
	assert_eq(joueur.statistiques.points_restants(), 1)
	assert_eq(joueur.statistiques.valeur("force"), 2)


func test_au_depart_on_porte_l_epee_et_ecu_de_milicien() -> void:
	assert_eq(joueur.equipement.arme().nom, "Épée et écu de milicien")
	assert_eq(joueur.id_arme, "arme.epee_bouclier")
	assert_false(terrain.get_node("Interface/OutilsTest").has_node("Arme"), "Le bouton de test Arme a disparu")


func test_le_sac_contient_une_arme_de_chaque_type_au_depart() -> void:
	assert_eq(joueur.inventaire.nombre_objets(), 5)
	var types := {}
	for i in 5:
		types[joueur.inventaire.objet(i).type_arme] = true
	assert_eq(types.size(), 5)


func test_bouton_butin_et_fenetre_du_sac() -> void:
	var bouton_butin: Button = terrain.get_node("Interface/OutilsTest/Butin")
	var bouton_sac: Button = terrain.get_node("Interface/BoutonSac")
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreSac")
	bouton_butin.pressed.emit()
	assert_eq(joueur.inventaire.nombre_objets(), 11, "Un objet de chaque rareté en plus")
	bouton_sac.pressed.emit()
	assert_true(fenetre.visible)
	fenetre.choisir("sac", 10)
	var fiche: FicheObjet = fenetre._fiche
	await wait_physics_frames(1)
	assert_gt(fiche.get_child_count(), 3, "La fiche montre l'objet touché")
	assert_eq((fiche.get_child(0) as Label).text, joueur.inventaire.objet(10).nom)
	fenetre.fermer_fenetre()
	assert_false(fenetre.visible)


func test_sac_plein_l_objet_est_recycle() -> void:
	var hasard := RandomNumberGenerator.new()
	while not joueur.inventaire.est_plein():
		joueur.recevoir_objet(joueur.butin.creer_objet("objet.boucle_os", 1, "standard", hasard))
	var or_avant := joueur.inventaire.or_possede
	var annonces := terrain.get_node("Interface/Annonces").get_child_count()
	watch_signals(joueur)
	joueur.recevoir_objet(joueur.butin.creer_objet("objet.lame_guet", 10, "dore", hasard))
	assert_gt(joueur.inventaire.or_possede, or_avant)
	assert_eq(terrain.get_node("Interface/Annonces").get_child_count(), annonces + 1, "Un message prévient")


func test_equiper_et_retirer_depuis_la_fenetre_du_sac() -> void:
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreSac")
	terrain.get_node("Interface/BoutonSac").pressed.emit()
	await wait_physics_frames(2)
	# La case 2 contient la Lame du Guet (épée à deux mains), d'après le sac de départ.
	var case_lame := -1
	for i in 5:
		if joueur.inventaire.objet(i).type_arme == "arme.epee_deux_mains":
			case_lame = i
	var ancienne := joueur.equipement.arme()
	fenetre.choisir("sac", case_lame)
	assert_eq(fenetre._action.text, "Équiper")
	fenetre._sur_action()
	assert_eq(joueur.id_arme, "arme.epee_deux_mains")
	assert_eq(joueur.inventaire.objet(case_lame), ancienne, "L'ancienne arme prend la place dans le sac")

	# Glisser-déposer : une armure du sac vers la case « casque » (mauvaise case) va quand même sur le plastron.
	var hasard := RandomNumberGenerator.new()
	var tunique := joueur.butin.creer_objet("objet.tunique_paysan", 5, "dore", hasard)
	var case_tunique := joueur.inventaire.ajouter(tunique)
	var pv_avant := joueur.pv_max
	fenetre.deposer({"lieu": "sac", "cle": case_tunique}, {"lieu": "equipement", "cle": "casque"})
	assert_eq(joueur.equipement.objet("plastron"), tunique)
	assert_gt(joueur.defense(), 0.0, "L'armure compte dans la défense")

	# Retirer : le plastron retourne dans le sac.
	fenetre.choisir("equipement", "plastron")
	assert_eq(fenetre._action.text, "Retirer")
	fenetre._sur_action()
	assert_null(joueur.equipement.objet("plastron"))
	assert_true(joueur.inventaire.cases.has(tunique))

	# L'arme ne se retire pas, elle se remplace.
	fenetre.choisir("equipement", "arme")
	assert_false(fenetre._action.visible)


func test_glisser_pour_ranger_le_sac() -> void:
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreSac")
	terrain.get_node("Interface/BoutonSac").pressed.emit()
	var premier := joueur.inventaire.objet(0)
	fenetre.deposer({"lieu": "sac", "cle": 0}, {"lieu": "sac", "cle": 20})
	assert_eq(joueur.inventaire.objet(20), premier)
	assert_null(joueur.inventaire.objet(0))


func test_recyclage_manuel_et_automatique() -> void:
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreSac")
	terrain.get_node("Interface/BoutonSac").pressed.emit()
	await wait_physics_frames(2)
	var hasard := RandomNumberGenerator.new()
	# À la main : le bouton Recycler rapporte de l'or et vide la case.
	var annonces := terrain.get_node("Interface/Annonces").get_child_count()
	fenetre.choisir("sac", 0)
	assert_true(fenetre._recycler.visible)
	fenetre._sur_recycler()
	assert_null(joueur.inventaire.objet(0))
	assert_gt(joueur.inventaire.or_possede, 0)
	assert_eq(terrain.get_node("Interface/Annonces").get_child_count(), annonces + 1)

	# Automatique : « sous Doré » recycle un argenté qui tombe, garde un doré.
	fenetre._filtre_rarete.select(2)
	fenetre._sur_filtre_rarete(2)
	assert_true(joueur.recyclage_auto.actif)
	assert_eq(joueur.recyclage_auto.rarete_limite, "dore")
	var avant := joueur.inventaire.nombre_objets()
	joueur.recevoir_objet(joueur.butin.creer_objet("objet.bottes_paysan", 3, "argente", hasard))
	assert_eq(joueur.inventaire.nombre_objets(), avant, "L'argenté est recyclé tout de suite")
	joueur.recevoir_objet(joueur.butin.creer_objet("objet.bottes_paysan", 3, "dore", hasard))
	assert_eq(joueur.inventaire.nombre_objets(), avant + 1, "Le doré va dans le sac")

	# Recycler le sac : les armes standard de départ partent, le doré reste.
	fenetre._sur_recycler_le_sac()
	assert_eq(joueur.inventaire.nombre_objets(), 1)


func test_on_part_de_vazylis_entouree_des_pres() -> void:
	await wait_physics_frames(40)
	assert_eq(terrain.zone_actuelle().nom, "Vazylis")
	var pres: Zone = terrain.get_node("Zones/PresDeVazylis")
	assert_true(pres.contient(Vector3(0, 0, -40)))
	assert_eq(pres.titre(), "Les Prés de Vazylis  (niv. 1–10)")
	joueur.global_position = Vector3(-9, 0, -20)
	await wait_physics_frames(40)
	assert_eq(terrain.zone_actuelle(), pres, "On annonce les Prés en sortant de la ville")


func test_les_monstres_des_pres_et_le_pomelin_royal_apparaissent() -> void:
	await wait_physics_frames(5)
	var noms := {}
	for monstre: Monstre in get_tree().get_nodes_in_group(Monstre.GROUPE):
		noms[monstre.id_monstre] = true
		assert_gt(monstre.global_position.length(), 18.0, "Aucun monstre dans Vazylis")
	for id in Config.jeu.ids_monstres():
		assert_true(noms.has(id), "%s manque" % id)


func test_le_bouton_afk_active_et_coupe_le_mode_afk() -> void:
	var bouton: Button = terrain.get_node("Interface/BoutonAFK")
	assert_true(bouton.is_in_group(CommandesTactiles.GROUPE_UI))
	bouton.button_pressed = true
	assert_true(joueur.afk)
	assert_eq(joueur.mode, Joueur.Mode.COMBAT)
	terrain.get_node("Interface/BoutonsMode/Pied").pressed.emit()
	assert_false(joueur.afk)
	assert_false(bouton.button_pressed, "Le bouton suit l'état du mode AFK")


func test_le_sac_affiche_les_ressources() -> void:
	joueur.recevoir_ressources({"ressource.fer": 4})
	terrain.get_node("Interface/BoutonSac").pressed.emit()
	await wait_physics_frames(2)
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreSac")
	var textes := []
	for ligne in fenetre._ressources.get_children():
		textes.append((ligne.get_child(1) as Label).text)
	assert_has(textes, "Fer 4")
	assert_has(textes, "Cuir 0")


func test_le_bois_des_lucioles_est_au_nord_et_plus_sombre() -> void:
	var bois: Zone = terrain.get_node("Zones/BoisDesLucioles")
	assert_eq(bois.titre(), "Le Bois des Lucioles  (niv. 11–20)")
	var lumiere_depart: float = terrain.get_node("Soleil").light_energy
	joueur.global_position = Vector3(0, 0.1, -90)
	await wait_until(func(): return terrain.zone_actuelle() == bois, 2.0)
	assert_eq(terrain.zone_actuelle(), bois)
	await wait_seconds(1.7)
	assert_lt(terrain.get_node("Soleil").light_energy, lumiere_depart, "La lumière baisse dans le Bois")
	assert_gt(terrain.get_node("Zones/BoisDesLucioles/Lucioles").get_child_count(), 5, "Des essaims de lucioles")


func test_les_ruines_du_guet_sont_au_nord_du_bois() -> void:
	var ruines: Zone = terrain.get_node("Zones/RuinesDuGuet")
	assert_eq(ruines.titre(), "Les Ruines du Guet  (niv. 21–30)")
	joueur.global_position = Vector3(0, 0.1, -170)
	await wait_until(func(): return terrain.zone_actuelle() == ruines, 2.0)
	assert_eq(terrain.zone_actuelle(), ruines)
	var gardien_present := false
	for monstre: Monstre in get_tree().get_nodes_in_group(Monstre.GROUPE):
		gardien_present = gardien_present or monstre.id_monstre == "monstre.gardien_sans_visage"
	assert_true(gardien_present, "Le Gardien sans visage attend dans sa cour")


func test_chaque_monstre_apparait_dans_sa_zone() -> void:
	await wait_physics_frames(5)
	var zones := terrain.get_node("Zones").get_children()
	for monstre: Monstre in get_tree().get_nodes_in_group(Monstre.GROUPE):
		var dedans := ""
		for zone: Zone in zones:
			if zone.name != "Vazylis" and zone.contient(monstre.global_position):
				dedans = zone.nom
		var attendu: Zone = monstre.get_parent().get_parent()
		assert_eq(dedans, attendu.nom, "%s apparaît hors de sa zone, en %s" % [monstre.id_monstre, monstre.global_position])


func test_la_lisiere_pourpre_ferme_la_zone_1() -> void:
	var lisiere: Zone = terrain.get_node("Zones/LisierePourpre")
	assert_eq(lisiere.titre(), "La Lisière pourpre  (niv. 31–40)")
	joueur.global_position = Vector3(0, 0.1, -250)
	await wait_until(func(): return terrain.zone_actuelle() == lisiere, 2.0)
	assert_eq(terrain.zone_actuelle(), lisiere)
	assert_gt(terrain.get_node("Zones/LisierePourpre/Brume").get_child_count(), 5, "De la brume pourpre")
	# Les 4 sous-zones de la zone 1 se suivent sans trou, de Vazylis jusqu'à la Lisière.
	for z in range(20, -315, -5):
		var couverte := false
		for zone: Zone in terrain.get_node("Zones").get_children():
			couverte = couverte or zone.contient(Vector3(0, 0, z))
		assert_true(couverte, "Le chemin vers le nord passe par une zone en z = %d" % z)


func test_la_forge_de_vazylis() -> void:
	var forge: PosteForge = terrain.get_node("Zones/Vazylis/Forge")
	var bouton: Button = terrain.get_node("Interface/BoutonForge")
	var fenetre: PanelContainer = terrain.get_node("Interface/FenetreForge")
	await wait_physics_frames(40)
	assert_false(bouton.visible, "Loin de l'enclume, pas de bouton Forge")
	# On s'approche de l'enclume : le bouton apparaît.
	joueur.global_position = forge.global_position + Vector3(1.5, 0.1, 1.0)
	await wait_physics_frames(40)
	assert_true(bouton.visible, "Près de l'enclume, le bouton Forge apparaît")
	bouton.pressed.emit()
	await wait_physics_frames(2)
	assert_true(fenetre.visible)
	var arme := joueur.equipement.arme()
	assert_eq(fenetre.objet_choisi(), arme, "L'arme portée est proposée en premier")
	joueur.recevoir_ressources({"ressource.fer": 50})
	joueur.inventaire.or_possede = 1000
	var degats := arme.degats
	fenetre._sur_ameliorer()
	assert_eq(arme.amelioration, 1, "+1 est garanti")
	assert_gt(arme.degats, degats)
	assert_eq(fenetre._resultat.text, "Réussite ! Épée et écu de milicien +1")
	assert_eq(forge.get_node("Enclume/Dessus").get_child_count(), 1, "Des étincelles jaillissent de l'enclume")
	assert_lt(joueur.inventaire.quantite("ressource.fer"), 50)
	# Sans assez de matériaux, le bouton Améliorer est grisé.
	joueur.inventaire.ressources["ressource.fer"] = 0
	fenetre._rafraichir()
	assert_true(fenetre._ameliorer.disabled)
	# On s'éloigne : la fenêtre se ferme et le bouton disparaît.
	joueur.global_position = Vector3(0, 0.1, 4)
	await wait_physics_frames(40)
	assert_false(fenetre.visible)
	assert_false(bouton.visible)


func test_les_monstres_loin_du_joueur_dorment() -> void:
	var veille: VeilleMonstres = terrain.get_node("VeilleMonstres")
	await wait_physics_frames(5)
	veille.verifier()
	var distance := Config.jeu.performance("monstres", "distance_sommeil")
	var eveilles := 0
	for monstre: Monstre in get_tree().get_nodes_in_group(Monstre.GROUPE):
		var loin := Vector2(monstre.global_position.x - joueur.global_position.x, monstre.global_position.z - joueur.global_position.z).length() > distance
		assert_eq(monstre.endormi, loin, "%s à sa distance" % monstre.id_monstre)
		assert_eq(monstre.visible, not loin)
		if not loin:
			eveilles += 1
	assert_lt(eveilles, 40, "Depuis Vazylis, la plupart des monstres dorment")
	# Le joueur part dans la Lisière : ses monstres se réveillent, ceux des Prés s'endorment.
	joueur.global_position = Vector3(0, 0.1, -290)
	veille.verifier()
	var krag_eveille := false
	for monstre: Monstre in get_tree().get_nodes_in_group(Monstre.GROUPE):
		if monstre.id_monstre == "monstre.krag":
			krag_eveille = not monstre.endormi
		if monstre.id_monstre == "monstre.cochonnet_suie":
			assert_true(monstre.endormi)
	assert_true(krag_eveille, "Krâg se réveille quand on approche")


func test_le_panneau_de_mesure() -> void:
	var panneau: Label = terrain.get_node("Interface/CompteurFPS/Marges/Texte")
	assert_false(panneau.texte_mesures().contains("Dessin"), "Au départ : juste les images par seconde")
	var clic := InputEventMouseButton.new()
	clic.button_index = MOUSE_BUTTON_LEFT
	clic.pressed = true
	panneau.gui_input.emit(clic)
	var texte: String = panneau.texte_mesures()
	assert_true(texte.contains("Dessin"))
	assert_true(texte.contains("Monstres éveillés"))
	panneau.gui_input.emit(clic)
	assert_false(panneau.detaille, "Toucher à nouveau referme le détail")
