class_name VeilleMonstres
extends Node
## Endort les monstres loin du joueur (ils ne bougent plus, ne sont plus animés ni dessinés)
## et les réveille quand il approche (config/performances.cfg [monstres]).
## Un seul nœud fait ce tri pour tous les monstres, quelques fois par seconde.

var _attente := 0.0


func _process(delta: float) -> void:
	_attente -= delta
	if _attente > 0.0:
		return
	_attente = Config.jeu.performance("monstres", "intervalle_verification")
	verifier()


## Endort ou réveille chaque monstre selon sa distance au joueur.
func verifier() -> void:
	var joueur := get_tree().get_first_node_in_group(Joueur.GROUPE) as Joueur
	if joueur == null:
		return
	var distance_max := Config.jeu.performance("monstres", "distance_sommeil")
	for noeud in get_tree().get_nodes_in_group(Monstre.GROUPE):
		var monstre := noeud as Monstre
		var ecart := Vector2(monstre.global_position.x - joueur.global_position.x,
			monstre.global_position.z - joueur.global_position.z).length()
		monstre.endormir(ecart > distance_max)


## Nombre de monstres éveillés (pour le panneau de mesure).
static func monstres_eveilles(arbre: SceneTree) -> int:
	return arbre.get_nodes_in_group(Monstre.GROUPE).filter(func(m: Monstre) -> bool: return not m.endormi).size()
