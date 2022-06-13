# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

This monorepo holds two Rails apps : one in `/www` and another in `/admin`

They share models code in `/shared`

## Usage

- install rbenv & make sure you have the correct ruby-versions installed and selected
- `make install`
- `make dev`

## Deploy

The process is setup to run in GH Actions, if tests pass correctly. It will auto-deploy the main branch to both staging and production environments.

By default, only the `www` rails app gets deployed. If the commit message contains `[admin]`, then only the `admin` app gets deployed.

The process is slightly convoluted:

- create a tar git archive of the `www` or `admin` codebase
- extract it
- replace the `www/shared` or `admin/shared` symlink with a hardcoded copy of the `/shared` dir
- repackage the tar archive
- deploy it with `scalingo deploy`


## Dumps

- Create a local dump with `make dump`

To restore dump on staging:

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal : `./bin/restore_to_staging.sh`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal

## Review Apps

- create it manually from https://dashboard.scalingo.com/apps/osc-fr1/collectif-objets-staging/review-apps/manual
- run `./scripts/deploy.sh www staging-prXX`
- restore a safe dump (without recensements and attachments) to that new app's db
- prevent erroneous mails with `scalingo --app collectif-objets-staging-prXXX run rake users:simple_magic_tokens_and_mailcatch_mails`

## Documentation

### Communes status state machine

![](doc/communes%20status%20diagram.png)
