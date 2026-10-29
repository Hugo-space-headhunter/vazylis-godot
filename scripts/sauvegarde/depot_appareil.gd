class_name DepotAppareil
extends RefCounted
## Sauvegarde sur l'appareil (fichier dans le dossier de l'application, « user:// ») :
## elle marche sans réseau et sert de secours si la sauvegarde en ligne est indisponible.
## Sur l'iPhone (version web), ce dossier est gardé par le navigateur de la web app.

const CHEMIN := "user://sauvegarde.json"


static func lire() -> Dictionary:
	if not FileAccess.file_exists(CHEMIN):
		return {}
	var texte := FileAccess.get_file_as_string(CHEMIN)
	var donnees: Variant = JSON.parse_string(texte)
	if not donnees is Dictionary:
		push_warning("Sauvegarde : le fichier de l'appareil est illisible, il est ignoré.")
		return {}
	return donnees


static func ecrire(donnees: Dictionary) -> bool:
	var fichier := FileAccess.open(CHEMIN, FileAccess.WRITE)
	if fichier == null:
		push_warning("Sauvegarde : écriture sur l'appareil impossible (erreur %d)." % FileAccess.get_open_error())
		return false
	fichier.store_string(JSON.stringify(donnees))
	fichier.close()
	return true


static func effacer() -> void:
	if FileAccess.file_exists(CHEMIN):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CHEMIN))
