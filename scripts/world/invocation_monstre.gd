class_name InvocationMonstre
extends RefCounted
## Un sous-boss qui invoque (« invocation » dans config/monstres.cfg) appelle des renforts à
## intervalle régulier pendant le combat ; les renforts disparaissent s'il abandonne le combat.

var _reglages := {}
var _recharge := 0.0
var _invoques: Array[Monstre] = []


func _init(reglages: Dictionary) -> void:
	_reglages = reglages
	_recharge = float(_reglages.get("intervalle", 0.0))


func est_active() -> bool:
	return not _reglages.is_empty()


## Appelle des renforts autour du sous-boss quand c'est le moment. Renvoie vrai s'il en a appelé.
func mettre_a_jour(sous_boss: Monstre, joueur: Joueur, delta: float, hasard: RandomNumberGenerator) -> bool:
	if _reglages.is_empty():
		return false
	_recharge -= delta
	if _recharge > 0.0:
		return false
	_recharge = float(_reglages.get("intervalle", 12.0))
	_invoques = _invoques.filter(func(m: Monstre) -> bool: return is_instance_valid(m) and m.est_vivant())
	var id := str(_reglages.get("monstre", ""))
	var definition := Config.jeu.monstre(id)
	var scene: PackedScene = load(sous_boss.scene_file_path)
	var place := int(_reglages.get("maximum", 4)) - _invoques.size()
	for i in mini(int(_reglages.get("nombre", 1)), place):
		var angle := hasard.randf() * TAU
		var point := sous_boss.global_position + Vector3(cos(angle), 0, sin(angle)) * 1.8
		var invoque: Monstre = scene.instantiate()
		var niveau_invoque := hasard.randi_range(int(definition.get("niveau_min", 1)), int(definition.get("niveau_max", 1)))
		invoque.initialiser(id, niveau_invoque, point, joueur)
		invoque.etat = Monstre.Etat.POURSUITE
		sous_boss.get_parent().add_child(invoque)
		_invoques.append(invoque)
	return place > 0


## Le sous-boss abandonne le combat : ses renforts disparaissent.
func renvoyer() -> void:
	for invoque in _invoques:
		if is_instance_valid(invoque) and invoque.est_vivant():
			invoque.queue_free()
	_invoques.clear()
	_recharge = float(_reglages.get("intervalle", 0.0))
