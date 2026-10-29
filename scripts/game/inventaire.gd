class_name Inventaire
extends RefCounted
## Le sac à dos : des cases qui contiennent chacune un objet (ou rien), et l'or du joueur.

signal change

var cases: Array[Objet] = []
var or_possede := 0

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


## Or rapporté par le recyclage d'un objet.
func valeur_recyclage(un_objet: Objet) -> int:
	return roundi(_config.butin("recyclage", "or_par_puissance") * un_objet.puissance(_config))


## Recycle l'objet d'une case. Renvoie l'or gagné.
func recycler(case_numero: int) -> int:
	var retire := retirer(case_numero)
	return recycler_objet(retire) if retire != null else 0


## Recycle un objet qui n'est pas dans le sac (par exemple quand le sac est plein).
func recycler_objet(un_objet: Objet) -> int:
	var gain := valeur_recyclage(un_objet)
	or_possede += gain
	change.emit()
	return gain
