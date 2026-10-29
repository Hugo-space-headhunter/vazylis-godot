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
- L'arc est tenu à l'horizontale au repos (l'animation de repos est faite pour une épée) ; trouver des animations de tir à l'arc.
- Dagues : une même animation d'attaque à l'épée sert pour toutes les armes de mêlée ; chercher des animations propres aux dagues et aux armes à deux mains.
- Hache : sa particularité (ignorer 15 % de la défense) n'a pas encore d'effet, car les monstres n'ont pas de défense.
- Poids du jeu : les armes Polyy pèsent environ 3 Mo chacune (textures en 2048 px) ; réduire leurs textures pour accélérer le chargement sur l'iPhone.
- Outil `tools/calculer_prise.gd` : il calcule la prise en main d'une nouvelle arme ; à utiliser pour les armes créées par Hugo.
