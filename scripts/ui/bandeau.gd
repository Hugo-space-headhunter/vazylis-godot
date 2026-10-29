extends PanelContainer
## Bandeau compact en haut à gauche : nom, niveau, vie, mana et XP.

@onready var _nom: Label = $Contenu/Ligne/Nom
@onready var _niveau: Label = $Contenu/Ligne/Niveau
@onready var _vie: ProgressBar = $Contenu/Vie
@onready var _mana: ProgressBar = $Contenu/Mana
@onready var _xp: ProgressBar = $Contenu/XP
@onready var _message: Label = $Contenu/Message
@onready var _sauvegarde: Label = $Contenu/Sauvegarde

const TEXTES_SAUVEGARDE := {
	0: ["", Color.WHITE],
	1: ["Chargement…", Color(0.85, 0.85, 0.9)],
	2: ["Sauvegardé en ligne", Color(0.45, 0.95, 0.5)],
	3: ["Envoi de la sauvegarde…", Color(1, 0.8, 0.35)],
	4: ["Hors ligne : sauvegardé sur l'appareil", Color(1, 0.55, 0.45)],
}


func afficher_nom(nom: String) -> void:
	_nom.text = nom


func afficher_pv(pv: float, pv_max: float) -> void:
	_regler(_vie, pv, pv_max, "%d / %d" % [ceili(pv), roundi(pv_max)])


func afficher_mana(mana: float, mana_max: float) -> void:
	_regler(_mana, mana, mana_max, "%d / %d" % [roundi(mana), roundi(mana_max)])


func afficher_xp(xp: int, xp_requise: int, niveau: int) -> void:
	_niveau.text = "Niv. %d" % niveau
	_regler(_xp, xp, xp_requise, "XP %d / %d" % [xp, xp_requise])


## Petit voyant de la sauvegarde (voir l'autoload Sauvegarde).
func afficher_sauvegarde(etat: int) -> void:
	var texte: Array = TEXTES_SAUVEGARDE.get(etat, ["", Color.WHITE])
	_sauvegarde.text = texte[0]
	_sauvegarde.add_theme_color_override("font_color", texte[1])
	_sauvegarde.visible = not str(texte[0]).is_empty()


func afficher_mort() -> void:
	_message.text = "Vaincu… retour au départ"
	_message.visible = true


func cacher_message() -> void:
	_message.visible = false


func _regler(barre: ProgressBar, valeur: float, maximum: float, texte: String) -> void:
	barre.max_value = maxf(maximum, 1.0)
	barre.value = valeur if maximum > 0.0 else 0.0
	(barre.get_node("Texte") as Label).text = texte
