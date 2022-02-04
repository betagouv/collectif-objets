# Collectif Objets

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
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname `scalingo --app collectif-objets-staging env-get SCALINGO_POSTGRESQL_URL` tmp/dump.pgsql
```
