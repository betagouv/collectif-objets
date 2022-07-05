# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

## Usage

- install rbenv & make sure you have the correct ruby-versions installed and selected
- `make install`
- `make dev`

## Dumps

- Create a local dump with `make dump`

To restore dump on staging:

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal : `./bin/restore_to_staging.sh`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal

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
