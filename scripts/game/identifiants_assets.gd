class_name IdentifiantsAssets
extends RefCounted
## Tous les identifiants d'assets utilisés par le jeu.
##
## Le jeu ne connaît jamais un fichier 3D : il utilise ces identifiants, et le
## catalogue (assets/catalogue.cfg) fait le lien avec les fichiers.
## Un test vérifie que chaque constante de ce fichier existe dans le catalogue :
## toute nouvelle constante doit donc avoir sa section dans le catalogue.

## Personnages de base (même squelette, mêmes animations, même équipement).
const HEROS_HOMME := "character.heros_homme"
const HEROS_FEMME := "character.heros_femme"
## Le forgeron de Vazylis (personnage de base, tablier de cuir).
const FORGERON := "character.forgeron"

## Monstres des Prés de Vazylis (voir aussi config/monstres.cfg).
const COCHONNET_SUIE := "monster.cochonnet_suie"
const CORBAC := "monster.corbac"
const POMELIN := "monster.pomelin"

## Armes (les types d'armes de config/armes.cfg indiquent lesquelles portent quoi).
const EPEE_DEPART := "weapon.epee_depart"
const DAGUE := "weapon.dague"
const CLAYMORE := "weapon.claymore"
const HACHE := "weapon.hache"
const BOUCLIER := "weapon.bouclier"
const ARC := "weapon.arc"
const FLECHE := "projectile.fleche"

## Objet de démonstration de l'étape 0 : un cristal qui tourne.
const CRISTAL_TEST := "prop.cristal_test"

## Exemple volontairement sans fichier, pour montrer le modèle provisoire de repli.
const EXEMPLE_MANQUANT := "prop.exemple_manquant"
