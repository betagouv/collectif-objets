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
- in another terminal `pg_dump --data-only --format c -f tmp/dump.pgsql --exclude-table recensements --exclude-table active_storage_attachments --exclude-table active_storage_blobs --exclude-table active_storage_variant_records postgres://collectif_o_9999:XXXXX@localhost:10000/collectif_o_9999`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal
- then `./scripts/restore_to_local.sh tmp/dump.pgsql`

## Prepare new seeds.pgsql for review apps

- create a staging dump (cf section before)
- import it locally with `rake db:schema:load && pg_restore --data-only --no-owner --no-privileges --no-comments --dbname collectif_objets_dev tmp/seeds.pgsql`
- run `rails runner "Commune.where(status: [:started, :completed]).update_all(status: :inactive)"`
- re-dump with `pg_dump --data-only --format c -f tmp/seeds.pgsql --exclude-table recensements --exclude-table active_storage_attachments --exclude-table active_storage_blobs --exclude-table active_storage_variant_records collectif_objets_dev`
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
