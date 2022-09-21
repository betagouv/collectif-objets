# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

Collectif Objets est un site web permettant aux communes françaises de recenser leur patrimoine mobilier monument historiques et aux conservateurs d'analyser ces recensements.

## Interfaces & Usagers

Le site expose trois interfaces pour trois types d'usagers différents :

1. **Interface communes** : permet aux agents municipaux des communes de réaliser les recensements d'objets.

2. **Interface conservateurs** : permet aux conservateurs de voir les recensements réalisés sur leur territoire et de les analyser

3. **Interface administrateurs** : permet à l'équipe technique de gérer les accès et les données

Toutes ces interfaces sont accessibles sur https://collectif-objets.beta.gouv.fr

## Captures d'écran

1. **Interface communes**

| | |
| - | - |
| ![](/doc/interface-communes1.png) | ![](/doc/interface-communes2.png) |

2. **Interface conservateurs**

| | |
| - | - |
| ![](/doc/interface-conservateurs1.png) | ![](/doc/interface-conservateurs2.png) |


3. **Interface administrateurs**

![](/doc/interface-admin1.png)


## Briques techniques principales

Les 3 interfaces sont servies par une seule et unique application Ruby On Rails 7.

Les gems principales dont dépend cette application Rails sont :

- `devise` : Authentification des usagers. Il y a trois modèles Devise `User` (Communes), `Conservateur` et `Admin`.
- `sidekiq` : Gestion des tâches asynchrones - nécessite Redis
- `activeadmin` : Pour l'interface d'administration
- `vite_rails` : Compilation des assets JS et images
- `turbo_rails` : Interactions JS simplifiées
- `sprockets-rails` : Compilation traditionnelle des assets, utilisée uniquement pour activeadmin
- `mjml-rails` : Templates de mails en MJML
- `AASM` : Machines à états finis pour les statuts de certains modèles

Côté Javascript les packages principaux utilisés sont :

- `@gouvfr/dsfr` : Design Système de l'État Français
- `@rails/activestorage` : Gestion des uploads (avancement, direct uploads etc…)
- `@hotwired/stimulus` : Simplifie le lien HTML et JS
- `maplibre-gl` : permet d'afficher une carte des objets en France
- `frappe-charts` : petits diagrammes SVG
- `spotlight.js` : galerie de photos d'objets

## Infrastructure, Écosystème et environnements

![](/doc/infrastructure-simple.drawio.svg)

*Diagramme d'infrastructure simplifié* · [éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Finfrastructure-simple.drawio.svg)

- Le site web hébergé sur Scalingo est accessible sur https://collectif-objets.beta.gouv.fr
- C'est le sentry partagé de beta.gouv.fr qui est utilisé, il est accessible sur https://sentry.incubateur.net
- Le compte Scaleway utilisé est celui de l'Atelier Numérique (l'incubateur du Ministère de la Culture)

## Diagramme d'entités de la base de données

![](/doc/erd-simple.drawio.svg)

*Diagramme d'entités simplifié de la base de données* · [éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Ferd-simple.drawio.svg)


- Les `User` sont les comptes usagers des communes. C'est un modèle Devise. Un `User` a accès à une et une seule commune.
- Les `Conservateurs` sont les comptes usagers des conservateurs. C'est aussi un modèle Devise. Un Conservateur a accès à un ou plusieurs départements et toutes les communes inclues.
- Les `Objets` sont les objets monuments historiques. Leurs infos proviennent de Palissy. Leur identifiant unique provient de POP et s'appelle dans notre base `palissy_REF`, il ressemble à `PM00023944`.
- Un `Recensement` contient les observations sur l'état d'un `Objet` et les photos associées à la visite de l'agent municipal.
- Un `Dossier` est un ensemble de `Recensements` pour une commune. Il doit être finalisé par la commune pour être analysable par les conservateurs.
- Une `Campagne` contient les dates et les communes à démarcher pour une campagne mail avec plusieurs relances. Elle est gérée et visible uniquement par les administrateurs.

La version complète du diagramme d'entités de la base de données est visible ici [doc/entity-relationship-diagram.svg](/doc/entity-relationship-diagram.svg)

## Diagrammes des machines à état finis

| Communes | Dossiers | Campaigns |
| - | - | - |
| ![](/doc/commune_state_machine_diagram.png) | ![](/doc/dossier_state_machine_diagram.png) | ![](/doc/campaign_state_machine_diagram.png) |

- Un `Dossier` est d'abord en construction, puis est soumis aux conservateurs et enfin accepté ou rejeté.
- L'état d'une `Commune` est lié à l'état de son `Dossier`. La commune passe en recensement démarré lorsque le dossier est en construction, puis en recensement complété lorsque le dossier est soumis.

`bundle exec rake diagrams:generate` permet de mettre à jour ces diagrammes

## Installation

### En local

- install rbenv & make sure you have the correct ruby-versions installed and selected
- `make install`
- ask someone else from the team for the master key and store it in `config/master.key`
- optional: for faster auto-format locally, see https://github.com/fohte/rubocop-daemon#more-speed
- `make dev`

### Via Docker

TODO

## Autres sujets plus précis

Dans le [wiki](https://github.com/betagouv/collectif-objets/wiki/) vous trouverez des informations pour les sujets suivants :

- [Dumps et seeds](https://github.com/betagouv/collectif-objets/wiki/Dumps-et-Seeds) : Comment dumper la base de données de staging et préparer le fichier seeds.pgsql pour les Review Apps
- [Configuration des buckets S3 sur Scaleway](https://github.com/betagouv/collectif-objets/wiki/Configuration-des-buckets-S3-sur-Scaleway)
- [Origines des données, transformations et stockage](https://github.com/betagouv/collectif-objets/wiki/Origines-des-données,-transformations-et-stockage)
- [Intégration du Design Système de l'État Français (DSFR)](https://github.com/betagouv/collectif-objets/wiki/Int%C3%A9gration-du-Design-Syst%C3%A8me-de-l'%C3%89tat-Fran%C3%A7ais-(DSFR))

