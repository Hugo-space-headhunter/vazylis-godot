class_name Butin
extends RefCounted
## Tirage du butin des monstres et création des objets, avec la garantie anti-malchance.

## Raretés tirées sur un monstre (une chance indépendante par rareté, butin.cfg [monstre]).
const RARETES_MONSTRE: PackedStringArray = ["standard", "argente", "dore", "epique"]

## Monstres tués depuis le dernier doré (ou mieux) et depuis le dernier épique (ou mieux).
var monstres_sans_dore := 0
var monstres_sans_epique := 0

var _config: ConfigJeu


func _init(config: ConfigJeu) -> void:
	_config = config


## Objets lâchés par un monstre de ce niveau (souvent aucun, parfois plusieurs).
func tirer_monstre(niveau: int, zone: int, hasard: RandomNumberGenerator) -> Array[Objet]:
	var raretes: Array[String] = []
	for rarete in RARETES_MONSTRE:
		if hasard.randf() < _config.butin("monstre", rarete):
			raretes.append(rarete)
	monstres_sans_dore += 1
	monstres_sans_epique += 1
	if not _contient_au_moins(raretes, "epique") and monstres_sans_epique >= int(_config.butin("garantie", "epique_apres")):
		raretes.append("epique")
	if not _contient_au_moins(raretes, "dore") and monstres_sans_dore >= int(_config.butin("garantie", "dore_apres")):
		raretes.append("dore")
	if _contient_au_moins(raretes, "dore"):
		monstres_sans_dore = 0
	if _contient_au_moins(raretes, "epique"):
		monstres_sans_epique = 0
	var objets: Array[Objet] = []
	for rarete in raretes:
		objets.append(creer_objet(tirer_famille(zone, hasard), niveau, rarete, hasard))
	return objets


## Famille d'objet tirée au hasard parmi celles de la zone.
func tirer_famille(zone: int, hasard: RandomNumberGenerator) -> String:
	var familles := PackedStringArray()
	for id in _config.ids_familles_objets():
		if int(_config.famille_objet(id).get("zone", 1)) == zone:
			familles.append(id)
	return familles[hasard.randi_range(0, familles.size() - 1)]


## Crée un objet : chaque valeur est tirée entre 70 % et 100 % de son maximum.
func creer_objet(famille: String, niveau: int, rarete: String, hasard: RandomNumberGenerator) -> Objet:
	var definition := _config.famille_objet(famille)
	var objet := Objet.new()
	objet.famille = famille
	objet.nom = str(definition.get("nom", famille))
	objet.emplacement = str(definition.get("emplacement", ""))
	objet.type_arme = str(definition.get("type_arme", ""))
	objet.niveau = niveau
	objet.rarete = rarete
	var tirages: Array[float] = []
	var puissance := float(objet.puissance(_config))

	if objet.est_arme():
		var brut := _config.combat("arme", "degats_base") + _config.combat("arme", "degats_par_niveau") * niveau
		var maximum := brut * _config.multiplicateur_rarete(rarete) \
			* float(_config.arme(objet.type_arme).get("multiplicateur_degats", 1.0))
		objet.degats = maximum * _tirer(hasard, tirages)
	elif not objet.est_bijou():
		var parts: Dictionary = _config.generation_objets("part_armure")
		objet.armure = puissance * float(parts.get(objet.emplacement, 0.0)) * _tirer(hasard, tirages)

	var bijou := objet.est_bijou()
	var bornes: Array = _config.generation_objets("nombre_statistiques_bijoux" if bijou else "nombre_statistiques")
	var par_puissance := float(_config.generation_objets("statistiques_par_puissance_bijoux" if bijou else "statistiques_par_puissance"))
	for nom in _au_hasard(Array(Statistiques.NOMS), hasard.randi_range(int(bornes[0]), int(bornes[1])), hasard):
		objet.statistiques[nom] = maxi(1, roundi(puissance * par_puissance * _tirer(hasard, tirages)))

	var maximums: Dictionary = _config.generation_objets("bonus_maximum")
	for nom in _au_hasard(maximums.keys(), _config.bonus_pourcent_rarete(rarete), hasard):
		objet.bonus[nom] = snappedf(float(maximums[nom]) * _tirer(hasard, tirages), 0.001)

	var somme := 0.0
	for tirage in tirages:
		somme += tirage
	objet.qualite = somme / tirages.size() if not tirages.is_empty() else 1.0
	return objet


func _tirer(hasard: RandomNumberGenerator, tirages: Array[float]) -> float:
	var tirage := hasard.randf_range(float(_config.generation_objets("qualite_min")), float(_config.generation_objets("qualite_max")))
	tirages.append(tirage)
	return tirage


func _au_hasard(liste: Array, nombre: int, hasard: RandomNumberGenerator) -> Array:
	var melange := liste.duplicate()
	for i in range(melange.size() - 1, 0, -1):
		var j := hasard.randi_range(0, i)
		var temporaire = melange[i]
		melange[i] = melange[j]
		melange[j] = temporaire
	return melange.slice(0, mini(nombre, melange.size()))


func _contient_au_moins(raretes: Array[String], minimum: String) -> bool:
	var ordre := _config.ids_raretes()
	for rarete in raretes:
		if ordre.find(rarete) >= ordre.find(minimum):
			return true
	return false
