# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

Collectif Objets est un site web permettant aux communes françaises de recenser leur patrimoine mobilier monument historiques et aux conservateurs d'analyser ces recensements.

- [Interfaces & Usagers](#interfaces--usagers)
- [Captures d'écran](#captures-décran)
- [Frameworks et dépendances](#frameworks-et-dépendances)
- [Infrastructure, Écosystème et environnements](#infrastructure-écosystème-et-environnements)
- [Diagramme d'entités de la base de données](#diagramme-dentités-de-la-base-de-données)
- [Diagrammes des machines à état finis](#diagrammes-des-machines-à-état-finis)
- [Installation](#installation)
- [Plus de documentation…](#plus-de-documentation)

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


## Frameworks et dépendances

Les 3 interfaces sont servies par une seule et unique application Ruby On Rails 7.

Les gems principales dont dépend cette application Rails sont :

- `devise` : Authentification des usagers. Il y a trois modèles Devise `User` (Communes), `Conservateur` et `Admin`.
- `pundit` : droits et règles d'accès selon les profils
- `sidekiq` : Gestion des tâches asynchrones via Redis
- `vite_rails` : Compilation des assets JS et images
- `turbo_rails` : Interactions JS simplifiées
- `mjml-rails` : Templates de mails en MJML
- `AASM` : Machines à états finis pour les statuts des modèles
- `haml-rails`, `kramdown` et `view_component` pour les modèles de vues
- `ransack` : recherches et filtres dans l'admin principalement

Côté Javascript les principaux packages utilisés sont :

- `@gouvfr/dsfr` : Design Système de l'État Français
- `@rails/activestorage` : Gestion des uploads de photos
- `@hotwired/stimulus` : Simplifie le lien entre HTML et JS
- `maplibre-gl` : permet d'afficher une carte des objets en France
- `frappe-charts` : diagrammes SVG
- `spotlight.js` : galeries de photos d'objets

## Infrastructure, Écosystème et environnements

![](/doc/infrastructure-simple.drawio.svg)

*Diagramme d'infrastructure simplifié* · [éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Finfrastructure-simple.drawio.svg)

Le site web hébergé sur Scalingo est accessible sur [collectif-objets.beta.gouv.fr](https://)

Un environnement de recette (ou staging) est disponible à l'adresse [staging.collectif-objets.incubateur.net](https://staging.collectif-objets.incubateur.net). Il n'y a pas de données sensible sur cette base de données et elle peut être réinitialisée à tout moment.

Une liste complète d'URLs des environnements et des outils externes est disponible [sur le wiki](https://github.com/betagouv/collectif-objets/wiki/urls).

## Diagramme d'entités de la base de données

![](/doc/erd-simple.drawio.svg)

*Diagramme d'entités simplifié de la base de données* · [éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Ferd-simple.drawio.svg)


- Les `User` sont les comptes usagers des communes. C'est un modèle Devise. Un `User` a accès à une et une seule commune.
- Les `Conservateurs` sont les comptes usagers des conservateurs. C'est aussi un modèle Devise. Un Conservateur a accès à un ou plusieurs départements et toutes les communes inclues.
- Les `Édifices` sont les lieux abritant les objets. Une partie sont des monuments historiques avec des références vers la base Mérimée.
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

### Installation via Docker

```
docker compose up
# CTRL-C to break

docker compose run web rails db:setup
```

### Installation en local via rbenv et bundle

```sh
# installer rbenv : https://github.com/rbenv/rbenv#installation
rbenv install `cat .ruby-version`
make install
make dev
```

optionnel: pour une utilisation de rubocop plus rapide en local, [voir le mode serveur](https://docs.rubocop.org/rubocop/usage/server.html)

### Travail en local sur les webhooks d'inbound mails

- installer manuellement [`loophole`](https://loophole.cloud/) 
- `make tunnel`

## Plus de documentation…

Après l'installation n'hésitez pas à suivre les [Premiers pas](https://github.com/betagouv/collectif-objets/wiki/premiers-pas)dans le wiki pour découvrir les interfaces et les fonctionnalités

Dans le [wiki](https://github.com/betagouv/collectif-objets/wiki/) vous trouverez des informations sur les sujets suivants :

- [URLs des environnements et des services externes](https://github.com/betagouv/collectif-objets/wiki/urls)
- [Astreinte, autorisations et accès](https://github.com/betagouv/collectif-objets/wiki/astreinte)
- [Dumps et seeds](https://github.com/betagouv/collectif-objets/wiki/dumps)
- [Configuration des buckets S3 sur Scaleway](https://github.com/betagouv/collectif-objets/wiki/buckets-s3)
- [Origines des données, transformations et stockage](https://github.com/betagouv/collectif-objets/wiki/donnees)
- [Intégration du Design Système de l'État Français (DSFR)](https://github.com/betagouv/collectif-objets/wiki/dsfr)
