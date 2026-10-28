extends SceneTree
## Outil : affiche l'arbre des nœuds, les os et les animations d'un modèle importé.
## Utile pour remplir le catalogue (noms d'animations, os des points d'attache).
##
## Exemple, depuis le dossier du projet :
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/inspecter_modele.gd -- res://assets/models/character/heros_homme/heros_homme.gltf


func _init() -> void:
	for chemin in OS.get_cmdline_user_args():
		print("=== ", chemin)
		var ressource := load(chemin)
		if ressource is PackedScene:
			var racine := (ressource as PackedScene).instantiate()
			_afficher(racine, 0)
			racine.free()
		elif ressource is AnimationLibrary:
			_afficher_bibliotheque(ressource)
		else:
			print("Type : ", ressource)
	quit(0)


func _afficher(noeud: Node, profondeur: int) -> void:
	var details := ""
	if noeud is Node3D:
		details = " pos=%s echelle=%s" % [(noeud as Node3D).position, (noeud as Node3D).scale]
	if noeud is MeshInstance3D:
		details += " aabb=%s" % (noeud as MeshInstance3D).get_aabb()
	print("  ".repeat(profondeur), noeud.name, " (", noeud.get_class(), ")", details)
	if noeud is Skeleton3D:
		var squelette := noeud as Skeleton3D
		var os := PackedStringArray()
		for i in squelette.get_bone_count():
			os.append(squelette.get_bone_name(i))
		print("  ".repeat(profondeur + 1), "Os (", os.size(), ") : ", ", ".join(os))
	if noeud is AnimationPlayer:
		for nom_bibliotheque in (noeud as AnimationPlayer).get_animation_library_list():
			_afficher_bibliotheque((noeud as AnimationPlayer).get_animation_library(nom_bibliotheque))
	for enfant in noeud.get_children():
		_afficher(enfant, profondeur + 1)


func _afficher_bibliotheque(bibliotheque: AnimationLibrary) -> void:
	var noms := bibliotheque.get_animation_list()
	print("    Animations (", noms.size(), ") : ", ", ".join(noms))
	if noms.size() > 0:
		var animation := bibliotheque.get_animation(noms[0])
		var pistes := PackedStringArray()
		for i in mini(animation.get_track_count(), 4):
			pistes.append(str(animation.track_get_path(i)))
		print("    Exemples de pistes : ", ", ".join(pistes))
