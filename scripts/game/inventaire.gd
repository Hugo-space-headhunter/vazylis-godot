class_name Inventaire
extends RefCounted
## Le sac à dos : des cases qui contiennent chacune un objet (ou rien), et l'or du joueur.

signal change

var cases: Array[Objet] = []
var or_possede := 0
## Ressources (rangées à part, sans prendre de case) : {"ressource.fer": 12, …}
var ressources := {}

var _config: ConfigJeu


func _init(config: ConfigJeu) -> void:
	_config = config
	cases.resize(int(config.butin("sac", "cases")))


func nombre_cases() -> int:
	return cases.size()


func nombre_objets() -> int:
	return cases.size() - cases.count(null)


func est_plein() -> bool:
	return not cases.has(null)


## Range l'objet dans la première case libre. Renvoie la case, ou -1 si le sac est plein.
func ajouter(objet: Objet) -> int:
	var case_libre := cases.find(null)
	if case_libre == -1:
		return -1
	cases[case_libre] = objet
	change.emit()
	return case_libre


func objet(case_numero: int) -> Objet:
	return cases[case_numero] if case_numero >= 0 and case_numero < cases.size() else null


func retirer(case_numero: int) -> Objet:
	var retire := objet(case_numero)
	if retire != null:
		cases[case_numero] = null
		change.emit()
	return retire


func ajouter_ressources(gains: Dictionary) -> void:
	if gains.is_empty():
		return
	for id: String in gains:
		ressources[id] = int(ressources.get(id, 0)) + int(gains[id])
	change.emit()


func quantite(id_ressource: String) -> int:
	return int(ressources.get(id_ressource, 0))


## Paie une amélioration à la forge (sans vérifier : voir Forge.peut_payer).
func payer(id_ressource: String, nombre: int, prix_or: int) -> void:
	ressources[id_ressource] = maxi(0, quantite(id_ressource) - nombre)
	or_possede = maxi(0, or_possede - prix_or)
	change.emit()


## Échange le contenu de deux cases (pour ranger le sac).
func echanger(case_a: int, case_b: int) -> void:
	if case_a == case_b or case_a < 0 or case_b < 0 or case_a >= cases.size() or case_b >= cases.size():
		return
	var temporaire := cases[case_a]
	cases[case_a] = cases[case_b]
	cases[case_b] = temporaire
	change.emit()


## Or rapporté par le recyclage d'un objet.
func valeur_recyclage(un_objet: Objet) -> int:
	return roundi(_config.butin("recyclage", "or_par_puissance") * un_objet.puissance(_config))


## Matériaux rendus par le recyclage d'un objet : {"ressource.fer": 3}. Plus la rareté et le niveau
## sont hauts, plus il en rend (butin.cfg [recyclage]).
func materiaux_recyclage(un_objet: Objet) -> Dictionary:
	var rang := maxi(0, _config.ids_raretes().find(un_objet.rarete))
	var nombre := int(_config.butin("recyclage", "materiaux_base")) + rang * int(_config.butin("recyclage", "materiaux_par_rarete")) \
		+ floori(un_objet.niveau / maxf(1.0, _config.butin("recyclage", "niveaux_par_materiau")))
	return {un_objet.materiau(_config): nombre}


## Recycle l'objet d'une case. Renvoie l'or gagné.
func recycler(case_numero: int) -> int:
	var retire := retirer(case_numero)
	return recycler_objet(retire) if retire != null else 0


## Recycle un objet qui n'est pas dans le sac (par exemple quand le sac est plein) :
## il rapporte de l'or et des matériaux. Renvoie l'or gagné.
func recycler_objet(un_objet: Objet) -> int:
	var gain := valeur_recyclage(un_objet)
	or_possede += gain
	var materiaux := materiaux_recyclage(un_objet)
	for id: String in materiaux:
		ressources[id] = quantite(id) + int(materiaux[id])
	change.emit()
	return gain
