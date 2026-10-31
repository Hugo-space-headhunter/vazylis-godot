class_name DispositionInterface
extends Node
## Place les boutons et le bandeau selon l'orientation de l'écran, toujours à l'intérieur
## des zones de sécurité (encoche, barre d'état, barre d'accueil), voir ZoneSecurite.
##
##   - en haut à gauche : le bandeau (vie, mana, XP) ; en haut à droite : le menu « Test » ;
##   - en bas à droite : Arme et Pied, avec AFK à leur gauche ;
##   - paysage (deux mains) : statistiques et sac sous le bandeau, forge au-dessus d'AFK ;
##   - portrait (une main) : statistiques, sac et forge descendent au-dessus d'Arme et Pied,
##     là où va le pouce.

## Écart entre deux éléments (unités de l'interface).
const ECART := 20.0
## La taille et les marges peuvent changer après une rotation (l'iPhone met les marges à jour
## un peu plus tard) : on les relit régulièrement.
const INTERVALLE_VERIFICATION := 1.0

@export var bandeau: Control
@export var bouton_statistiques: Control
@export var bouton_sac: Control
@export var bouton_forge: Control
@export var boutons_mode: Control
@export var bouton_afk: Control
@export var outils_test: Control
@export var annonces: Control
@export var compteur: Control

## Orientation de la dernière mise en place (pour les tests).
var portrait := false
var _marges := Vector4(-1, -1, -1, -1)
var _taille := Vector2.ZERO
var _attente := 0.0


func _ready() -> void:
	get_viewport().size_changed.connect(placer)
	placer.call_deferred()


func _process(delta: float) -> void:
	_attente -= delta
	if _attente > 0.0:
		return
	_attente = INTERVALLE_VERIFICATION
	if get_viewport().get_visible_rect().size != _taille or ZoneSecurite.marges(get_viewport()) != _marges:
		placer()


## Met chaque élément à sa place pour la taille et les marges actuelles de l'écran.
func placer() -> void:
	var ecran := get_viewport().get_visible_rect().size
	_marges = ZoneSecurite.marges(get_viewport())
	_taille = ecran
	portrait = ecran.y > ecran.x
	var gauche := _marges.x
	var haut := _marges.y
	var droite := ecran.x - _marges.z
	var bas := ecran.y - _marges.w

	_mettre(bandeau, Vector2(gauche, haut))
	_mettre(outils_test, Vector2(droite - _taille_de(outils_test).x, haut))
	var sous_bandeau := haut + _taille_de(bandeau).y + ECART
	_mettre(annonces, Vector2((ecran.x - _taille_de(annonces).x) / 2.0, sous_bandeau + 90.0))

	var modes := Vector2(droite, bas) - _taille_de(boutons_mode)
	_mettre(boutons_mode, modes)
	var afk := Vector2(modes.x - ECART - _taille_de(bouton_afk).x, bas - _taille_de(bouton_afk).y - 10.0)
	_mettre(bouton_afk, afk)

	var bas_des_menus := sous_bandeau
	if portrait:
		var ligne := modes.y - ECART - _taille_de(bouton_sac).y
		var sac := Vector2(droite - _taille_de(bouton_sac).x, ligne)
		_mettre(bouton_sac, sac)
		var stats := Vector2(sac.x - ECART - _taille_de(bouton_statistiques).x, ligne)
		_mettre(bouton_statistiques, stats)
		_mettre(bouton_forge, Vector2(stats.x - ECART - _taille_de(bouton_forge).x, ligne))
	else:
		_mettre(bouton_statistiques, Vector2(gauche, sous_bandeau))
		_mettre(bouton_sac, Vector2(gauche + _taille_de(bouton_statistiques).x + 12.0, sous_bandeau))
		_mettre(bouton_forge, Vector2(afk.x, afk.y - ECART - _taille_de(bouton_forge).y))
		bas_des_menus = sous_bandeau + _taille_de(bouton_sac).y + ECART
	_mettre(compteur, Vector2(gauche, bas_des_menus))


func _taille_de(element: Control) -> Vector2:
	if element == null:
		return Vector2.ZERO
	return element.size.max(element.get_combined_minimum_size())


func _mettre(element: Control, coin: Vector2) -> void:
	if element == null:
		return
	var taille := _taille_de(element)
	element.set_anchors_preset(Control.PRESET_TOP_LEFT)
	element.position = coin.round()
	element.size = taille
