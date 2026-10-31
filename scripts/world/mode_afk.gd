class_name ModeAfk
extends RefCounted
## Mode AFK du joueur : le personnage cible et enchaîne seul les monstres autour de l'endroit
## où le mode a été activé (hors sous-boss), puis revient à ce point quand il n'y en a plus.

var actif := false
## Point d'activation : le centre du terrain de chasse.
var point := Vector3.ZERO


## Direction à suivre depuis « position » : vers le monstre le plus proche (dans le rayon autour du
## point d'activation), ou vers le point d'activation s'il n'y en a pas. Zéro quand le personnage
## est arrivé (assez près pour frapper, ou revenu à son point).
func direction(position: Vector3, portee_arme: float, arbre: SceneTree) -> Vector3:
	var rayon := Config.jeu.rayon_afk()
	var cible: Monstre = null
	var meilleure := INF
	for noeud in arbre.get_nodes_in_group(Monstre.GROUPE):
		var monstre := noeud as Monstre
		if not monstre.est_vivant() or monstre.rang == Combat.RANG_SOUS_BOSS:
			continue
		if distance_au_sol(monstre.global_position, point) > rayon:
			continue
		var distance := distance_au_sol(monstre.global_position, position)
		if distance < meilleure:
			cible = monstre
			meilleure = distance
	var arret := portee_arme * Config.jeu.part_portee_afk()
	var destination := point
	if cible != null:
		destination = cible.global_position
	else:
		arret = 0.5
	var vers := destination - position
	vers.y = 0.0
	if vers.length() <= arret:
		return Vector3.ZERO
	return vers.normalized()


static func distance_au_sol(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
