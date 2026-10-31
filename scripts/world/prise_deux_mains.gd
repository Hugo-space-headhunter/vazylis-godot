class_name PriseDeuxMains
extends Node
## Tient une arme à deux mains : la cinématique inverse (Godot calcule la position de l'épaule,
## du coude et du poignet pour qu'une main atteigne une cible) pose les mains sur la poignée.
##
## Deux tenues :
##   - TRAINE : l'arme est accrochée à la hanche, pointe au sol derrière ; les DEUX mains la tiennent ;
##   - ATTAQUE : l'arme est dans la main droite (animation de frappe) ; la main GAUCHE la rejoint.
## Où poser les mains sur l'arme : réglage « poignee_mains » du catalogue (tools/calculer_prise_deux_mains.gd).

enum Tenue { AUCUNE, ATTAQUE, TRAINE }

## Durée du passage d'une tenue à l'autre (les mains glissent au lieu de sauter).
const DUREE_TRANSITION := 0.15
## Où pointent les coudes (repère du personnage, qui regarde vers +Z ; sa droite est -X).
const COUDE_DROIT := Vector3(-0.9, 1.1, -0.3)
const COUDE_GAUCHE := Vector3(0.6, 1.0, 0.2)
const OS_BRAS := {
	"droite": ["upperarm_r", "lowerarm_r", "hand_r"],
	"gauche": ["upperarm_l", "lowerarm_l", "hand_l"],
}

var tenue := Tenue.AUCUNE
var _ik := {}
var _transition: Tween


## Prépare la cinématique inverse sur le porteur, avec les cibles posées sur l'arme.
## Sans « poignee_mains » au catalogue (ou sans squelette), rien n'est fait.
func installer(porteur: ModeleAsset, arme: ModeleAsset, poignees: Dictionary) -> void:
	retirer()
	var squelette := porteur.squelette()
	if squelette == null or poignees.is_empty() or arme.provisoire:
		return
	for cote: String in OS_BRAS:
		if not poignees.has(cote):
			continue
		var cible := Marker3D.new()
		cible.name = "Main_" + cote
		cible.position = poignees[cote]
		arme.ajouter_au_modele(cible)
		var coude := Marker3D.new()
		coude.name = "Coude_" + cote
		coude.position = COUDE_DROIT if cote == "droite" else COUDE_GAUCHE
		porteur.add_child(coude)
		var ik := TwoBoneIK3D.new()
		ik.name = "Prise_" + cote
		squelette.add_child(ik)
		ik.setting_count = 1
		var os_bras: Array = OS_BRAS[cote]
		ik.set_root_bone_name(0, os_bras[0])
		ik.set_middle_bone_name(0, os_bras[1])
		ik.set_end_bone_name(0, os_bras[2])
		ik.influence = 0.0
		_ik[cote] = {"ik": ik, "cible": cible, "coude": coude}
	tenue = Tenue.AUCUNE
	# L'arme n'est peut-être pas encore accrochée au personnage : on relie les cibles juste après.
	relier.call_deferred()


## Relie chaque main à sa cible. À refaire quand l'arme change de point d'attache (hanche ↔ main) :
## le chemin vers la cible change avec elle.
func relier() -> void:
	for cote: String in _ik:
		var reglage: Dictionary = _ik[cote]
		var ik: TwoBoneIK3D = reglage["ik"]
		if is_instance_valid(ik) and ik.is_inside_tree() and reglage["cible"].is_inside_tree():
			ik.set_target_node(0, ik.get_path_to(reglage["cible"]))
			ik.set_pole_node(0, ik.get_path_to(reglage["coude"]))


func retirer() -> void:
	for cote: String in _ik:
		for cle in ["ik", "cible", "coude"]:
			var noeud: Node = _ik[cote][cle]
			if is_instance_valid(noeud):
				noeud.queue_free()
	_ik.clear()
	tenue = Tenue.AUCUNE


func est_installee() -> bool:
	return not _ik.is_empty()


## Change de tenue en douceur : quelles mains se posent sur l'arme.
func regler(nouvelle: Tenue) -> void:
	if nouvelle == tenue or _ik.is_empty():
		return
	tenue = nouvelle
	var poids := {
		"droite": 1.0 if nouvelle == Tenue.TRAINE else 0.0,
		"gauche": 1.0 if nouvelle != Tenue.AUCUNE else 0.0,
	}
	if _transition != null:
		_transition.kill()
	_transition = create_tween().set_parallel()
	for cote: String in _ik:
		_transition.tween_property(_ik[cote]["ik"], "influence", poids[cote], DUREE_TRANSITION)


## Poids actuel de la main (0 = libre, 1 = posée sur l'arme), pour les tests.
func poids_main(cote: String) -> float:
	return float(_ik[cote]["ik"].influence) if _ik.has(cote) else 0.0
