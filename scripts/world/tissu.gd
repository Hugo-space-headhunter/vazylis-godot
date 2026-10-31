class_name Tissu
extends SpringBoneSimulator3D
## Fait vivre un objet en tissu qui a des os (une cape…) : Godot fait bouger chaque colonne d'os
## comme une chaîne de ressorts (inertie, gravité). La cape vole en arrière quand on court,
## balance dans les virages et retombe à l'arrêt.
## Des capsules invisibles autour du dos, du bassin et des jambes du porteur l'empêchent de traverser le corps.
##
## Réglages au catalogue :
##   - sur l'objet, « tissu » : {"chaines": [[os du haut, os du bas], …], "raideur", "amorti", "gravite", "rayon"} ;
##   - sur le personnage, « collisions_tissu » : [[os suivi, os de départ, os d'arrivée, rayon], …]
##     (une capsule qui suit « os suivi » et va de la position de repos d'un os à celle d'un autre).

var _porteur: Skeleton3D
## Pour chaque capsule : [capsule, os suivi du porteur, position de la capsule par rapport à cet os].
var _capsules := []


## Ajoute le tissu à un objet porté. Ne fait rien si l'objet n'a pas de réglage « tissu » ou pas de squelette.
static func animer(objet: ModeleAsset, porteur: ModeleAsset) -> Tissu:
	var reglages: Dictionary = CatalogueAssets.reglage(objet.asset_id, "tissu", {})
	var squelette := objet.squelette()
	if reglages.is_empty() or squelette == null or objet.provisoire:
		return null
	var tissu := Tissu.new()
	tissu.name = "Tissu"
	squelette.add_child(tissu)
	tissu._regler(reglages)
	var squelette_porteur := porteur.squelette()
	if squelette_porteur != null:
		tissu._entourer_le_corps(squelette_porteur, CatalogueAssets.reglage(porteur.asset_id, "collisions_tissu", []))
	return tissu


func _regler(reglages: Dictionary) -> void:
	var chaines: Array = reglages.get("chaines", [])
	setting_count = chaines.size()
	for i in chaines.size():
		set_root_bone_name(i, chaines[i][0])
		set_end_bone_name(i, chaines[i][1])
		set_stiffness(i, float(reglages.get("raideur", 0.6)))
		set_drag(i, float(reglages.get("amorti", 0.5)))
		set_gravity(i, float(reglages.get("gravite", 1.0)))
		set_gravity_direction(i, Vector3.DOWN)
		set_radius(i, float(reglages.get("rayon", 0.03)))
		set_enable_all_child_collisions(i, true)


func _entourer_le_corps(squelette: Skeleton3D, collisions: Array) -> void:
	_porteur = squelette
	for definition: Array in collisions:
		var os := squelette.find_bone(definition[0])
		var depart := squelette.find_bone(definition[1])
		var arrivee := squelette.find_bone(definition[2])
		if os == -1 or depart == -1 or arrivee == -1:
			push_warning("Tissu : os absent dans « collisions_tissu » : %s" % [definition])
			continue
		var repere := squelette.get_bone_global_rest(os).affine_inverse()
		var a := repere * squelette.get_bone_global_rest(depart).origin
		var b := repere * squelette.get_bone_global_rest(arrivee).origin
		var rayon := float(definition[3])
		var axe := (b - a).normalized()
		var cote := axe.cross(Vector3.FORWARD if absf(axe.z) < 0.9 else Vector3.RIGHT).normalized()
		var capsule := SpringBoneCollisionCapsule3D.new()
		capsule.radius = rayon
		capsule.height = a.distance_to(b) + 2.0 * rayon
		add_child(capsule)
		_capsules.append([capsule, os, Transform3D(Basis(cote, axe, cote.cross(axe)), (a + b) / 2.0)])
	_suivre_le_corps()


## Les capsules suivent les os du porteur (avant le calcul du tissu).
func _process(_delta: float) -> void:
	_suivre_le_corps()


func _suivre_le_corps() -> void:
	if _porteur == null or not is_instance_valid(_porteur) or not is_inside_tree():
		return
	for entree: Array in _capsules:
		var capsule: SpringBoneCollisionCapsule3D = entree[0]
		capsule.global_transform = _porteur.global_transform * _porteur.get_bone_global_pose(entree[1]) * entree[2]
