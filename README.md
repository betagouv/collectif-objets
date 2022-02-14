# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

## Dev

Setup:

- install rbenv & make sure you have the correct ruby-version installed and selected

```sh
bundle install
bundle exec overcommit --install
```

Dev: `rails server`


## Dumps

- Create a local dump with `make dump`

To restore dump on staging:

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal : `./bin/restore_to_staging.sh`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal

## Mails & MJML

- `npm install`
- `./node_modules/.bin/mjml -r app/views/user_mailer/validate_email.html.mjml > app/views/user_mailer/validate_email.html.erb`
