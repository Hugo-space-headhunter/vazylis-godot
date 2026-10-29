class_name CorpsSousVetements
extends RefCounted
## Rentre la peau du personnage sous les vêtements portés, pour qu'elle ne traverse pas le tissu.
## Le personnage de base est plus large que le corps prévu pour les tenues : sous chaque pièce,
## les sommets de la peau reculent de quelques centimètres vers l'intérieur. La peau reste entière,
## donc une pièce manquante ne laisse jamais de trou.

## Os de la peau cachés par chaque emplacement (on regarde l'os qui pèse le plus sur chaque sommet).
const OS_COUVERTS := {
	"plastron": ["spine_01", "spine_02", "spine_03", "clavicle_l", "clavicle_r"],
	"ceinture": ["pelvis", "thigh_l", "thigh_r"],
	"bottes": ["calf_l", "calf_r", "foot_l", "foot_r", "ball_l", "ball_r", "ball_leaf_l", "ball_leaf_r"],
	"gants": ["upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r", "hand_l", "hand_r"],
}
const PREFIXES_DOIGTS: PackedStringArray = ["index_", "middle_", "ring_", "pinky_", "thumb_"]

## Maillages déjà fabriqués : clé = maillage d'origine + emplacements couverts.
static var _cache := {}


## Donne à « peau » la version de son maillage où la peau recule sous les emplacements couverts.
## « origine » est le maillage d'origine du personnage (à garder pour revenir en arrière).
static func ajuster(peau: MeshInstance3D, origine: Mesh, couverts: PackedStringArray, retrait: float) -> void:
	if couverts.is_empty() or retrait <= 0.0 or peau.skin == null:
		peau.mesh = origine
		return
	var tries := couverts.duplicate()
	tries.sort()
	var cle := "%d|%s|%.3f" % [origine.get_instance_id(), ",".join(tries), retrait]
	if not _cache.has(cle):
		_cache[cle] = _fabriquer(origine, peau.skin, tries, retrait)
	peau.mesh = _cache[cle]


static func _fabriquer(origine: Mesh, skin: Skin, couverts: PackedStringArray, retrait: float) -> ArrayMesh:
	var os_caches := {}
	for emplacement in couverts:
		for nom: String in OS_COUVERTS.get(emplacement, []):
			os_caches[nom] = true
	var cache_doigts := "gants" in couverts
	var binds_caches := {}
	for i in skin.get_bind_count():
		var nom := str(skin.get_bind_name(i))
		if os_caches.has(nom) or (cache_doigts and _est_un_doigt(nom)):
			binds_caches[i] = true

	var resultat := ArrayMesh.new()
	for surface in origine.get_surface_count():
		var tableaux := origine.surface_get_arrays(surface)
		var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
		var normales: PackedVector3Array = tableaux[Mesh.ARRAY_NORMAL]
		var os_sommets: PackedInt32Array = tableaux[Mesh.ARRAY_BONES]
		var poids: PackedFloat32Array = tableaux[Mesh.ARRAY_WEIGHTS]
		var par_sommet := os_sommets.size() / maxi(1, sommets.size())
		for v in sommets.size():
			var meilleur := -1
			var poids_max := -1.0
			for k in par_sommet:
				if poids[v * par_sommet + k] > poids_max:
					poids_max = poids[v * par_sommet + k]
					meilleur = os_sommets[v * par_sommet + k]
			if binds_caches.has(meilleur):
				sommets[v] -= normales[v] * retrait
		tableaux[Mesh.ARRAY_VERTEX] = sommets
		# Les canaux personnalisés du fichier ne servent pas au jeu : on ne les recopie pas.
		for canal in [Mesh.ARRAY_CUSTOM0, Mesh.ARRAY_CUSTOM1, Mesh.ARRAY_CUSTOM2, Mesh.ARRAY_CUSTOM3]:
			tableaux[canal] = null
		var drapeaux: int = origine.surface_get_format(surface) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS
		resultat.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, tableaux, [], {}, drapeaux)
		resultat.surface_set_material(surface, origine.surface_get_material(surface))
	return resultat


static func _est_un_doigt(nom: String) -> bool:
	for prefixe in PREFIXES_DOIGTS:
		if nom.begins_with(prefixe):
			return true
	return false
