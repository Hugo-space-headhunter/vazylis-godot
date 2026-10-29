extends SceneTree
## Outil : calcule comment tenir une arme à un moment précis d'une animation
## (par exemple l'impact d'un coup, ou la pose de repos), en donnant la direction voulue.
## Les lignes obtenues vont dans « placements » de l'arme, dans assets/catalogue.cfg.
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/calculer_prise_pose.gd -- \
##     res://assets/models/weapon/claymore/claymore.glb lame 1.4 - Idle 0.0 r 0,-0.55,-1 1,0,0
##
## Arguments : <modèle> <lame|manche|centre> <longueur en m> <axe ou -> <animation> <moment 0 à 1>
##             <main r ou l> <direction de la pointe> <direction secondaire>
## Les directions sont dans le repère du personnage : +Z devant lui, +Y en haut, +X à sa gauche.
## Pour un arc (type centre), la direction secondaire est celle de la corde.

const Prise := preload("res://tools/calculer_prise.gd")
const PERSONNAGE := "res://assets/models/character/heros_homme/heros_homme.gltf"
const BIBLIOTHEQUES := {
	"catalogue": "res://assets/models/animation/bibliotheque_ual1/bibliotheque_ual1.glb",
	"ual2": "res://assets/models/animation/bibliotheque_ual2/bibliotheque_ual2.glb",
}

var _etape := 0
var _personnage: Node3D
var _arguments: PackedStringArray


func _process(_delta: float) -> bool:
	_etape += 1
	if _etape == 1:
		_arguments = OS.get_cmdline_user_args()
		if _arguments.size() < 9:
			print("Usage : -- <modèle> <type> <longueur> <axe|-> <animation> <moment> <r|l> <pointe x,y,z> <secondaire x,y,z>")
			quit(1)
			return false
		_personnage = load(PERSONNAGE).instantiate()
		root.add_child(_personnage)
		var lecteur := AnimationPlayer.new()
		_personnage.add_child(lecteur)
		for nom in BIBLIOTHEQUES:
			lecteur.add_animation_library(nom, load(BIBLIOTHEQUES[nom]))
		var animation := _arguments[4]
		for nom in BIBLIOTHEQUES:
			if lecteur.has_animation(nom + "/" + animation):
				animation = nom + "/" + animation
		lecteur.play(animation)
		lecteur.seek(float(_arguments[5]) * lecteur.current_animation_length, true)
		lecteur.pause()
	elif _etape == 3:
		_calculer()
		quit(0)
	return false


func _calculer() -> void:
	var axes := {"x": Vector3.RIGHT, "y": Vector3.UP, "z": Vector3.BACK}
	var axe_impose := Vector3.ZERO
	if _arguments[3] != "-":
		axe_impose = axes[_arguments[3]] if axes.has(_arguments[3]) else _vecteur(_arguments[3]).normalized()
	var forme: Dictionary = Prise._analyser(Prise._sommets(_arguments[0]), _arguments[1], axe_impose)
	var echelle := float(_arguments[2]) / float(forme["longueur"])
	var cote := _arguments[6]
	var squelette: Skeleton3D = _personnage.find_children("*", "Skeleton3D", true, false)[0]
	var main := squelette.get_bone_global_pose(squelette.find_bone("hand_" + cote))
	var repos := squelette.get_bone_global_rest(squelette.find_bone("hand_" + cote))
	var majeur := repos.affine_inverse() * squelette.get_bone_global_rest(squelette.find_bone("middle_01_" + cote)).origin
	var pointe := (main.basis.inverse() * _vecteur(_arguments[7])).normalized()
	var secondaire := main.basis.inverse() * _vecteur(_arguments[8])
	secondaire = (secondaire - pointe * secondaire.dot(pointe)).normalized()
	if _arguments[1] == "centre" and axe_impose != Vector3.ZERO:
		# Arme symétrique (arc) : l'axe secondaire du modèle est imposé (+Z = côté de la corde).
		forme["vers_pointe"] = axe_impose
		forme["secondaire"] = Vector3.BACK
	var prise: Transform3D = Prise._placer(forme, echelle, pointe, secondaire, majeur * 0.5)
	print("echelle=%.3f" % echelle)
	print("{\"rotation_degres\": %s, \"decalage\": %s}" % [Prise._v(prise.basis.get_euler() * 180.0 / PI), Prise._v(prise.origin)])


func _vecteur(texte: String) -> Vector3:
	var c := texte.split_floats(",")
	return Vector3(c[0], c[1], c[2])
