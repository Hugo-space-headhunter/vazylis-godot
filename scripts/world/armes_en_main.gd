class_name ArmesEnMain
extends Node
## Les modèles de l'arme portée par le joueur : rangés dans le dos en déplacement, en main en combat.
## S'occupe aussi de l'enchaînement des coups, de la tenue des armes à deux mains (PriseDeuxMains),
## de la corde de l'arc (TirArc) et de la parade.

## Position des armes en main quand on n'attaque pas (voir « placements » du catalogue).
const VARIANTE_REPOS := "repos"
## Réglage de l'arme (objets.cfg ou armes.cfg) → point d'attache sur le personnage.
const POINTS_ATTACHE := {"modele_main_droite": "main_droite", "modele_main_gauche": "main_gauche"}
## Temps sans frapper avant que l'arme à deux mains retombe et traîne derrière (secondes).
const PAUSE_AVANT_TRAINE := 1.0

## Modèle de chaque arme, par point d'attache (« main_droite », « main_gauche »).
var modeles := {}
## Tenue des armes à deux mains (main gauche posée sur la poignée par cinématique inverse).
var prise := PriseDeuxMains.new()
## Le tir à l'arc (main droite qui tire la corde).
var tir := TirArc.new()

var _reglages := {}
var _porteur: ModeleAsset
## Rang du prochain coup dans l'enchaînement d'animations de l'arme.
var _coup_suivant := 0
## L'arme à deux mains est levée pour frapper (sinon elle traîne derrière, dans la main droite).
var _levee := false
## Temps depuis le dernier coup : l'arme à deux mains ne retombe qu'après une pause.
var _sans_frapper := 0.0


func _ready() -> void:
	add_child(prise)
	add_child(tir)


## Crée les modèles d'une arme (objet porté), avec le rendu de sa rareté.
static func creer_modeles(objet: Objet, reglages: Dictionary) -> Dictionary:
	var famille := Config.jeu.famille_objet(objet.famille)
	var resultat := {}
	for cle: String in POINTS_ATTACHE:
		var modele_id := str(famille.get(cle, reglages.get(cle, "")))
		if modele_id.is_empty():
			continue
		var modele := CatalogueAssets.creer(modele_id)
		ApparenceRarete.appliquer(modele, objet.rarete)
		ApparenceRarete.ajouter_etincelles(modele, objet.rarete, modele.boite_englobante())
		resultat[POINTS_ATTACHE[cle]] = modele
	return resultat


## Remplace l'arme affichée. « reglages » : le type d'arme (section de config/armes.cfg).
func changer(objet: Objet, reglages: Dictionary, combat: bool) -> void:
	for modele: ModeleAsset in modeles.values():
		modele.queue_free()
	_reglages = reglages
	modeles = creer_modeles(objet, reglages)
	_coup_suivant = 0
	_installer()
	ranger(combat)


## Le personnage change de modèle (homme ↔ femme) : les armes sont décrochées de l'ancien…
func decrocher() -> void:
	for modele: ModeleAsset in modeles.values():
		if modele.get_parent() != null:
			modele.get_parent().remove_child(modele)


## … puis accrochées au nouveau.
func porter_par(porteur: ModeleAsset, combat: bool) -> void:
	_porteur = porteur
	_installer()
	ranger(combat)


## En main (combat) ou dans le dos (déplacement).
func ranger(combat: bool) -> void:
	if _porteur == null:
		return
	_levee = false
	for point: String in modeles:
		if combat:
			modeles[point].accrocher_a(_porteur, point, VARIANTE_REPOS)
		else:
			modeles[point].accrocher_a(_porteur, "dos")
	prise.relier()
	prise.regler(PriseDeuxMains.Tenue.AUCUNE)


## Le prochain coup de l'enchaînement de l'arme (« animations_attaque », jouées à tour de rôle).
func prochaine_animation() -> String:
	var liste: Array = _reglages.get("animations_attaque", ["attack"])
	if liste.is_empty():
		return "attack"
	var animation := str(liste[_coup_suivant % liste.size()])
	_coup_suivant += 1
	return animation if _porteur.a_animation(animation) else "attack"


## Un coup commence : position de frappe ; l'arme à deux mains se lève, la main gauche la rejoint.
## Pour l'arc, la main droite tire la corde jusqu'au moment où la flèche part (« avant_le_tir » secondes).
func preparer_le_coup(avant_le_tir: float) -> void:
	_sans_frapper = 0.0
	lever()
	varier("")
	tir.bander(avant_le_tir)


## La flèche part : la corde est lâchée.
func lacher_la_corde() -> void:
	tir.lacher()


## Entre deux coups (ou hors combat) : les armes reprennent leur position de repos ;
## l'arme à deux mains attend une courte pause avant de retomber.
func au_repos(delta: float, combat: bool) -> void:
	_sans_frapper += delta
	if not combat:
		return
	if not prise.est_installee():
		varier(VARIANTE_REPOS)
	elif _sans_frapper >= PAUSE_AVANT_TRAINE:
		reposer()


## Arme à deux mains : elle se lève (position de frappe) et la main gauche la rejoint.
func lever() -> void:
	if not prise.est_installee() or _levee:
		return
	_levee = true
	modeles["main_droite"].varier("")
	prise.regler(PriseDeuxMains.Tenue.ATTAQUE)


## Arme à deux mains : elle retombe et traîne derrière, dans la main droite ; la gauche la lâche.
func reposer() -> void:
	if not prise.est_installee() or not _levee:
		return
	_levee = false
	modeles["main_droite"].varier(VARIANTE_REPOS)
	prise.regler(PriseDeuxMains.Tenue.AUCUNE)


## Courte parade quand le bouclier (ou l'arme) bloque. Renvoie sa durée (0 = pas de parade).
func parer() -> float:
	var parade := str(_reglages.get("animation_parade", ""))
	if parade.is_empty() or _porteur == null or not _porteur.a_animation(parade):
		return 0.0
	_porteur.jouer(parade, 0.08, false, true)
	return minf(_porteur.duree(parade), 0.6)


func varier(variante: String) -> void:
	for modele: ModeleAsset in modeles.values():
		modele.varier(variante)


## Arme à deux mains : la cinématique inverse posera la main gauche sur la poignée.
## Arc : la main droite tirera la corde. Sinon, rien.
func _installer() -> void:
	prise.retirer()
	tir.retirer()
	if _porteur == null:
		return
	if bool(_reglages.get("a_distance", false)) and modeles.has("main_gauche"):
		var arc: ModeleAsset = modeles["main_gauche"]
		tir.installer(_porteur, arc, CatalogueAssets.reglage(arc.asset_id, "corde", {}))
	if bool(_reglages.get("deux_mains", false)) and modeles.has("main_droite"):
		var lame: ModeleAsset = modeles["main_droite"]
		prise.installer(_porteur, lame, CatalogueAssets.reglage(lame.asset_id, "poignee_mains", {}))
