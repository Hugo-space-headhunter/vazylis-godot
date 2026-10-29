class_name CaseObjet
extends Button
## Une case qui montre un objet (dans le sac ou sur le personnage).
## On peut la toucher (pour voir la fiche) ou la faire glisser vers une autre case.

## Une case a été déposée sur celle-ci : source = {"lieu": "sac"|"equipement", "cle": …}.
signal deposee(source: Dictionary, cible: Dictionary)

const TAILLE := 58

## « sac » (cle = numéro de case) ou « equipement » (cle = emplacement).
var lieu := "sac"
var cle: Variant = 0
## Vrai si un objet est dans la case (sinon elle ne se fait pas glisser).
var occupee := false
## Dit si l'objet décrit par « source » peut être déposé ici.
var peut_recevoir: Callable

var _niveau: Label
var _nom_vide: Label


func _init() -> void:
	custom_minimum_size = Vector2(TAILLE, TAILLE)
	focus_mode = Control.FOCUS_NONE
	expand_icon = true
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_niveau = _etiquette(14, Vector2(4, TAILLE - 22))
	_nom_vide = _etiquette(11, Vector2(2, TAILLE - 18))
	_nom_vide.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	_nom_vide.size = Vector2(TAILLE - 4, 16)
	_nom_vide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nom_vide.clip_text = true


## Affiche un objet (vignette, couleur de rareté, niveau) ou une case vide.
func afficher(texture: Texture2D, couleur: Color, niveau: int, choisie: bool, nom_si_vide: String = "", bloquee: bool = false) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = couleur.darkened(0.75) if occupee else Color(0, 0, 0, 0.25 if bloquee else 0.45)
	style.border_color = couleur if occupee else Color(1, 1, 1, 0.08 if bloquee else 0.15)
	style.set_border_width_all(4 if choisie else 2)
	style.set_corner_radius_all(8)
	for etat in ["normal", "hover", "pressed", "disabled"]:
		add_theme_stylebox_override(etat, style)
	icon = texture if occupee else null
	_niveau.text = str(niveau) if occupee else ""
	_nom_vide.text = nom_si_vide if not occupee else ""
	disabled = bloquee


func _get_drag_data(_position: Vector2) -> Variant:
	if not occupee or disabled:
		return null
	var apercu := TextureRect.new()
	apercu.texture = icon
	apercu.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	apercu.size = Vector2(TAILLE, TAILLE)
	apercu.modulate = Color(1, 1, 1, 0.85)
	set_drag_preview(apercu)
	return {"lieu": lieu, "cle": cle}


func _can_drop_data(_position: Vector2, donnees: Variant) -> bool:
	return donnees is Dictionary and donnees.has("lieu") and not disabled \
		and (not peut_recevoir.is_valid() or peut_recevoir.call(donnees))


func _drop_data(_position: Vector2, donnees: Variant) -> void:
	deposee.emit(donnees, {"lieu": lieu, "cle": cle})


func _etiquette(taille: int, position_etiquette: Vector2) -> Label:
	var etiquette := Label.new()
	etiquette.add_theme_font_size_override("font_size", taille)
	etiquette.add_theme_color_override("font_outline_color", Color.BLACK)
	etiquette.add_theme_constant_override("outline_size", 4)
	etiquette.position = position_etiquette
	etiquette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiquette)
	return etiquette
