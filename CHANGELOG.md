# Changelog

À partir du 1er août 2023, tous les changements sur le projet sont documentés ici

Format basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
le projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Non publié]

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
