class_name ZoneApparition
extends Node3D
## Fait apparaître des monstres d'un type autour de ce point, et les fait réapparaître
## après leur mort (délai « reapparition » de config/monstres.cfg).
## À régler dans l'éditeur : identifiant du monstre, nombre et rayon.

const SCENE_MONSTRE := preload("res://scenes/monstres/monstre.tscn")

## Identifiant du monstre dans config/monstres.cfg.
@export var monstre_id := "monstre.cochonnet_suie"
## Nombre de monstres présents en même temps.
@export var nombre := 4
## Rayon de la zone, en mètres.
@export var rayon := 3.0

var _hasard := RandomNumberGenerator.new()


func _ready() -> void:
	_hasard.randomize()
	for i in nombre:
		_faire_apparaitre.call_deferred()


func _faire_apparaitre() -> void:
	var joueur := get_tree().get_first_node_in_group(Joueur.GROUPE) as Joueur
	var definition := Config.jeu.monstre(monstre_id)
	var niveau := _hasard.randi_range(int(definition.get("niveau_min", 1)), int(definition.get("niveau_max", 1)))
	var angle := _hasard.randf() * TAU
	var point := global_position + Vector3(cos(angle), 0, sin(angle)) * sqrt(_hasard.randf()) * rayon
	var monstre: Monstre = SCENE_MONSTRE.instantiate()
	monstre.initialiser(monstre_id, niveau, point, joueur)
	monstre.mort.connect(_sur_mort)
	get_parent().add_child(monstre)


func _sur_mort(_monstre: Monstre) -> void:
	var delai := float(Config.jeu.monstre(monstre_id).get("reapparition", 8.0))
	get_tree().create_timer(delai, false).timeout.connect(_faire_apparaitre)
