class_name AttaqueDeZone
extends RefCounted
## Attaque de zone (« attaque_zone » dans config/monstres.cfg, la Gueule-Fleur) : un cercle rouge
## grandit au sol pendant le préavis ; si le joueur est encore dedans à la fin, il est frappé.
## Il a le temps de s'écarter.

const COULEUR := Color(1.0, 0.25, 0.2)

var _reglages := {}
var _recharge := 0.0
var _en_cours := false


func _init(reglages: Dictionary) -> void:
	_reglages = reglages
	_recharge = float(_reglages.get("intervalle", 0.0)) / 2.0


## Lance l'attaque quand c'est le moment et que le joueur est assez près.
## « frapper » est appelé à la fin du préavis avec (multiplicateur de dégâts, rayon).
func mettre_a_jour(monstre: Node3D, distance_joueur: float, delta: float, frapper: Callable) -> void:
	if _reglages.is_empty() or _en_cours:
		return
	_recharge -= delta
	var rayon := float(_reglages.get("rayon", 4.0))
	if _recharge > 0.0 or distance_joueur > rayon * 1.5:
		return
	_recharge = float(_reglages.get("intervalle", 8.0))
	_en_cours = true
	var cercle := CercleAuSol.creer(monstre, "AttaqueDeZone", rayon, Color(COULEUR, 0.9), 0.05)
	cercle.scale = Vector3.ONE * 0.15
	var animation := cercle.create_tween()
	animation.tween_property(cercle, "scale", Vector3.ONE, float(_reglages.get("preavis", 1.2)))
	animation.tween_callback(func() -> void:
		_en_cours = false
		cercle.queue_free()
		frapper.call(float(_reglages.get("multiplicateur", 2.0)), rayon))
