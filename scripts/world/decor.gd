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


func _ready() -> void:
	add_child(CatalogueAssets.creer(id_asset))
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
