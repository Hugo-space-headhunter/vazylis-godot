extends PanelContainer
## Bandeau compact en haut à gauche : nom, niveau, vie, mana et XP.

@onready var _nom: Label = $Contenu/Ligne/Nom
@onready var _niveau: Label = $Contenu/Ligne/Niveau
@onready var _vie: ProgressBar = $Contenu/Vie
@onready var _mana: ProgressBar = $Contenu/Mana
@onready var _xp: ProgressBar = $Contenu/XP
@onready var _message: Label = $Contenu/Message


func afficher_nom(nom: String) -> void:
	_nom.text = nom


func afficher_pv(pv: float, pv_max: float) -> void:
	_regler(_vie, pv, pv_max, "%d / %d" % [ceili(pv), roundi(pv_max)])


func afficher_mana(mana: float, mana_max: float) -> void:
	_regler(_mana, mana, mana_max, "%d / %d" % [roundi(mana), roundi(mana_max)])


func afficher_xp(xp: int, xp_requise: int, niveau: int) -> void:
	_niveau.text = "Niv. %d" % niveau
	_regler(_xp, xp, xp_requise, "XP %d / %d" % [xp, xp_requise])


func afficher_mort() -> void:
	_message.text = "Vaincu… retour au départ"
	_message.visible = true


func cacher_message() -> void:
	_message.visible = false


func _regler(barre: ProgressBar, valeur: float, maximum: float, texte: String) -> void:
	barre.max_value = maxf(maximum, 1.0)
	barre.value = valeur if maximum > 0.0 else 0.0
	(barre.get_node("Texte") as Label).text = texte
