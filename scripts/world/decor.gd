class_name Decor
extends Node3D
## Un élément de décor (mur, tonneau, bannière…) pris dans le catalogue d'assets par son identifiant,
## avec un obstacle facultatif pour qu'on ne passe pas au travers.
## À régler dans l'éditeur : identifiant et taille de l'obstacle.

## Identifiant du décor dans assets/catalogue.cfg (par exemple « prop.tonneau »).
@export var id_asset := ""
## Taille de l'obstacle (une boîte posée au sol, centrée sous le décor), en mètres.
## Laisser à zéro pour un décor qu'on traverse (bannière, torche murale…).
@export var obstacle := Vector3.ZERO
## Au-delà de cette distance de la caméra (en mètres), le décor n'est plus dessiné, pour ménager
## le téléphone. Zéro : toujours dessiné.
@export var distance_affichage := 0.0
## Les petits décors (fleurs, buissons, tonneaux…) ne projettent pas d'ombre : c'est presque
## invisible à l'écran et cela évite de les dessiner une deuxième fois.
@export var projette_ombre := true
## Distance à la caméra (en mètres) en dessous de laquelle le décor s'efface en pointillés :
## un arbre qui passe entre la caméra et le héros ne cache plus l'écran. Zéro : jamais.
@export var fondu_camera := 0.0

## Matières déjà préparées pour l'effacement, partagées entre tous les décors.
static var _matieres_fondues := {}


func _ready() -> void:
	var modele := CatalogueAssets.creer(id_asset)
	add_child(modele)
	for noeud in modele.find_children("*", "GeometryInstance3D", true, false):
		var maillage := noeud as GeometryInstance3D
		if distance_affichage > 0.0:
			maillage.visibility_range_end = distance_affichage
			maillage.visibility_range_end_margin = 2.0
		if not projette_ombre:
			maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if fondu_camera > 0.0 and maillage is MeshInstance3D:
			_effacer_pres_de_la_camera(maillage as MeshInstance3D)
	if obstacle == Vector3.ZERO:
		return
	var boite := BoxShape3D.new()
	boite.size = obstacle
	var forme := CollisionShape3D.new()
	forme.shape = boite
	forme.position.y = obstacle.y / 2.0
	var corps := StaticBody3D.new()
	corps.add_child(forme)
	add_child(corps)


func _effacer_pres_de_la_camera(maillage: MeshInstance3D) -> void:
	for surface in maillage.get_surface_override_material_count():
		var origine := maillage.get_active_material(surface) as BaseMaterial3D
		if origine == null:
			continue
		var cle := [origine, fondu_camera]
		if not _matieres_fondues.has(cle):
			var copie := origine.duplicate() as BaseMaterial3D
			copie.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_DITHER
			copie.distance_fade_min_distance = fondu_camera * 0.45
			copie.distance_fade_max_distance = fondu_camera
			_matieres_fondues[cle] = copie
		maillage.set_surface_override_material(surface, _matieres_fondues[cle])
