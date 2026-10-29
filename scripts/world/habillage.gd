class_name Habillage
extends RefCounted
## Habille un personnage avec ses objets portés : les pièces de tenue (casque, plastron, gants,
## bottes, ceinture) se plient avec son squelette ; la cape et l'amulette s'accrochent au dos.
## Chaque pièce prend le rendu de sa rareté ; un objet transcendant entoure le personnage d'une aura.

## Pièces de tenue qui suivent le squelette du personnage (même squelette que les personnages de base).
const PIECES_SOUPLES: PackedStringArray = ["casque", "plastron", "gants", "bottes", "ceinture"]
## Objets rigides accrochés à un point d'attache du personnage.
const OBJETS_ACCROCHES := {"cape": "dos", "collier": "dos"}
## Étincelles de l'aura d'un personnage qui porte un objet transcendant.
const AURA_ETINCELLES := 24

var _noeuds: Array[Node] = []
var _peau: MeshInstance3D
var _peau_origine: Mesh


## Remplace la tenue affichée par celle de l'équipement.
func habiller(personnage: ModeleAsset, equipement: Equipement, femme: bool) -> void:
	vider()
	var config := Config.jeu
	var squelette := personnage.squelette()
	if squelette == null:
		return
	_rentrer_la_peau(personnage, squelette, equipement)
	for emplacement in PIECES_SOUPLES:
		var objet := equipement.objet(emplacement)
		if objet == null:
			continue
		var famille := config.famille_objet(objet.famille)
		var modeles: Array = [objet.modele(config, femme)]
		modeles.append_array(famille.get("accessoires_femme" if femme else "accessoires_homme", []))
		for modele_id: String in modeles:
			_coudre(squelette, modele_id, objet.rarete)
	for emplacement: String in OBJETS_ACCROCHES:
		var objet := equipement.objet(emplacement)
		if objet == null:
			continue
		var accroche := CatalogueAssets.creer(objet.modele(config, femme))
		accroche.accrocher_a(personnage, OBJETS_ACCROCHES[emplacement])
		ApparenceRarete.appliquer(accroche, objet.rarete)
		_noeuds.append(accroche)
	if _porte_un_transcendant(equipement):
		var aura := ApparenceRarete.ajouter_etincelles(personnage, "transcendant",
			AABB(Vector3(-0.35, 0.1, -0.35), Vector3(0.7, 1.7, 0.7)), AURA_ETINCELLES)
		if aura != null:
			_noeuds.append(aura)


## Rentre la peau du personnage sous les pièces portées (voir CorpsSousVetements).
func _rentrer_la_peau(personnage: ModeleAsset, squelette: Skeleton3D, equipement: Equipement) -> void:
	var nom_peau := str(CatalogueAssets.reglage(personnage.asset_id, "maillage_peau", ""))
	if nom_peau.is_empty():
		return
	if _peau == null or not is_instance_valid(_peau) or _peau.get_parent() != squelette:
		_peau = squelette.find_child(nom_peau, false, false) as MeshInstance3D
		_peau_origine = _peau.mesh if _peau != null else null
	if _peau == null:
		return
	var couverts := PackedStringArray()
	for emplacement in PIECES_SOUPLES:
		if equipement.objet(emplacement) != null:
			couverts.append(emplacement)
	CorpsSousVetements.ajuster(_peau, _peau_origine, couverts,
		float(CatalogueAssets.reglage(personnage.asset_id, "retrait_sous_vetements", 0.0)))


## Retire toute la tenue affichée.
func vider() -> void:
	for noeud in _noeuds:
		if is_instance_valid(noeud):
			noeud.queue_free()
	_noeuds.clear()


## Nombre de morceaux affichés (pour les tests).
func nombre_de_morceaux() -> int:
	return _noeuds.size()


## Ajoute les maillages d'une pièce de tenue au squelette du personnage, pour qu'ils bougent avec lui.
func _coudre(squelette: Skeleton3D, modele_id: String, rarete: String) -> void:
	var piece := CatalogueAssets.creer(modele_id)
	if piece.provisoire:
		piece.free()
		return
	for noeud in piece.find_children("*", "MeshInstance3D", true, false):
		var maillage := noeud as MeshInstance3D
		maillage.owner = null
		maillage.get_parent().remove_child(maillage)
		squelette.add_child(maillage)
		maillage.skeleton = NodePath("..")
		maillage.transform = Transform3D.IDENTITY
		ApparenceRarete.appliquer(maillage, rarete)
		_noeuds.append(maillage)
	piece.free()


func _porte_un_transcendant(equipement: Equipement) -> bool:
	for objet: Objet in equipement.objets.values():
		if objet.rarete == "transcendant":
			return true
	return false
