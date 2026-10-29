class_name ApercuPersonnage
extends SubViewportContainer
## Le personnage en 3D dans la fenêtre du sac, avec tout son équipement porté.
## Il tourne doucement ; on peut aussi le faire tourner en glissant le doigt dessus.

const TAILLE := Vector2(200, 280)
const VITESSE_ROTATION := 0.4
const POINTS_ATTACHE := {"modele_main_droite": "main_droite", "modele_main_gauche": "main_gauche"}

var _vue: SubViewport
var _socle: Node3D
var _modele: ModeleAsset
var _habillage := Habillage.new()
var _armes: Array[ModeleAsset] = []
var _joueur: Joueur
var _glisse := false


func _ready() -> void:
	custom_minimum_size = TAILLE
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_vue = SubViewport.new()
	_vue.own_world_3d = true
	_vue.transparent_bg = true
	_vue.size = Vector2i(TAILLE)
	_vue.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(_vue)
	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_CLEAR_COLOR
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color(0.8, 0.82, 0.9)
	environnement.environment.ambient_light_energy = 0.7
	_vue.add_child(environnement)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-35, 30, 0)
	_vue.add_child(lumiere)
	var camera := Camera3D.new()
	camera.fov = 32.0
	_vue.add_child(camera)
	camera.look_at_from_position(Vector3(0, 1.15, 4.0), Vector3(0, 0.92, 0))
	_socle = Node3D.new()
	_vue.add_child(_socle)


func relier(joueur: Joueur) -> void:
	_joueur = joueur
	_joueur.equipement_change.connect(rafraichir)


## Recrée le personnage affiché avec l'équipement actuel du joueur.
func rafraichir() -> void:
	if _joueur == null or not is_visible_in_tree():
		return
	var config := Config.jeu
	var rotation_actuelle := _socle.rotation.y
	if _modele != null:
		_habillage.vider()
		_modele.queue_free()
	_armes.clear()
	_modele = CatalogueAssets.creer(_joueur.personnage)
	_socle.add_child(_modele)
	_socle.rotation.y = rotation_actuelle
	_modele.jouer("idle", 0.0)
	_habillage.habiller(_modele, _joueur.equipement, _joueur.est_une_femme())
	var arme := _joueur.equipement.arme()
	if arme != null:
		var famille := config.famille_objet(arme.famille)
		for cle: String in POINTS_ATTACHE:
			var modele_id := str(famille.get(cle, ""))
			if modele_id.is_empty():
				continue
			var modele_arme := CatalogueAssets.creer(modele_id)
			ApparenceRarete.appliquer(modele_arme, arme.rarete)
			ApparenceRarete.ajouter_etincelles(modele_arme, arme.rarete, modele_arme.boite_englobante())
			modele_arme.accrocher_a(_modele, POINTS_ATTACHE[cle], Joueur.VARIANTE_REPOS)
			_armes.append(modele_arme)


func _process(delta: float) -> void:
	if not _glisse and _socle != null:
		_socle.rotate_y(VITESSE_ROTATION * delta)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_glisse = (event as InputEventMouseButton).pressed
	elif event is InputEventMouseMotion and _glisse:
		_socle.rotate_y((event as InputEventMouseMotion).relative.x * 0.012)
