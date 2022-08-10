rails db:schema:load

curl https://s3.fr-par.scw.cloud/collectif-objets-public/seeds.pgsql > tmp/seeds.pgsql

. ${0%/*}/pg_restore_data.sh $SCALINGO_POSTGRESQL_URL tmp/seeds.pgsql