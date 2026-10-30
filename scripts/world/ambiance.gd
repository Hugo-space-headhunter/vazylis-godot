class_name Ambiance
extends Resource
## L'ambiance d'une zone : ciel, brouillard, soleil et lumière ambiante. Quand le joueur change
## de zone, le monde passe doucement d'une ambiance à l'autre (voir monde.gd).
## Les ambiances sont des fichiers .tres dans scenes/zones/ambiances/, réglables dans l'éditeur Godot.

@export_group("Ciel")
## Couleur du ciel tout en haut.
@export var ciel_haut := Color(0.32, 0.56, 0.86)
## Couleur du ciel près de l'horizon.
@export var ciel_horizon := Color(0.78, 0.86, 0.92)

@export_group("Brouillard")
## Couleur du brouillard : les objets lointains s'y fondent.
@export var brouillard_couleur := Color(0.78, 0.85, 0.9)
## Épaisseur du brouillard (0 = aucun ; 0,02 = on voit à peine à 60 m).
@export_range(0.0, 0.1, 0.001) var brouillard_densite := 0.004

@export_group("Lumière")
@export var soleil_couleur := Color(1.0, 0.95, 0.85)
@export_range(0.0, 2.0, 0.01) var soleil_energie := 1.15
## Lumière qui vient de partout (elle éclaire les côtés à l'ombre).
@export var ambiante_couleur := Color(0.75, 0.8, 0.9)
@export_range(0.0, 2.0, 0.01) var ambiante_energie := 0.55
