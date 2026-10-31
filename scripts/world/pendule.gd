class_name Pendule
extends Node
## Fait balancer un objet rigide accroché au personnage (amulette…) comme un petit pendule :
## il prend du retard quand le personnage accélère, puis revient en oscillant.
##
## Réglage au catalogue, sur l'objet, « pendule » : {"pivot": point d'accroche (repère du modèle),
## "raideur": force de rappel, "amorti": freinage, "sensibilite": réaction aux mouvements, "angle_max": en degrés}.

var _objet: ModeleAsset
var _pivot := Vector3.ZERO
var _raideur := 60.0
var _amorti := 6.0
var _sensibilite := 1.0
var _angle_max := 35.0
## Inclinaison actuelle (x : vers l'avant/l'arrière, y : sur le côté), en radians, et sa vitesse.
var angle := Vector2.ZERO
var _vitesse_angle := Vector2.ZERO
var _position_precedente := Vector3.ZERO
var _vitesse_precedente := Vector3.ZERO
var _premiere_image := true


## Ajoute un pendule à un objet porté. Ne fait rien sans réglage « pendule » au catalogue.
static func animer(objet: ModeleAsset) -> Pendule:
	var reglages: Dictionary = CatalogueAssets.reglage(objet.asset_id, "pendule", {})
	if reglages.is_empty() or objet.provisoire:
		return null
	var pendule := Pendule.new()
	pendule.name = "Pendule"
	pendule._objet = objet
	pendule._pivot = objet.vers_porteur(reglages.get("pivot", Vector3.ZERO))
	pendule._raideur = float(reglages.get("raideur", 60.0))
	pendule._amorti = float(reglages.get("amorti", 6.0))
	pendule._sensibilite = float(reglages.get("sensibilite", 1.0))
	pendule._angle_max = float(reglages.get("angle_max", 35.0))
	objet.add_child(pendule)
	return pendule


func _process(delta: float) -> void:
	if delta <= 0.0 or not is_instance_valid(_objet) or _objet.get_parent() == null:
		return
	var accroche := _objet.get_parent() as Node3D
	var position := accroche.global_transform * _pivot
	var vitesse := (position - _position_precedente) / delta
	var acceleration := (vitesse - _vitesse_precedente) / delta
	_position_precedente = position
	_vitesse_precedente = vitesse
	if _premiere_image:
		_premiere_image = false
		_vitesse_precedente = Vector3.ZERO
		return
	# L'objet est poussé à l'opposé de l'accélération, dans le repère du point d'accroche.
	var locale := accroche.global_basis.orthonormalized().inverse() * acceleration
	var poussee := Vector2(locale.z, -locale.x) * _sensibilite
	var rappel := -angle * _raideur - _vitesse_angle * _amorti
	_vitesse_angle += (rappel + poussee) * delta
	angle += _vitesse_angle * delta
	var maximum := deg_to_rad(_angle_max)
	angle = angle.clamp(Vector2(-maximum, -maximum), Vector2(maximum, maximum))
	var rotation_ := Basis(Vector3.RIGHT, angle.x) * Basis(Vector3.BACK, angle.y)
	_objet.transform = Transform3D(Basis.IDENTITY, _pivot) * Transform3D(rotation_, Vector3.ZERO) * Transform3D(Basis.IDENTITY, -_pivot)
