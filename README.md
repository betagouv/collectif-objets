# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

## Dev

`rails server`


## Dumps

Create local dump

```sh
pg_dump --format c --data-only --table=objets --table=communes --dbname collectif_objets_dev --file tmp/dump.pgsql
```


Restore dump on scalingo:

```sh
# terminal 1
scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL

# terminal 2
scalingo --app collectif-objets-staging env-get SCALINGO_POSTGRESQL_URL
# DB_URL=[[ MANUALLY SET IT ]]
psql --command "TRUNCATE objets; TRUNCATE communes;" $DB_URL
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname $DB_URL tmp/dump.pgsql

# don't forget to switch back to terminal 1 and enter SSH password if necessary
```
