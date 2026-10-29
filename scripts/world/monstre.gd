class_name Monstre
extends CharacterBody3D
## Un monstre : il se promène autour de son point d'apparition, poursuit et mord le joueur
## (tout de suite s'il est agressif, seulement après avoir été frappé s'il est passif),
## et rentre chez lui si on l'entraîne trop loin.

signal mort(monstre: Monstre)

const GROUPE := "monstres"
const HAUTEUR_INFOS := 0.95

enum Etat { ERRANCE, POURSUITE, RETOUR, MORT }

var id_monstre := ""
var nom := ""
var niveau := 1
var pv_max := 1.0
var pv := 1.0
var etat := Etat.ERRANCE

var _definition := {}
var _passif := true
var _point_apparition := Vector3.ZERO
var _joueur: Joueur
var _modele: ModeleAsset
var _barre: BarreVie3D
var _etiquette: Label3D
var _destination := Vector3.ZERO
var _pause_errance := 0.0
var _recharge_attaque := 0.0
var _verrou_animation := 0.0
var _hasard := RandomNumberGenerator.new()
var _gravite: float = ProjectSettings.get_setting("physics/3d/default_gravity")


## À appeler avant d'ajouter le monstre à la scène.
func initialiser(id: String, un_niveau: int, point: Vector3, joueur: Joueur) -> void:
	var config := Config.jeu
	id_monstre = id
	_definition = config.monstre(id)
	nom = str(_definition.get("nom", id))
	niveau = un_niveau
	_passif = str(_definition.get("comportement", "passif")) == "passif"
	pv_max = Combat.pv_monstre(niveau, config)
	pv = pv_max
	_point_apparition = point
	_destination = point
	_joueur = joueur
	position = point
	_hasard.randomize()


func _ready() -> void:
	add_to_group(GROUPE)
	_modele = CatalogueAssets.creer(str(_definition.get("modele", "")))
	_modele.rotation.y = _hasard.randf() * TAU
	add_child(_modele)
	_modele.jouer("idle", 0.0)

	_etiquette = Label3D.new()
	_etiquette.text = "%s  niv. %d" % [nom, niveau]
	_etiquette.font_size = 40
	_etiquette.outline_size = 10
	_etiquette.pixel_size = 0.005
	_etiquette.modulate = Color(1, 1, 1) if _passif else Color(1, 0.6, 0.35)
	_etiquette.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_etiquette.position.y = HAUTEUR_INFOS + 0.12
	add_child(_etiquette)

	_barre = BarreVie3D.new()
	_barre.position.y = HAUTEUR_INFOS
	add_child(_barre)


func est_vivant() -> bool:
	return etat != Etat.MORT


## Le monstre reçoit un coup. Renvoie vrai s'il en meurt.
func recevoir_coup(degats: int, critique: bool) -> bool:
	if not est_vivant():
		return false
	pv = maxf(0.0, pv - degats)
	_barre.visible = true
	_barre.regler(pv / pv_max)
	var couleur := ChiffreFlottant.COULEUR_CRITIQUE if critique else ChiffreFlottant.COULEUR_DEGATS
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * (HAUTEUR_INFOS + 0.3),
		str(degats) + ("!" if critique else ""), couleur, 84 if critique else 60)
	if pv <= 0.0:
		_mourir()
		return true
	if etat != Etat.RETOUR:
		etat = Etat.POURSUITE
	if _verrou_animation <= 0.0:
		_jouer_une_fois("hit")
	return false


func _physics_process(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravite * delta
	_recharge_attaque -= delta
	_verrou_animation -= delta
	if not est_vivant():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var vitesse := 0.0
	var cible := global_position
	match etat:
		Etat.ERRANCE:
			cible = _errer(delta)
			vitesse = float(_definition.get("vitesse_marche", 1.0))
			if not _passif and _joueur_visible(float(_definition.get("rayon_detection", 0.0))):
				etat = Etat.POURSUITE
		Etat.POURSUITE:
			if not _joueur_vivant() or _distance_sol(_point_apparition) > float(_definition.get("rayon_laisse", 12.0)):
				etat = Etat.RETOUR
			elif _distance_sol(_joueur.global_position) > float(_definition.get("portee_attaque", 1.1)):
				cible = _joueur.global_position
				vitesse = float(_definition.get("vitesse_course", 2.0))
			else:
				_tourner_vers(_joueur.global_position, 1.0)
				_attaquer()
		Etat.RETOUR:
			pv = pv_max
			_barre.visible = false
			cible = _point_apparition
			vitesse = float(_definition.get("vitesse_course", 2.0))
			if _distance_sol(_point_apparition) < 0.5:
				etat = Etat.ERRANCE

	var direction := cible - global_position
	direction.y = 0.0
	if direction.length() < 0.2:
		vitesse = 0.0
	direction = direction.normalized()
	velocity.x = direction.x * vitesse
	velocity.z = direction.z * vitesse
	move_and_slide()
	if vitesse > 0.0:
		_tourner_vers(global_position + direction, 1.0 - exp(-10.0 * delta))
	if _verrou_animation <= 0.0:
		_modele.jouer("walk" if vitesse > 0.0 else "idle", 0.15)


func _errer(delta: float) -> Vector3:
	if _distance_sol(_destination) < 0.3:
		_pause_errance -= delta
		if _pause_errance <= 0.0:
			var rayon := float(_definition.get("rayon_errance", 4.0))
			var angle := _hasard.randf() * TAU
			_destination = _point_apparition + Vector3(cos(angle), 0, sin(angle)) * _hasard.randf() * rayon
			_pause_errance = _hasard.randf_range(1.5, 4.0)
		return global_position
	return _destination


func _attaquer() -> void:
	if _recharge_attaque > 0.0:
		return
	var intervalle := float(_definition.get("intervalle_attaque", 1.5))
	_recharge_attaque = intervalle
	_jouer_une_fois("attack")
	_joueur.recevoir_degats(Combat.degats_monstre(niveau, _joueur.niveau(), _passif, intervalle, Config.jeu), niveau)


func _mourir() -> void:
	etat = Etat.MORT
	remove_from_group(GROUPE)
	collision_layer = 0
	_barre.visible = false
	_etiquette.visible = false
	_modele.jouer("die", 0.1, false)
	mort.emit(self)
	var disparition := create_tween()
	disparition.tween_interval(1.5)
	disparition.tween_property(_modele, "scale", Vector3.ONE * 0.01, 0.3)
	disparition.tween_callback(queue_free)


func _jouer_une_fois(animation: String) -> void:
	_modele.jouer(animation, 0.08, false, true)
	_verrou_animation = _modele.duree(animation)


func _tourner_vers(point: Vector3, poids: float) -> void:
	var direction := point - global_position
	if Vector2(direction.x, direction.z).length() > 0.01:
		_modele.rotation.y = lerp_angle(_modele.rotation.y, atan2(direction.x, direction.z), poids)


func _joueur_vivant() -> bool:
	return is_instance_valid(_joueur) and _joueur.est_vivant()


func _joueur_visible(rayon: float) -> bool:
	return _joueur_vivant() and _distance_sol(_joueur.global_position) < rayon


func _distance_sol(point: Vector3) -> float:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length()
