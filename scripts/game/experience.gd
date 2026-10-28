class_name Experience
extends RefCounted
## Niveau et XP du personnage. Indépendant de l'affichage : la scène l'écoute.

signal niveau_gagne(nouveau_niveau: int)

var niveau := 1
var xp := 0

var _config: ConfigJeu


func _init(config: ConfigJeu, niveau_depart: int = 1, xp_depart: int = 0) -> void:
	_config = config
	niveau = niveau_depart
	xp = xp_depart


## XP de base d'un monstre de ce niveau.
static func xp_base_monstre(niveau_monstre: int, config: ConfigJeu) -> float:
	return config.xp_base_par_niveau() * niveau_monstre


## Coefficient selon l'écart de niveau entre le monstre et le joueur.
static func coefficient_ecart(niveau_joueur: int, niveau_monstre: int, config: ConfigJeu) -> float:
	var ecart := niveau_monstre - niveau_joueur
	if ecart > 0:
		return 1.0 + minf(config.bonus_xp_par_niveau_au_dessus() * ecart, config.bonus_xp_maximum())
	if ecart < 0:
		return maxf(1.0 + config.malus_xp_par_niveau_en_dessous() * ecart, config.coefficient_xp_minimum())
	return 1.0


## XP gagnée en tuant un monstre (au moins 1).
static func xp_gagnee(niveau_joueur: int, niveau_monstre: int, config: ConfigJeu) -> int:
	var brut := xp_base_monstre(niveau_monstre, config) * coefficient_ecart(niveau_joueur, niveau_monstre, config)
	return maxi(1, roundi(brut))


## XP à atteindre pour passer le niveau actuel.
func xp_pour_niveau_suivant() -> int:
	return Progression.xp_requise(niveau, xp_base_monstre(niveau, _config), _config)


## Ajoute de l'XP et passe autant de niveaux que nécessaire. Renvoie le nombre de niveaux gagnés.
func ajouter_xp(quantite: int) -> int:
	xp += quantite
	var gagnes := 0
	while xp >= xp_pour_niveau_suivant():
		xp -= xp_pour_niveau_suivant()
		niveau += 1
		gagnes += 1
		niveau_gagne.emit(niveau)
	return gagnes
