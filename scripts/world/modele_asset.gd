class_name ModeleAsset
extends Node3D
## Modèle 3D créé par le catalogue d'assets (voir l'autoload CatalogueAssets).
##
## Le jeu ne parle qu'à ce nœud : il joue des animations standard (« idle »,
## « walk »…) et accroche des objets à des points nommés (« main_droite »…),
## sans connaître le vrai fichier 3D ni ses vrais noms d'animations ou d'os.

## Identifiant du catalogue (ex. « character.heros_homme »).
var asset_id := ""
## Vrai si le fichier 3D manquait et qu'un modèle provisoire est affiché.
var provisoire := false

const NOM_BIBLIOTHEQUE := "catalogue"

var _modele: Node3D
var _lecteur: AnimationPlayer
var _animations := {}
var _points_attache := {}
var _placements := {}
var _transformation_de_base := Transform3D.IDENTITY
var _attaches := {}
var _animation_en_cours := ""


func configurer(id: String, modele: Node3D, est_provisoire: bool, animations: Dictionary,
		points_attache: Dictionary, bibliotheque: AnimationLibrary, placements: Dictionary = {}) -> void:
	asset_id = id
	provisoire = est_provisoire
	name = id.replace(".", "_")
	_modele = modele
	_animations = animations
	_points_attache = points_attache
	_placements = placements
	_transformation_de_base = modele.transform
	add_child(modele)
	if est_provisoire:
		return
	var lecteurs := modele.find_children("*", "AnimationPlayer", true, false)
	if not lecteurs.is_empty():
		_lecteur = lecteurs[0]
	elif bibliotheque != null:
		_lecteur = AnimationPlayer.new()
		_lecteur.name = "LecteurAnimations"
		modele.add_child(_lecteur)
	if _lecteur != null and bibliotheque != null:
		_lecteur.add_animation_library(NOM_BIBLIOTHEQUE, bibliotheque)


## Vrai si l'animation standard existe pour ce modèle.
func a_animation(animation_standard: String) -> bool:
	return not _vrai_nom(animation_standard).is_empty()


## Joue une animation standard en fondu. Sans effet si le modèle ne l'a pas.
## « forcer » la relance même si elle est déjà en cours (pour enchaîner deux attaques).
func jouer(animation_standard: String, fondu: float = 0.2, en_boucle: bool = true, forcer: bool = false) -> void:
	if animation_standard == _animation_en_cours and not forcer:
		return
	var nom := _vrai_nom(animation_standard)
	if nom.is_empty():
		return
	_animation_en_cours = animation_standard
	_lecteur.get_animation(nom).loop_mode = Animation.LOOP_LINEAR if en_boucle else Animation.LOOP_NONE
	if forcer and _lecteur.current_animation == nom:
		_lecteur.seek(0.0, true)
	_lecteur.play(nom, fondu)


## Durée d'une animation standard en secondes (0 si absente).
func duree(animation_standard: String) -> float:
	var nom := _vrai_nom(animation_standard)
	return _lecteur.get_animation(nom).length if not nom.is_empty() else 0.0


## Animation standard en cours (« idle », « walk »…), ou "" si aucune.
func animation_en_cours() -> String:
	return _animation_en_cours


## Vitesse de lecture de l'animation en cours (1 = normale).
func regler_vitesse_animation(vitesse: float) -> void:
	if _lecteur != null:
		_lecteur.speed_scale = vitesse


## Point d'attache nommé (« main_droite », « dos »…), qui suit l'os correspondant.
## Renvoie le modèle lui-même si le point n'existe pas, pour ne jamais planter.
func point_attache(nom: String) -> Node3D:
	if _attaches.has(nom):
		return _attaches[nom]
	var squelette := _squelette()
	var nom_os := str(_points_attache.get(nom, ""))
	if squelette == null or nom_os.is_empty() or squelette.find_bone(nom_os) == -1:
		push_warning("ModeleAsset : point d'attache « %s » absent pour « %s »." % [nom, asset_id])
		return self
	var attache := BoneAttachment3D.new()
	attache.name = "Attache_" + nom
	attache.bone_name = nom_os
	squelette.add_child(attache)
	_attaches[nom] = attache
	return attache


## Pour un objet porté (arme…) : accroche l'objet au point d'attache d'un porteur,
## avec la position prévue par le catalogue pour ce point (réglage « placements »).
func accrocher_a(porteur: ModeleAsset, point: String) -> void:
	var attache := porteur.point_attache(point)
	if get_parent() != attache:
		if get_parent() != null:
			get_parent().remove_child(self)
		attache.add_child(self)
	if provisoire:
		return
	var placement: Dictionary = _placements.get(point, {})
	if placement.is_empty():
		_modele.transform = _transformation_de_base
	else:
		_modele.rotation_degrees = placement.get("rotation_degres", Vector3.ZERO)
		_modele.position = placement.get("decalage", Vector3.ZERO)
		_modele.scale = _transformation_de_base.basis.get_scale()


func _vrai_nom(animation_standard: String) -> String:
	if _lecteur == null:
		return ""
	var nom := str(_animations.get(animation_standard, animation_standard))
	if _lecteur.has_animation(nom):
		return nom
	if _lecteur.has_animation(NOM_BIBLIOTHEQUE + "/" + nom):
		return NOM_BIBLIOTHEQUE + "/" + nom
	return ""


func _squelette() -> Skeleton3D:
	var squelettes := find_children("*", "Skeleton3D", true, false)
	return squelettes[0] if not squelettes.is_empty() else null
