# Changelog

À partir du 1er août 2023, tous les changements sur le projet sont documentés ici

Format basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
le projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2023-11-30

### Ajouté
- Envoi d'un email spécifique adressé aux communes ayant fini leur recensement, selon la présence d'objets prioritaires ou non
- Statut "Réponse automatique" pour les communes ayant uniquement des objets verts
- Les statistiques sont dans un accordéon pour gagner de la place
- Hook de post déploiement pour migrer la base de données

### Changé
- Amélioration du design des stats et du tableau de bord du département côté conservateur
- Tri des objets des communes par ordre de priorité. Les objets prioritaires sont affichés en premier
- Sur la page d'une commune, les objets à examiner sont affichés en premier
- Le tableau des communes en version mobile n'affiche que 2 colonnes et les filtres sont alignés verticalement
- Les statistiques des états des objets sont masqués sur mobile
- Le tableau des communes est en blanc
- Les vocabulaire "rapport" et "analyse" devient "examen"
- Les bandeaux d'alerte précisant le statut d'une commune et les actions possibles sont harmonisés avec le DSFR
- Le tag "photos manquantes" de vient un badge

### Supprimé
- Lien de désinscription pour les emails transactionnels (non marketing)
- Bouton "finaliser le rapport" en bas de page d'une commune

## [1.2.0] - 2023-10-25

### Changé
- Meilleur espacement entre les édifices sur la page commune
- Harmonisation de l'affichage du nombre d'objets sur les différentes pages

### Ajouté
- Lien vers la fiche POP sur une fiche objet, et lien vers la fiche objet sur la page de recensement
- Documentation sur le statut global d'une commune et sur les règles d'import

## [1.1.0] - 2023-09-20

### Changé
- Un objet dit "prioritaire" est soit disparu soit en péril (et pas en mauvais état)
- Refonte de la vue département côté conservateur
  - Fusion des colonnes "État du recensement" et "Analyse"
  - Filtre et tri sur la nouvelle colonne "Analyse"
  - Colonne Objets disparus scindées en 2 colonnes "disparus" et "péril", avec tri par nombre d'objets
  - Ajout d'une colonne "Date du recensement", avec tri par date
- Harmonisation des badges d'analyse et d'objet prioritaire dans la page commune, dans l'admin et sur la carte du département
- Nouveau design du composant carte d'un objet
- Coquilles de texte : "classés" -> "protégés", "réouvrir" -> "rouvrir"

### Ajouté
- Lettre d'informations #3 sur la page d'accueil conservateur

### Supprimé
- Liste des édifices sur la page d'une commune, si la commune a moins de 3 édifices, et que les édifices ont moins de 6 objets. 

### Corrigé
- Bug lors de la synchronisation de POP en mode interactif

### Mises à jour
- @gouvfr/dsfr : 1.9.3 à 1.10.0
- rails : 7.0.5 à 7.0.6
- @rails/activestorage 7.0.5 à 7.0.6
- maplibre-gl : 3.0.1 à 3.2.1
- lookbook : 2.0.3 à 2.0.5
- capybara : 4.49.1 à 3.39.2
- semver : 5.7.1 à 5.7.2
- aws-sdk-s3 : 1.122.0 à 1.132.0
- patch-package : 7.0.0 à 8.0.0

## [1.0.0] - 2023-08-01

### Ajouté

- Possibilité de rouvrir un dossier dont l'analyse est terminée
- Vue sur les fiches attribuées par les conservateurs sur leur département

### Changé

- Le déploiement sur la production n'écrase plus le staging
- Chaque push sur la branche staging déploie sur l'environnement de staging
- La conformité à l'accessibilité n'est plus obligatoire sur les pages de documentation conservateur et commune, pour permmettre l'incrustration de vidéo Loom ou Youtube
