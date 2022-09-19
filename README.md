# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

Collectif Objets est un site web permettant aux communes françaises de recenser leur patrimoine mobilier monument historiques et aux conservateurs d'analyser ces recensements.

## Interfaces

Le site se décompose en trois interfaces :

- Interface communes : permet aux agents municipaux des communes de réaliser les recensements d'objets. Ces personnes peuvent se connecter et voir la liste des objets de leur commune, évaluer leur état, et envoyer des photos.
- Interface conservateurs : permet aux conservateurs de voir les recensements réalisés sur leur territoire et de les analyser avec un retour éventuel aux communes
- Interface administrateurs : permet à l'équipe technique de gérer les accès et les données

Toutes ces interfaces sont servies par la même appli web Rails et sont accessibles sur https://collectif-objets.beta.gouv.fr

## Infrastructure & Écosystème

![](/doc/infrastructure.drawio.png)

- le site web Rails hébergé sur Scalingo est accessible sur https://collectif-objets.beta.gouv.fr
- l'appli Datasette hébergée sur Fly.io est disponible sur https://collectif-objets-datasette.fly.dev/. Son code est disponible sur le repo Github [collectif-objets-datasette](https://github.com/adipasquale/collectif-objets-datasette)
- le repo de notebooks jupyter est privé car il contient des jeux de données non anonymisés
- le code du scraper POP est disponible sur le repo GitHub [pop-scraper](https://github.com/adipasquale/pop-scraper). Il tourne sur la plateforme SaaS [Zyte](https://app.zyte.com/)
- C'est le sentry partagé de beta.gouv.fr qui est utilisé, il est accessible sur https://sentry.incubateur.net
- le compte Scaleway utilisé est celui de l'incubateur du Ministère de la culture.

## Diagramme d'entités de la base de données

**Version simplifiée**

![](/doc/erd_simplified.drawio.png)

- Les `User` sont les comptes usagers des communes. C'est un modèle Devise. Un `User` a accès à une et une seule commune.
- Les `Conservateurs` sont les comptes usagers des conservateurs. C'est aussi un modèle Devise. Un Conservateur a accès à un ou plusieurs départements et toutes les communes inclues.
- Les `Objets` sont les objets monuments historiques. Leurs infos proviennent de Palissy. Leur identifiant unique provient de POP et s'appelle dans notre base `palissy_REF`, il ressemble à `PM00023944`.
- Un `Recensement` contient les observations sur l'état d'un `Objet` et les photos associées à la visite de l'agent municipal.
- Un `Dossier` est un ensemble de `Recensements` pour une commune. Il doit être finalisé par la commune pour être analysable par les conservateurs.
- Une `Campagne` contient les dates et les communes à démarcher pour une campagne mail avec plusieurs relances. Elle est gérée et visible uniquement par les conservateurs.

**Version complète**

![](/doc/entity-relationship-diagram.svg)

## Diagrammes des machines à état finis

**Communes**

![](/doc/commune_state_machine_diagram.png)

**Dossiers**

![](/doc/dossier_state_machine_diagram.png)

**Campaigns**

![](/doc/campaign_state_machine_diagram.png)


To regenerate diagrams : `bundle exec rake diagrams:generate`

## Installation

### En local

- install rbenv & make sure you have the correct ruby-versions installed and selected
- `make install`
- ask someone else from the team for the master key and store it in `config/master.key`
- optional: for faster auto-format locally, see https://github.com/fohte/rubocop-daemon#more-speed
- `make dev`

### Via Docker

À venir

## Dumps

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal `./scripts/pg_dump_data_anonymous.sh postgres://collectif_o_9999:XXXXX@localhost:10000/collectif_o_9999 tmp/dump.pgsql`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal
- then `./scripts/pg_restore_data.sh tmp/dump.pgsql`

## Prepare new `seeds.pgsql` for review apps

- create a staging dump named `tmp/seeds.pgsql` (cf section before)
- import it locally with `dropdb collectif_objets_dev && createdb collectif_objets_dev && rake db:schema:load && ./scripts/pg_restore_data.sh collectif_objets_dev tmp/seeds.pgsql`
- run `rails runner "Commune.where(status: [:started, :completed]).update_all(status: :inactive)"`
- re-dump with `./scripts/pg_dump_data_anonymous.sh collectif_objets_dev tmp/seeds.pgsql`
- upload `tmp/seeds.pgsql` to the `collectif-objets-public` S3 bucket using cyberduck

