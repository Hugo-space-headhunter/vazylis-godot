class_name Monstre
extends CharacterBody3D
## Un monstre : il se promène autour de son point d'apparition, poursuit et mord le joueur
## (tout de suite s'il est agressif, seulement après avoir été frappé s'il est passif),
## et rentre chez lui si on l'entraîne trop loin.
## Un monstre peut être un champion (plus gros, aura dorée) ou un sous-boss (qui peut invoquer des renforts).
## Comportements réglés dans config/monstres.cfg : immobile (plante), recul après chaque coup (gobelin
## chapardeur), attaque à distance (gobelin chaman), attaque de zone annoncée au sol (Gueule-Fleur),
## vie renforcée (Gargouillon), meute (Rat des cryptes), parade (Écuyer creux) et blocage de face
## avec une rotation lente (le Gardien sans visage), encerclement (Loup morbide) et rage sous la
## moitié de sa vie (Krâg le Mutilé).
## Morceaux à part : InvocationMonstre (renforts), AttaqueDeZone (cercle au sol), CercleAuSol (aura).

signal mort(monstre: Monstre)

const GROUPE := "monstres"
const HAUTEUR_INFOS := 0.95
const COULEUR_CHAMPION := Color(1.0, 0.8, 0.25)
const COULEUR_SOUS_BOSS := Color(0.85, 0.55, 1.0)
const COULEUR_RAGE := Color(1.0, 0.2, 0.15)

enum Etat { ERRANCE, POURSUITE, RETOUR, MORT }

var id_monstre := ""
var nom := ""
var niveau := 1
var pv_max := 1.0
var pv := 1.0
var etat := Etat.ERRANCE
## Loin du joueur, le monstre dort : il ne bouge plus, n'est plus animé ni dessiné (voir VeilleMonstres).
var endormi := false
## Combat.RANG_NORMAL, RANG_CHAMPION ou RANG_SOUS_BOSS.
var rang := Combat.RANG_NORMAL
## Ressource lâchée (section de config/ressources.cfg), ou "".
var ressource := ""

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
var _hauteur_infos := HAUTEUR_INFOS
var _invocation := InvocationMonstre.new({})
var _immobile := false
var _recul_restant := 0.0
var _attaque_zone := AttaqueDeZone.new({})
var _vitesse_rotation := 0.0
## En rage (« enrage » dans la config) : il frappe plus vite et plus fort.
var enrage := false
var _matiere_aura: StandardMaterial3D
var _echelle_modele := Vector3.ONE
var _reaction: Tween
var _sens_encerclement := 1.0
var _delta := 0.0
var _hasard := RandomNumberGenerator.new()
var _gravite: float = ProjectSettings.get_setting("physics/3d/default_gravity")


## À appeler avant d'ajouter le monstre à la scène.
## « champion » : ce monstre apparaît en version champion (ignoré pour un sous-boss).
func initialiser(id: String, un_niveau: int, point: Vector3, joueur: Joueur, champion: bool = false) -> void:
	var config := Config.jeu
	id_monstre = id
	_definition = config.monstre(id)
	nom = str(_definition.get("nom", id))
	niveau = un_niveau
	_passif = str(_definition.get("comportement", "passif")) == "passif"
	ressource = str(_definition.get("ressource", ""))
	_immobile = str(_definition.get("deplacement", "normal")) == "immobile"
	_attaque_zone = AttaqueDeZone.new(_definition.get("attaque_zone", {}))
	if bool(_definition.get("sous_boss", false)):
		rang = Combat.RANG_SOUS_BOSS
		_invocation = InvocationMonstre.new(_definition.get("invocation", {}))
	elif champion:
		rang = Combat.RANG_CHAMPION
	pv_max = Combat.pv_monstre(niveau, config, rang) * float(_definition.get("multiplicateur_vie", 1.0))
	_vitesse_rotation = deg_to_rad(float(_definition.get("vitesse_rotation", 0.0)))
	pv = pv_max
	_point_apparition = point
	_destination = point
	_joueur = joueur
	_hasard.randomize()
	_sens_encerclement = 1.0 if _hasard.randf() < 0.5 else -1.0


func _ready() -> void:
	add_to_group(GROUPE)
	# « point » est une position du monde, quel que soit le nœud parent (une zone peut être décalée).
	global_position = _point_apparition
	_modele = CatalogueAssets.creer(str(_definition.get("modele", "")))
	_modele.rotation.y = _hasard.randf() * TAU
	add_child(_modele)
	_modele.jouer("idle", 0.0)
	var armes: Dictionary = _definition.get("armes", {})
	for point: String in armes:
		var arme := CatalogueAssets.creer(str(armes[point]))
		add_child(arme)
		arme.accrocher_a(_modele, point)
	if rang == Combat.RANG_CHAMPION:
		_modele.scale *= Config.jeu.combat("champion", "echelle")
		$Collision.scale *= Config.jeu.combat("champion", "echelle")
	_echelle_modele = _modele.scale
	var boite := Transform3D(_modele.transform.basis, Vector3.ZERO) * _modele.boite_englobante()
	_hauteur_infos = maxf(HAUTEUR_INFOS, boite.end.y + 0.25)
	if rang != Combat.RANG_NORMAL:
		_matiere_aura = CercleAuSol.aura(self, boite, _couleur_du_rang())

	_etiquette = Label3D.new()
	_etiquette.text = "%s  niv. %d" % [nom, niveau]
	_etiquette.font_size = 40
	_etiquette.outline_size = 10
	_etiquette.pixel_size = 0.005
	_etiquette.modulate = Color(1, 1, 1) if _passif else Color(1, 0.6, 0.35)
	if rang == Combat.RANG_CHAMPION:
		_etiquette.text = "Champion · " + _etiquette.text
		_etiquette.modulate = COULEUR_CHAMPION
	elif rang == Combat.RANG_SOUS_BOSS:
		_etiquette.modulate = COULEUR_SOUS_BOSS
		_etiquette.font_size = 52
	_etiquette.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_etiquette.position.y = _hauteur_infos + 0.12
	add_child(_etiquette)

	_barre = BarreVie3D.new()
	_barre.position.y = _hauteur_infos
	if rang != Combat.RANG_NORMAL:
		_barre.scale = Vector3.ONE * 1.6
	add_child(_barre)


func endormir(oui: bool) -> void:
	if oui == endormi or not est_vivant():
		return
	endormi = oui
	process_mode = Node.PROCESS_MODE_DISABLED if oui else Node.PROCESS_MODE_INHERIT
	visible = not oui


func est_vivant() -> bool:
	return etat != Etat.MORT


## Le monstre reçoit un coup. Renvoie vrai s'il en meurt.
func recevoir_coup(degats: int, critique: bool) -> bool:
	if not est_vivant():
		return false
	if _evite_le_coup():
		if etat == Etat.ERRANCE:
			_engager()
		return false
	pv = maxf(0.0, pv - degats)
	_encaisser(critique)
	_barre.visible = true
	_barre.regler(pv / pv_max)
	var couleur := ChiffreFlottant.COULEUR_CRITIQUE if critique else ChiffreFlottant.COULEUR_DEGATS
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * (_hauteur_infos + 0.3),
		str(degats) + ("!" if critique else ""), couleur, 84 if critique else 60)
	if pv <= 0.0:
		_mourir()
		return true
	_verifier_la_rage()
	if etat != Etat.RETOUR:
		_engager()
	if _verrou_animation <= 0.0:
		_jouer_une_fois("hit")
	return false


## Parade (« chance_parade ») ou blocage de face au bouclier (« blocage_de_face ») : le coup ne fait rien.
func _evite_le_coup() -> bool:
	var texte := ""
	if _hasard.randf() < float(_definition.get("chance_parade", 0.0)):
		texte = "Paré"
	var blocage: Dictionary = _definition.get("blocage_de_face", {})
	if texte.is_empty() and not blocage.is_empty() and _joueur_vivant() \
			and _face_au_joueur(float(blocage.get("angle", 60.0))) and _hasard.randf() < float(blocage.get("chance", 0.5)):
		texte = "Bloqué"
	if texte.is_empty():
		return false
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * (_hauteur_infos + 0.3), texte, Color(0.75, 0.85, 1.0), 52)
	return true


## Le joueur est-il devant lui (à moins de « angle » degrés de son regard) ?
func _face_au_joueur(angle: float) -> bool:
	var vers := _joueur.global_position - global_position
	var regard := Vector2(sin(_modele.rotation.y), cos(_modele.rotation.y))
	var direction := Vector2(vers.x, vers.z)
	if direction.length() < 0.01:
		return true
	return absf(rad_to_deg(regard.angle_to(direction.normalized()))) <= angle


## Le monstre entre en combat ; une meute (« meute » : rayon en mètres) entraîne ses voisins du même type.
func _engager() -> void:
	etat = Etat.POURSUITE
	var rayon := float(_definition.get("meute", 0.0))
	if rayon <= 0.0:
		return
	for noeud in get_tree().get_nodes_in_group(GROUPE):
		var voisin := noeud as Monstre
		if voisin != self and voisin.id_monstre == id_monstre and voisin.etat == Etat.ERRANCE \
				and voisin.global_position.distance_to(global_position) <= rayon:
			voisin.etat = Etat.POURSUITE


func _physics_process(delta: float) -> void:
	_delta = delta
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
			if not _immobile:
				cible = _errer(delta)
				vitesse = float(_definition.get("vitesse_marche", 1.0))
			if not _passif and _joueur_visible(float(_definition.get("rayon_detection", 0.0))):
				_engager()
		Etat.POURSUITE:
			var laisse := float(_definition.get("rayon_laisse", 12.0))
			if not _joueur_vivant() or _distance_sol(_point_apparition) > laisse \
					or (_immobile and _distance_sol(_joueur.global_position) > laisse):
				etat = Etat.RETOUR
			else:
				var choix := _manoeuvrer()
				cible = choix[0]
				vitesse = choix[1]
				if _invocation.mettre_a_jour(self, _joueur, delta, _hasard):
					_jouer_une_fois("attack")
				_attaque_zone.mettre_a_jour(self, _distance_sol(_joueur.global_position), delta, _frapper_en_zone)
		Etat.RETOUR:
			pv = pv_max
			_barre.visible = false
			_invocation.renvoyer()
			_calmer()
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
	if _recul_restant > 0.0:
		_recul_restant -= vitesse * delta
	if vitesse > 0.0:
		_tourner_vers(global_position + direction, 1.0 - exp(-10.0 * delta))
	if _verrou_animation <= 0.0:
		_modele.jouer("walk" if vitesse > 0.0 else "idle", 0.15)


## Où aller pendant le combat, et à quelle vitesse : [point visé, vitesse].
func _manoeuvrer() -> Array:
	var distance := _distance_sol(_joueur.global_position)
	var loin_du_joueur := global_position - _joueur.global_position
	loin_du_joueur.y = 0.0
	loin_du_joueur = loin_du_joueur.normalized() * 2.0
	var course := float(_definition.get("vitesse_course", 2.0))
	if _recul_restant > 0.0:
		return [global_position + loin_du_joueur, course]
	var portee := float(_definition.get("portee_attaque", 1.1))
	if _immobile:
		_tourner_vers(_joueur.global_position, 1.0)
		if distance <= portee:
			_attaquer()
		return [global_position, 0.0]
	var distance_tir := float(_definition.get("distance_tir", 0.0))
	if distance_tir > 0.0 and distance < distance_tir * 0.5 and _recharge_attaque > 0.0:
		return [global_position + loin_du_joueur, float(_definition.get("vitesse_marche", 1.0))]
	# Encerclement (« encercle ») : entre deux morsures, il tourne autour du joueur au lieu de l'attendre en face.
	if bool(_definition.get("encercle", false)) and _recharge_attaque > 0.3 and distance <= portee * 2.0:
		var depuis_joueur := global_position - _joueur.global_position
		depuis_joueur.y = 0.0
		var tangente := depuis_joueur.normalized().cross(Vector3.UP) * _sens_encerclement
		var rappel := depuis_joueur.normalized() * (portee * 1.3 - distance)
		return [global_position + (tangente * 2.0 + rappel), float(_definition.get("vitesse_marche", 1.0)) * 1.6]
	if distance > portee:
		return [_joueur.global_position, course]
	_tourner_vers(_joueur.global_position, 1.0)
	# Un monstre qui tourne lentement ne frappe que ce qu'il a devant lui : on peut le contourner.
	if _vitesse_rotation <= 0.0 or _face_au_joueur(40.0):
		_attaquer()
	return [global_position, 0.0]


## Sous un seuil de vie (« enrage » : {"seuil": part de la vie, "vitesse": …, "degats": …}), il enrage.
func _verifier_la_rage() -> void:
	var rage: Dictionary = _definition.get("enrage", {})
	if rage.is_empty() or enrage or pv > pv_max * float(rage.get("seuil", 0.5)):
		return
	enrage = true
	ChiffreFlottant.afficher(get_parent(), global_position + Vector3.UP * (_hauteur_infos + 0.6), "Enragé !", COULEUR_RAGE, 64, 1.4, 0.6)
	if _matiere_aura != null:
		_matiere_aura.albedo_color = Color(COULEUR_RAGE, 0.85)
	_modele.regler_vitesse_animation(float(rage.get("vitesse", 1.0)))


## De retour chez lui, il se calme (sa vie remonte au maximum).
func _calmer() -> void:
	if not enrage:
		return
	enrage = false
	if _matiere_aura != null:
		_matiere_aura.albedo_color = Color(_couleur_du_rang(), 0.7)
	_modele.regler_vitesse_animation(1.0)


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
	var rage: Dictionary = _definition.get("enrage", {})
	if enrage:
		intervalle /= float(rage.get("vitesse", 1.0))
	_recharge_attaque = intervalle
	_jouer_une_fois("attack")
	var degats := Combat.degats_monstre(niveau, _joueur.niveau(), _passif, intervalle, Config.jeu, rang)
	if enrage:
		degats *= float(rage.get("degats", 1.0))
	if float(_definition.get("distance_tir", 0.0)) > 0.0:
		var couleur: Color = _definition.get("couleur_tir", Color(0.5, 1.0, 0.4))
		var joueur := _joueur
		var niveau_tireur := niveau
		var tireur: WeakRef = weakref(self)
		BouleMagique.lancer(get_parent(), global_position + Vector3.UP * _hauteur_infos * 0.7, _joueur, couleur,
			func() -> void:
				if is_instance_valid(joueur):
					joueur.recevoir_degats(degats, niveau_tireur, tireur.get_ref() as Monstre))
		return
	_joueur.recevoir_degats(degats, niveau, self)
	_recul_restant = float(_definition.get("recul", 0.0))


## Fin du préavis de l'attaque de zone : le joueur est frappé s'il est encore dans le cercle.
func _frapper_en_zone(multiplicateur: float, rayon: float) -> void:
	if not est_vivant() or not _joueur_vivant() or _distance_sol(_joueur.global_position) > rayon:
		return
	_jouer_une_fois("attack")
	var degats := Combat.degats_monstre(niveau, _joueur.niveau(), _passif, float(_definition.get("intervalle_attaque", 1.5)),
		Config.jeu, rang) * multiplicateur
	_joueur.recevoir_degats(degats, niveau, self)


func _couleur_du_rang() -> Color:
	return COULEUR_SOUS_BOSS if rang == Combat.RANG_SOUS_BOSS else COULEUR_CHAMPION


## Un coup porte : éclair blanc, étincelles, et le monstre recule un instant en se tassant.
func _encaisser(critique: bool) -> void:
	if _modele == null or not is_inside_tree():
		return
	var config := Config.jeu
	_modele.eclairer(config.combat("impact", "duree_eclair"), config.combat("impact", "force_eclair"))
	var vers_le_monstre := Vector3.FORWARD
	if _joueur_vivant():
		vers_le_monstre = global_position - _joueur.global_position
		vers_le_monstre.y = 0.0
		vers_le_monstre = vers_le_monstre.normalized() if vers_le_monstre.length() > 0.01 else Vector3.FORWARD
	EffetsDeCoup.etincelles(get_parent(), global_position + Vector3.UP * _hauteur_infos * 0.55 - vers_le_monstre * 0.3, critique)
	var recul := config.combat("impact", "recul_monstre") * (1.6 if critique else 1.0)
	if _reaction != null:
		_reaction.kill()
	_modele.position = Vector3.ZERO
	_modele.scale = _echelle_modele
	_reaction = create_tween()
	_reaction.tween_property(_modele, "position", vers_le_monstre * recul, 0.06).set_ease(Tween.EASE_OUT)
	_reaction.parallel().tween_property(_modele, "scale", _echelle_modele * Vector3(1.08, 0.9, 1.08), 0.06)
	_reaction.tween_property(_modele, "position", Vector3.ZERO, 0.18).set_trans(Tween.TRANS_SINE)
	_reaction.parallel().tween_property(_modele, "scale", _echelle_modele, 0.18).set_trans(Tween.TRANS_SINE)


func _mourir() -> void:
	etat = Etat.MORT
	remove_from_group(GROUPE)
	collision_layer = 0
	_barre.visible = false
	_etiquette.visible = false
	_modele.jouer("die", 0.1, false)
	mort.emit(self)
	# Le corps reste un instant, puis s'enfonce dans un nuage de poussière.
	var taille := clampf(_hauteur_infos / 1.2, 0.6, 2.5)
	var disparition := create_tween()
	disparition.tween_interval(1.3)
	disparition.tween_callback(func() -> void: EffetsDeCoup.poussiere(get_parent(), global_position, taille))
	disparition.tween_property(_modele, "position:y", -0.6 * taille, 0.5).set_ease(Tween.EASE_IN)
	disparition.parallel().tween_property(_modele, "scale", _echelle_modele * 0.3, 0.5).set_ease(Tween.EASE_IN)
	disparition.tween_callback(queue_free)


func _jouer_une_fois(animation: String) -> void:
	_modele.jouer(animation, 0.08, false, true)
	_verrou_animation = _modele.duree(animation)


func _tourner_vers(point: Vector3, poids: float) -> void:
	var direction := point - global_position
	if Vector2(direction.x, direction.z).length() <= 0.01:
		return
	var visee := atan2(direction.x, direction.z)
	if _vitesse_rotation > 0.0:
		_modele.rotation.y = rotate_toward(_modele.rotation.y, visee, _vitesse_rotation * _delta)
	else:
		_modele.rotation.y = lerp_angle(_modele.rotation.y, visee, poids)


func _joueur_vivant() -> bool:
	return is_instance_valid(_joueur) and _joueur.est_vivant()


func _joueur_visible(rayon: float) -> bool:
	return _joueur_vivant() and _distance_sol(_joueur.global_position) < rayon


func _distance_sol(point: Vector3) -> float:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length()
