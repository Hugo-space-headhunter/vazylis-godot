extends Node3D
## Scène de test de l'étape 0 : un cristal qui tourne, chargé par le catalogue,
## et un exemple de modèle provisoire (fichier volontairement absent).

## Vitesse de rotation du cristal, en degrés par seconde.
@export var vitesse_rotation_degres := 45.0

@onready var _presentoir: Node3D = $Presentoir
@onready var _emplacement_repli: Node3D = $EmplacementRepli


func _ready() -> void:
	_presentoir.add_child(CatalogueAssets.creer(IdentifiantsAssets.CRISTAL_TEST))
	_emplacement_repli.add_child(CatalogueAssets.creer(IdentifiantsAssets.EXEMPLE_MANQUANT))


func _process(delta: float) -> void:
	_presentoir.rotate_y(deg_to_rad(vitesse_rotation_degres) * delta)
