extends VBoxContainer
## Affichage provisoire du niveau, de la vie et de l'XP (le vrai bandeau arrive à l'étape 3).

@onready var _niveau: Label = $Niveau
@onready var _vie: ProgressBar = $Vie
@onready var _xp: ProgressBar = $XP
@onready var _message: Label = $Message


func afficher_pv(pv: float, pv_max: float) -> void:
	_vie.max_value = pv_max
	_vie.value = pv
	_vie.tooltip_text = ""
	$Vie/Texte.text = "Vie %d / %d" % [ceili(pv), roundi(pv_max)]


func afficher_xp(xp: int, xp_requise: int, niveau: int) -> void:
	_niveau.text = "Niveau %d" % niveau
	_xp.max_value = xp_requise
	_xp.value = xp
	$XP/Texte.text = "XP %d / %d" % [xp, xp_requise]


func afficher_mort() -> void:
	_message.text = "Vaincu… retour au départ"
	_message.visible = true


func cacher_message() -> void:
	_message.visible = false
