class_name ChiffreFlottant
extends Label3D
## Texte qui monte et s'efface très vite : dégâts, « Level Up »…

const COULEUR_DEGATS := Color(1, 1, 1)
const COULEUR_CRITIQUE := Color(1, 0.85, 0.2)
const COULEUR_DEGATS_SUBIS := Color(1, 0.35, 0.3)


## Affiche un texte flottant dans le monde, à la position donnée.
static func afficher(parent: Node, position_monde: Vector3, texte: String, couleur: Color,
		taille: int = 64, duree_affichage: float = 0.8, hauteur: float = 0.8) -> ChiffreFlottant:
	var chiffre := ChiffreFlottant.new()
	chiffre.text = texte
	chiffre.modulate = couleur
	chiffre.font_size = taille
	chiffre.outline_size = 12
	chiffre.outline_modulate = Color(0, 0, 0, 0.8)
	chiffre.pixel_size = 0.006
	chiffre.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chiffre.no_depth_test = true
	chiffre.render_priority = 10
	parent.add_child(chiffre)
	chiffre.global_position = position_monde + Vector3(randf_range(-0.15, 0.15), 0, 0)
	var animation := chiffre.create_tween().set_parallel()
	animation.tween_property(chiffre, "global_position:y", chiffre.global_position.y + hauteur, duree_affichage) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	animation.tween_property(chiffre, "modulate:a", 0.0, duree_affichage * 0.4).set_delay(duree_affichage * 0.6)
	animation.chain().tween_callback(chiffre.queue_free)
	return chiffre
