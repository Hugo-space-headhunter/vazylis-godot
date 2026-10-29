class_name Zone
extends Node3D
## Une zone (ou sous-zone) du monde : son nom, ses niveaux et l'espace qu'elle couvre au sol.
## Le monde est découpé en zones pour pouvoir, plus tard, ne charger que la zone courante et ses voisines.

## Nom affiché quand le joueur y entre.
@export var nom := ""
## Niveaux des monstres, par exemple « 1–10 » (vide pour Vazylis).
@export var niveaux := ""
## Espace couvert au sol : un rectangle (largeur X, profondeur Z) centré sur la zone…
@export var taille := Vector2(20, 20)
## … ou un cercle de ce rayon, s'il est plus grand que zéro.
@export var rayon := 0.0
## Ambiance quand on y entre : couleur du ciel (laisser transparent pour garder celle de départ)
## et force de la lumière (1 = comme au départ, 0.7 = plus sombre).
@export var couleur_ciel := Color(0, 0, 0, 0)
@export var lumiere := 1.0


func contient(point: Vector3) -> bool:
	var ecart := Vector2(point.x - global_position.x, point.z - global_position.z)
	if rayon > 0.0:
		return ecart.length() <= rayon
	return absf(ecart.x) <= taille.x / 2.0 and absf(ecart.y) <= taille.y / 2.0


func titre() -> String:
	return nom if niveaux.is_empty() else "%s  (niv. %s)" % [nom, niveaux]
