# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

## Usage

- install rbenv & make sure you have the correct ruby-versions installed and selected
- `make install`
- ask someone else from the team for the master key and store it in `config/master.key`
- `make dev`

## Dumps

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal `pg_dump --format c -f tmp/dump.pgsql postgres://collectif_o_9999:XXXXX@localhost:10000/collectif_o_9999`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal
- then `./scripts/restore_to_local.sh tmp/dump.pgsql`

## Review Apps

- create it manually from https://dashboard.scalingo.com/apps/osc-fr1/collectif-objets-staging/review-apps/manual
- restore a safe dump (without recensements and attachments) to that new app's db
- prevent erroneous mails with `scalingo --app collectif-objets-staging-prXXX run rake users:simple_magic_tokens_and_mailcatch_mails`

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
