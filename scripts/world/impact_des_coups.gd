class_name ImpactDesCoups
extends RefCounted
## Le ressenti d'un coup du joueur qui porte : la caméra tremble (plus fort pour une arme lourde
## ou un critique), et le temps s'arrête une fraction de seconde sur les coups lourds et critiques.
## Réglages : config/combat.cfg, section [impact].


static func ressentir(arbre: SceneTree, critique: bool, lourd: bool) -> void:
	var config := Config.jeu
	var genre := "critique" if critique else ("lourde" if lourd else "normale")
	var camera := arbre.get_first_node_in_group(CameraSuiveuse.GROUPE) as CameraSuiveuse
	if camera != null:
		camera.secouer(config.combat("impact", "secousse_" + genre), config.combat("impact", "duree_secousse"))
	var arret := 0.0
	if critique:
		arret = config.combat("impact", "arret_critique")
	elif lourd:
		arret = config.combat("impact", "arret_lourd")
	if arret > 0.0:
		arreter_le_temps(arbre, arret)


## Le temps ralentit presque à l'arrêt pendant « duree » secondes (temps réel).
static func arreter_le_temps(arbre: SceneTree, duree: float) -> void:
	Engine.time_scale = Config.jeu.combat("impact", "vitesse_arret")
	arbre.create_timer(duree, true, false, true).timeout.connect(reprendre_le_temps)


static func reprendre_le_temps() -> void:
	Engine.time_scale = 1.0
