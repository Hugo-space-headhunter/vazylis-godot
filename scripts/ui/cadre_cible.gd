class_name CadreCible
extends PanelContainer
## Cadre de la cible, en haut de l'écran : le monstre que le joueur combat, son niveau (dans la couleur
## du danger), sa vie, et son rang (champion, sous-boss). Caché quand il n'y a pas de cible.

const LARGEUR := 300.0

@export var joueur: Joueur

var _nom: Label
var _niveau: Label
var _vie: ProgressBar
var _cible: Monstre


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(LARGEUR, 0)
	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 4)
	colonne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(colonne)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonne.add_child(ligne)
	_nom = _texte(22)
	_nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_nom.clip_text = true
	ligne.add_child(_nom)
	_niveau = _texte(20)
	ligne.add_child(_niveau)
	_vie = ProgressBar.new()
	_vie.custom_minimum_size = Vector2(0, 14)
	_vie.show_percentage = false
	_vie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fond := StyleBoxFlat.new()
	fond.bg_color = Color(0, 0, 0, 0.55)
	fond.set_corner_radius_all(5)
	_vie.add_theme_stylebox_override("background", fond)
	var remplissage := StyleBoxFlat.new()
	remplissage.bg_color = Color(0.85, 0.2, 0.2)
	remplissage.set_corner_radius_all(5)
	_vie.add_theme_stylebox_override("fill", remplissage)
	colonne.add_child(_vie)
	visible = false


func _texte(taille: int) -> Label:
	var etiquette := Label.new()
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_outline_color", Color.BLACK)
	etiquette.add_theme_constant_override("outline_size", 5)
	etiquette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiquette


func _process(_delta: float) -> void:
	var cible := joueur.cible() if is_instance_valid(joueur) else null
	if cible != _cible:
		_cible = cible
		if cible != null:
			var prefixe: String = {Combat.RANG_CHAMPION: "Champion · ", Combat.RANG_SOUS_BOSS: "★ "}.get(cible.rang, "")
			_nom.text = prefixe + cible.nom
			_niveau.text = "niv. %d" % cible.niveau
	visible = _cible != null
	if _cible != null:
		_niveau.add_theme_color_override("font_color", _cible.couleur_du_niveau())
		_vie.value = 100.0 * _cible.pv / maxf(_cible.pv_max, 1.0)
