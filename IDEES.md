# Idées pour plus tard

Les idées et améliorations hors de l'étape en cours sont notées ici, au lieu d'être codées tout de suite.

## Technique

- Netteté et performances sur iPhone : l'écran de l'iPhone affiche 3 pixels par point. Si les images par seconde baissent avec les vraies scènes, réduire la résolution de rendu 3D (réglage « Échelle 3D »).
- Zone de sécurité de l'iPhone (encoche, barre du bas) : adapter les marges de l'interface quand le bandeau et les boutons arriveront (étape 3).
- Raccourci pour lancer les tests automatiques depuis l'éditeur Godot (panneau GUT en bas de l'éditeur).

## Personnage

- Ajouter le héros créé par Hugo avec Tripo comme deuxième personnage du catalogue (`character.heros_tripo`), avec les animations Quaternius par reciblage (« retargeting ») de Godot. Il faudra l'exporter de Tripo en GLB avec un squelette. Tripo gratuit : usage perso uniquement.
- Coiffures : le pack Universal Base Characters contient des coiffures séparées (dossier « Hairstyles », attachées à l'os de la tête). À ajouter avec l'écran de création du personnage.
- Écran de création du personnage (homme ou femme, prénom) : remplacera le bouton provisoire Homme/Femme.
- Caméra : en portrait, le personnage paraît petit ; envisager une caméra un peu plus proche en portrait. Empêcher la caméra de passer derrière les obstacles.
- Bibliothèque d'animations : le jeu en garde 43 alors qu'il en utilise 6 ; ne garder que les utiles pour alléger le téléchargement.

## Combat

- Cochonnet de suie : pas de vrai cochon en CC0 chez Quaternius ; le modèle « Dog » teinté sert en attendant. Les yeux rouges demanderaient de retoucher la texture.
- Épée : légèrement trop en avant pendant la marche avec l'arme sortie ; à affiner dans `placements` du catalogue si besoin.
- Plusieurs monstres d'une même zone peuvent se chevaucher ; les écarter un peu les uns des autres.
- Les étiquettes « nom niv. X » de tous les monstres sont toujours visibles ; ne les montrer que pour les monstres proches si l'écran devient chargé.

## Armes et statistiques

- Arc et bouclier : modèles provisoires faits par code ; les remplacer par de vrais modèles (aucun arc ni bouclier seul en CC0 dans les packs actuels ; chercher chez KayKit Adventurers ou Quaternius).
- Hache : sa particularité (ignorer 15 % de la défense) n'a pas encore d'effet, car les monstres n'ont pas de défense.
- Poids du jeu : les armes Polyy pèsent environ 3 Mo chacune (textures en 2048 px) ; réduire leurs textures pour accélérer le chargement sur l'iPhone.
- Outils `tools/calculer_prise.gd` et `tools/calculer_prise_pose.gd` : ils calculent la prise en main d'une nouvelle arme (au repos ou à un moment d'une animation) ; à utiliser pour les armes créées par Hugo.
- Tir à l'arc : la main droite ne tire pas la corde (l'animation est un sort lancé d'une main) ; chercher une vraie animation de tir à l'arc.
- Dagues et épée et bouclier : une même animation d'attaque à l'épée ; chercher des animations propres aux dagues.
- Coup à deux mains : l'animation « TreeChopping » commence arme levée, ce qui fait un petit saut au début du coup ; une animation d'armement serait plus fluide.
- Main gauche sur le manche : pendant le coup à deux mains, la main gauche est proche du manche grâce à l'animation ; on pourrait la coller exactement au manche avec l'IK de Godot (TwoBoneIK3D).
