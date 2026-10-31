class_name ZoneSecurite
extends RefCounted
## Zones de sécurité de l'écran : les bords cachés par l'encoche, la barre d'état ou la barre d'accueil
## de l'iPhone. Les boutons se placent à l'intérieur, le décor peut aller dessous (plein écran).
##
## Sur le web, l'iPhone donne ces marges à la page (« env(safe-area-inset-…) » ; la page s'étend
## sous l'encoche grâce à « viewport-fit=cover », voir export_presets.cfg). Dans une app native,
## Godot les donne directement.

## Marge ajoutée partout, pour que rien ne colle au bord de l'écran (unités de l'interface).
const MARGE_MINIMALE := 16.0

## Marges imposées (gauche, haut, droite, bas), pour les tests et les captures sur le PC
## (par exemple celles d'un iPhone) ; Vector4(-1, …) = lire les vraies marges de l'écran.
static var marges_imposees := Vector4(-1, -1, -1, -1)

const _LIRE_LES_MARGES_DU_NAVIGATEUR := """
(function () {
	var d = document.createElement('div');
	d.style.cssText = 'position:fixed;left:0;top:0;width:0;height:0;visibility:hidden;' +
		'padding:env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left)';
	document.body.appendChild(d);
	var s = getComputedStyle(d);
	var r = [s.paddingTop, s.paddingRight, s.paddingBottom, s.paddingLeft].map(parseFloat);
	d.remove();
	return r.concat([window.innerWidth, window.innerHeight]).join(',');
})()
"""


## Marges de chaque bord, dans les unités de l'interface : x = gauche, y = haut, z = droite, w = bas.
static func marges(viewport: Viewport) -> Vector4:
	var ecran := viewport.get_visible_rect().size
	var brutes := Vector4.ZERO
	if marges_imposees.x >= 0.0:
		brutes = marges_imposees
	elif OS.has_feature("web"):
		brutes = _marges_du_navigateur(ecran)
	elif OS.has_feature("mobile"):
		brutes = _marges_de_l_appareil(ecran)
	return brutes + Vector4.ONE * MARGE_MINIMALE


static func _marges_du_navigateur(ecran: Vector2) -> Vector4:
	var reponse = JavaScriptBridge.eval(_LIRE_LES_MARGES_DU_NAVIGATEUR, true)
	if typeof(reponse) != TYPE_STRING:
		return Vector4.ZERO
	var valeurs := (reponse as String).split_floats(",")
	if valeurs.size() < 6 or valeurs[4] <= 0.0 or valeurs[5] <= 0.0:
		return Vector4.ZERO
	var echelle := Vector2(ecran.x / valeurs[4], ecran.y / valeurs[5])
	return Vector4(valeurs[3] * echelle.x, valeurs[0] * echelle.y, valeurs[1] * echelle.x, valeurs[2] * echelle.y)


static func _marges_de_l_appareil(ecran: Vector2) -> Vector4:
	var sure := Rect2(DisplayServer.get_display_safe_area())
	var fenetre := Vector2(DisplayServer.window_get_size())
	if fenetre.x <= 0.0 or fenetre.y <= 0.0:
		return Vector4.ZERO
	var echelle := ecran / fenetre
	return Vector4(sure.position.x * echelle.x, sure.position.y * echelle.y,
		maxf(0.0, fenetre.x - sure.end.x) * echelle.x, maxf(0.0, fenetre.y - sure.end.y) * echelle.y)
