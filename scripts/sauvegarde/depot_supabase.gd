class_name DepotSupabase
extends Node
## Sauvegarde en ligne avec Supabase (réglages dans config/sauvegarde.cfg).
##
## Chaque appareil a un compte anonyme invisible (pas de mot de passe), créé la première fois
## et mémorisé dans « user://session_supabase.json ». La partie est rangée dans la table « saves »,
## une ligne par compte : {user_id, data, updated_at}. Les règles de sécurité de Supabase
## empêchent un compte de lire ou d'écrire la ligne d'un autre.

const CHEMIN_SESSION := "user://session_supabase.json"
## On renouvelle la session un peu avant qu'elle expire (secondes).
const MARGE_EXPIRATION := 120

var _url := ""
var _cle := ""
var _table := "saves"
var _delai := 10.0
var _session := {}


func _init(reglages: ConfigFile) -> void:
	_url = str(reglages.get_value("supabase", "url", "")).trim_suffix("/")
	_cle = str(reglages.get_value("supabase", "cle_publique", ""))
	_table = str(reglages.get_value("supabase", "table", "saves"))
	_delai = float(reglages.get_value("supabase", "delai_reponse", 10.0))


## La partie enregistrée en ligne ({} s'il n'y en a pas), ou null si Supabase ne répond pas.
func lire() -> Variant:
	if not await _assurer_session():
		return null
	var reponse := await _requete(HTTPClient.METHOD_GET,
		"/rest/v1/%s?select=data&user_id=eq.%s" % [_table, _session["user_id"]], null)
	if reponse["code"] != 200 or not reponse["donnees"] is Array:
		push_warning("Sauvegarde : lecture en ligne impossible (code %d)." % reponse["code"])
		return null
	var lignes: Array = reponse["donnees"]
	if lignes.is_empty() or not lignes[0] is Dictionary:
		return {}
	var donnees: Variant = lignes[0].get("data", {})
	return donnees if donnees is Dictionary else {}


## Enregistre la partie en ligne (remplace la précédente). Renvoie vrai si c'est réussi.
func ecrire(donnees: Dictionary) -> bool:
	if not await _assurer_session():
		return false
	var ligne := {
		"user_id": _session["user_id"],
		"data": donnees,
		"updated_at": Time.get_datetime_string_from_system(true) + "Z",
	}
	var reponse := await _requete(HTTPClient.METHOD_POST, "/rest/v1/%s" % _table, [ligne],
		["Prefer: resolution=merge-duplicates,return=minimal"])
	if reponse["code"] < 200 or reponse["code"] >= 300:
		push_warning("Sauvegarde : écriture en ligne impossible (code %d)." % reponse["code"])
		return false
	return true


## Ouvre (ou renouvelle) la session du compte anonyme de cet appareil.
func _assurer_session() -> bool:
	if _session.is_empty():
		_session = _lire_session()
	var maintenant := int(Time.get_unix_time_from_system())
	if not _session.is_empty() and int(_session.get("expire_a", 0)) > maintenant + MARGE_EXPIRATION:
		return true
	if not _session.is_empty() and _session.has("refresh_token"):
		var renouvellement := await _requete(HTTPClient.METHOD_POST, "/auth/v1/token?grant_type=refresh_token",
			{"refresh_token": _session["refresh_token"]}, [], false)
		if _garder_session(renouvellement):
			return true
	# Pas de session (première fois sur cet appareil) : création du compte anonyme.
	var inscription := await _requete(HTTPClient.METHOD_POST, "/auth/v1/signup", {}, [], false)
	if _garder_session(inscription):
		return true
	push_warning("Sauvegarde : connexion à Supabase impossible (code %d)." % inscription["code"])
	return false


func _garder_session(reponse: Dictionary) -> bool:
	var donnees: Variant = reponse["donnees"]
	if reponse["code"] != 200 or not donnees is Dictionary or not donnees.has("access_token"):
		return false
	var utilisateur: Dictionary = donnees.get("user", {})
	_session = {
		"access_token": donnees["access_token"],
		"refresh_token": donnees.get("refresh_token", ""),
		"user_id": utilisateur.get("id", _session.get("user_id", "")),
		"expire_a": int(Time.get_unix_time_from_system()) + int(donnees.get("expires_in", 3600)),
	}
	var fichier := FileAccess.open(CHEMIN_SESSION, FileAccess.WRITE)
	if fichier != null:
		fichier.store_string(JSON.stringify(_session))
		fichier.close()
	return not str(_session["user_id"]).is_empty()


func _lire_session() -> Dictionary:
	if not FileAccess.file_exists(CHEMIN_SESSION):
		return {}
	var donnees: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHEMIN_SESSION))
	return donnees if donnees is Dictionary else {}


## Envoie une requête à Supabase. Renvoie {"code": code HTTP (0 si pas de réponse), "donnees": réponse lue}.
func _requete(methode: HTTPClient.Method, chemin: String, corps: Variant,
		entetes_en_plus: Array = [], avec_session: bool = true) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = _delai
	# Dans la version web, le navigateur décompresse déjà les réponses : Godot ne doit pas le refaire.
	http.accept_gzip = false
	add_child(http)
	var entetes := PackedStringArray(["apikey: " + _cle, "Content-Type: application/json", "Accept: application/json"])
	if avec_session:
		entetes.append("Authorization: Bearer " + str(_session.get("access_token", "")))
	for entete in entetes_en_plus:
		entetes.append(entete)
	var erreur := http.request(_url + chemin, entetes, methode, JSON.stringify(corps) if corps != null else "")
	if erreur != OK:
		http.queue_free()
		return {"code": 0, "donnees": null}
	var resultat: Array = await http.request_completed
	http.queue_free()
	var texte := (resultat[3] as PackedByteArray).get_string_from_utf8()
	return {"code": int(resultat[1]) if int(resultat[0]) == HTTPRequest.RESULT_SUCCESS else 0,
		"donnees": JSON.parse_string(texte) if not texte.is_empty() else null}
