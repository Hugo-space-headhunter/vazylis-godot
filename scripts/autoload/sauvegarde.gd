extends Node
## Autoload « Sauvegarde » : garde la partie sur l'appareil et en ligne (Supabase).
##
##   un changement → sur l'appareil après un court instant (marche sans réseau)
##                 → en ligne quelques secondes après (et tout de suite quand on quitte l'app)
##   au lancement  → on prend la plus récente des deux sauvegardes.
##
## Pendant les tests automatiques (jeu lancé sans écran), la sauvegarde est éteinte :
## les tests ne touchent jamais à la partie de Hugo.

signal etat_change(etat: Etat)
## Une sauvegarde en ligne plus récente que la partie en cours a été trouvée (après un démarrage
## hors ligne) : elle n'est pas écrasée, il faut relancer l'app pour la reprendre.
signal sauvegarde_en_ligne_plus_recente

enum Etat { ETEINTE, CHARGEMENT, A_JOUR, ENVOI, APPAREIL_SEUL }

const CHEMIN_REGLAGES := "res://config/sauvegarde.cfg"

var etat := Etat.ETEINTE
## Vrai si la sauvegarde fonctionne (faux pendant les tests automatiques).
var active := false

var _en_ligne: DepotSupabase
var _a_enregistrer := {}
var _attente_appareil := -1.0
var _attente_en_ligne := -1.0
var _delai_appareil := 0.5
var _delai_en_ligne := 4.0
var _envoi_en_cours := false
## Vrai quand la sauvegarde en ligne a été lue au moins une fois : avant, on n'écrit pas en ligne,
## pour ne jamais écraser une partie plus récente qu'on n'a pas pu lire (démarrage hors ligne).
var _en_ligne_lue := false
## Date de la partie chargée au lancement.
var _date_partie_chargee := 0.0
var _conflit := false


func _ready() -> void:
	active = DisplayServer.get_name() != "headless"
	var reglages := ConfigFile.new()
	if reglages.load(CHEMIN_REGLAGES) != OK:
		push_error("Sauvegarde : impossible de lire %s." % CHEMIN_REGLAGES)
		active = false
		return
	_delai_appareil = float(reglages.get_value("envoi", "delai_appareil", 0.5))
	_delai_en_ligne = float(reglages.get_value("envoi", "delai_en_ligne", 4.0))
	_en_ligne = DepotSupabase.new(reglages)
	add_child(_en_ligne)


## Charge la partie : la plus récente entre l'appareil et la sauvegarde en ligne ({} s'il n'y en a pas).
func charger() -> Dictionary:
	if not active:
		return {}
	_changer_etat(Etat.CHARGEMENT)
	var locale := DepotAppareil.lire()
	var distante: Variant = await _en_ligne.lire()
	var choisie := locale
	if distante == null:
		_changer_etat(Etat.APPAREIL_SEUL)
	else:
		_en_ligne_lue = true
		_changer_etat(Etat.A_JOUR)
		if float((distante as Dictionary).get("sauvegarde_le", 0.0)) >= float(locale.get("sauvegarde_le", 0.0)):
			choisie = distante
	_date_partie_chargee = float(choisie.get("sauvegarde_le", 0.0))
	return choisie


## Demande d'enregistrer la partie (les envois sont regroupés).
func enregistrer(donnees: Dictionary) -> void:
	if not active:
		return
	donnees["sauvegarde_le"] = Time.get_unix_time_from_system()
	_a_enregistrer = donnees
	_attente_appareil = _delai_appareil
	if _attente_en_ligne < 0.0:
		_attente_en_ligne = _delai_en_ligne


## Écrit tout de suite (par exemple quand on quitte l'app).
func enregistrer_maintenant() -> void:
	if not active or _a_enregistrer.is_empty():
		return
	DepotAppareil.ecrire(_a_enregistrer)
	_attente_appareil = -1.0
	_attente_en_ligne = -1.0
	_envoyer()


## Efface la partie (bouton « Nouvelle partie ») : sur l'appareil et en ligne.
func effacer() -> void:
	_a_enregistrer = {}
	_attente_appareil = -1.0
	_attente_en_ligne = -1.0
	if not active:
		return
	DepotAppareil.effacer()
	_changer_etat(Etat.ENVOI)
	_en_ligne_lue = true
	_conflit = false
	var reussi: bool = await _en_ligne.ecrire({})
	_changer_etat(Etat.A_JOUR if reussi else Etat.APPAREIL_SEUL)


func _process(delta: float) -> void:
	if _attente_appareil >= 0.0:
		_attente_appareil -= delta
		if _attente_appareil < 0.0:
			DepotAppareil.ecrire(_a_enregistrer)
	if _attente_en_ligne >= 0.0:
		_attente_en_ligne -= delta
		if _attente_en_ligne < 0.0:
			_envoyer()


func _envoyer() -> void:
	if _envoi_en_cours:
		_attente_en_ligne = _delai_en_ligne
		return
	_envoi_en_cours = true
	_changer_etat(Etat.ENVOI)
	if not _en_ligne_lue and not await _verifier_avant_d_ecrire():
		_envoi_en_cours = false
		_changer_etat(Etat.APPAREIL_SEUL)
		if not _conflit:
			_attente_en_ligne = _delai_en_ligne * 4.0
		return
	var reussi: bool = await _en_ligne.ecrire(_a_enregistrer)
	_envoi_en_cours = false
	_changer_etat(Etat.A_JOUR if reussi else Etat.APPAREIL_SEUL)
	if not reussi and _attente_en_ligne < 0.0:
		# Pas de réseau : on réessaiera plus tard.
		_attente_en_ligne = _delai_en_ligne * 4.0


## Après un démarrage hors ligne : on relit la sauvegarde en ligne avant d'oser l'écrire.
## Si elle est plus récente que la partie chargée au lancement, on ne l'écrase pas.
func _verifier_avant_d_ecrire() -> bool:
	if _conflit:
		return false
	var distante: Variant = await _en_ligne.lire()
	if distante == null:
		return false
	if float((distante as Dictionary).get("sauvegarde_le", 0.0)) > _date_partie_chargee:
		_conflit = true
		sauvegarde_en_ligne_plus_recente.emit()
		return false
	_en_ligne_lue = true
	return true


func _notification(quoi: int) -> void:
	if quoi in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST]:
		enregistrer_maintenant()


func _changer_etat(nouvel_etat: Etat) -> void:
	etat = nouvel_etat
	etat_change.emit(etat)
