class_name EffetButin
extends Node3D
## Un objet tombe : il jaillit du monstre, retombe au sol à côté de lui et y brille dans la couleur
## de sa rareté (colonne de lumière, anneau au sol), en tournant sur lui-même. Quand le personnage
## passe à proximité, ou au bout de quelques secondes, l'objet file vers lui (dans le sac).
## Pas de ramassage à la main : le mode AFK continue de tout récupérer.
## L'objet est déjà rangé dans le sac dès sa chute : cet effet ne fait que le montrer.
## Une belle trouvaille (doré et au-delà) a une colonne plus haute, une onde lumineuse au sol
## et reste plus longtemps. Réglages : section [au_sol] de config/butin.cfg.

const TAILLE := 0.55
## Rang de rareté (0 = standard) à partir duquel une trouvaille est mise en valeur.
const RANG_BELLE_TROUVAILLE := 2
const DUREE_CHUTE := 0.5
const DUREE_VOL := 0.35
const VITESSE_ROTATION := 2.0
## Hauteur où l'objet flotte au-dessus du sol en tournant.
const HAUTEUR_AU_SOL := 0.35

var _modele: ModeleAsset
var _cible: Node3D
var _matiere_colonne: StandardMaterial3D
var _anneau: MeshInstance3D
var _attente := 0.0
var _rayon_aimant := 2.5
var _au_sol := false
var _envole := false


static func jouer(parent: Node, position_depart: Vector3, objet: Objet, cible: Node3D, femme: bool) -> EffetButin:
	var effet := EffetButin.new()
	effet._cible = cible
	parent.add_child(effet)
	effet.global_position = position_depart
	effet._lancer(objet, femme)
	return effet


func _lancer(objet: Objet, femme: bool) -> void:
	var config := Config.jeu
	var couleur := config.couleur_rarete(objet.rarete)
	var rang := maxi(0, config.ids_raretes().find(objet.rarete))
	_rayon_aimant = config.butin("au_sol", "rayon_aimant")
	_attente = config.butin("au_sol", "duree_max") + config.butin("au_sol", "duree_par_rang") * rang

	_modele = CatalogueAssets.creer(objet.modele(config, femme))
	ApparenceRarete.appliquer(_modele, objet.rarete)
	add_child(_modele)
	var boite := _modele.boite_englobante()
	var plus_grand := maxf(boite.size.x, maxf(boite.size.y, boite.size.z))
	if plus_grand > 0.001:
		_modele.scale = Vector3.ONE * (TAILLE / plus_grand)
	var centre := -(boite.get_center() * _modele.scale)

	# Point de chute : un peu à côté du monstre, au hasard.
	var angle := randf() * TAU
	var chute := Vector3(cos(angle), 0, sin(angle)) * randf_range(0.6, 1.2)
	var arrivee := centre + chute + Vector3.UP * HAUTEUR_AU_SOL
	_modele.position = centre + Vector3.UP * 1.0
	var saut := create_tween()
	saut.tween_method(func(t: float) -> void:
		_modele.position = (centre + Vector3.UP * 1.0).lerp(arrivee, t) + Vector3.UP * sin(t * PI) * 0.9, 0.0, 1.0, DUREE_CHUTE)
	saut.tween_callback(_poser.bind(chute, couleur, rang, objet))


## L'objet touche le sol : colonne de lumière, anneau et nom dans la couleur de sa rareté.
func _poser(chute: Vector3, couleur: Color, rang: int, objet: Objet) -> void:
	_au_sol = true
	var colonne := MeshInstance3D.new()
	var cylindre := CylinderMesh.new()
	cylindre.top_radius = 0.1 + 0.03 * rang
	cylindre.bottom_radius = 0.22 + 0.05 * rang
	cylindre.height = 1.0 + 0.6 * rang
	cylindre.cap_top = false
	cylindre.cap_bottom = false
	cylindre.radial_segments = 12
	colonne.mesh = cylindre
	colonne.position = chute + Vector3.UP * cylindre.height / 2.0
	colonne.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_matiere_colonne = StandardMaterial3D.new()
	_matiere_colonne.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_matiere_colonne.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_matiere_colonne.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_matiere_colonne.cull_mode = BaseMaterial3D.CULL_DISABLED
	_matiere_colonne.albedo_color = Color(couleur, 0.0)
	colonne.material_override = _matiere_colonne
	add_child(colonne)
	create_tween().tween_property(_matiere_colonne, "albedo_color:a", 0.3 + 0.04 * rang, 0.2)

	_anneau = CercleAuSol.creer(self, "Anneau", 0.45 + 0.08 * rang, Color(couleur, 0.75), 0.03)
	_anneau.position += chute
	var pulsation := _anneau.create_tween().set_loops()
	pulsation.tween_property(_anneau, "scale", Vector3.ONE * 1.15, 0.6).set_trans(Tween.TRANS_SINE)
	pulsation.tween_property(_anneau, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_SINE)

	var texte := objet.nom if rang < RANG_BELLE_TROUVAILLE else "%s !" % objet.nom
	ChiffreFlottant.afficher(get_parent(), global_position + chute + Vector3.UP * 1.2, texte, couleur, 30 + 5 * rang, 1.4, 0.5)
	if rang >= RANG_BELLE_TROUVAILLE:
		_onde_au_sol(chute, couleur, rang)


## Onde de lumière qui s'étale au sol depuis l'objet, deux fois pour les plus rares.
func _onde_au_sol(chute: Vector3, couleur: Color, rang: int) -> void:
	for i in (2 if rang >= RANG_BELLE_TROUVAILLE + 2 else 1):
		var onde := CercleAuSol.creer(self, "Onde", 1.0, Color(couleur, 0.9), 0.04)
		onde.position += chute
		onde.scale = Vector3.ONE * 0.2
		var matiere := CercleAuSol.matiere(onde)
		var vague := onde.create_tween()
		vague.tween_interval(0.25 * i)
		vague.tween_property(onde, "scale", Vector3.ONE * (1.6 + 0.3 * rang), 0.9).set_ease(Tween.EASE_OUT)
		vague.parallel().tween_property(matiere, "albedo_color:a", 0.0, 0.9)


func _process(delta: float) -> void:
	if is_instance_valid(_modele) and not _envole:
		_modele.rotate_y(VITESSE_ROTATION * delta)
	if not _au_sol or _envole:
		return
	_attente -= delta
	var proche := is_instance_valid(_cible) and \
		Vector2(_cible.global_position.x - _modele.global_position.x, _cible.global_position.z - _modele.global_position.z).length() <= _rayon_aimant
	if proche or _attente <= 0.0 or not is_instance_valid(_cible):
		_envoler()


## Le personnage passe à côté (ou l'attente est finie) : l'objet file vers lui en rapetissant.
func _envoler() -> void:
	_envole = true
	var depart := _modele.global_position
	var echelle := _modele.scale
	var vol := create_tween()
	vol.tween_method(func(t: float) -> void:
		if not is_instance_valid(_cible):
			return
		_modele.global_position = depart.lerp(_cible.global_position + Vector3.UP * 1.0, t) + Vector3.UP * sin(t * PI) * 0.5
		_modele.scale = echelle.lerp(echelle * 0.1, t), 0.0, 1.0, DUREE_VOL).set_ease(Tween.EASE_IN)
	vol.parallel().tween_property(_matiere_colonne, "albedo_color:a", 0.0, DUREE_VOL)
	if _anneau != null:
		vol.parallel().tween_property(_anneau, "scale", Vector3.ONE * 0.01, DUREE_VOL)
	vol.tween_callback(queue_free)


## Pour les tests : l'objet est-il encore au sol ?
func est_au_sol() -> bool:
	return _au_sol and not _envole
