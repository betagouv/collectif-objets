# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

## Usage

- install rbenv & make sure you have the correct ruby-versions installed and selected
- `make install`
- ask someone else from the team for the master key and store it in `config/master.key`
- optional: for faster auto-format locally, see https://github.com/fohte/rubocop-daemon#more-speed
- `make dev`

## Dumps

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal `./scripts/pg_dump_data.sh postgres://collectif_o_9999:XXXXX@localhost:10000/collectif_o_9999 tmp/dump.pgsql`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal
- then `./scripts/pg_restore_data.sh tmp/dump.pgsql`

## Prepare new `seeds.pgsql` for review apps

- create a staging dump named `tmp/seeds.pgsql` (cf section before)
- import it locally with `dropdb collectif_objets_dev && createdb collectif_objets_dev && rake db:schema:load && ./scripts/pg_restore_data.sh collectif_objets_dev tmp/seeds.pgsql`
- run `rails runner "Commune.where(status: [:started, :completed]).update_all(status: :inactive)"`
- re-dump with `./scripts/pg_dump_data.sh collectif_objets_dev tmp/seeds.pgsql`
- upload `tmp/seeds.pgsql` to the `collectif-objets-public` S3 bucket using cyberduck

## Documentation

To regenerate diagrams : `bundle exec rake diagrams:generate`

**Database Schema - Entity relationship diagram**

![](/doc/entity-relationship-diagram.svg)

**Communes state machine diagram**

![](/doc/commune_state_machine_diagram.png)

**Dossiers state machine diagram**

![](/doc/dossier_state_machine_diagram.png)


## Mails & MJML

- `npm install`
- `./node_modules/.bin/mjml -r app/views/user_mailer/validate_email.html.mjml > app/views/user_mailer/validate_email.html.erb`
