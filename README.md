# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

This monorepo holds two Rails apps : one in `/www` and another in `/admin`

## Usage

- Install overmind
- `overmind start -f Procfile.dev`

## Dumps

- Create a local dump with `make dump`

To restore dump on staging:

- in one terminal : `scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL`
- in another terminal : `./bin/restore_to_staging.sh`
- ⚠️ you may have to enter the SSH password multiple times in the first terminal

