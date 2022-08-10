rails db:schema:load

curl https://s3.fr-par.scw.cloud/collectif-objets-public/seeds.pgsql | \
  pg_restore --data-only --no-owner --no-privileges --no-comments --dbname $SCALINGO_POSTGRESQL_URL