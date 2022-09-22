rails db:schema:load

# TODO infer DATABASE_URL from DATABASE_HOST etc

url=https://s3.fr-par.scw.cloud/collectif-objets-public/seeds.pgsql
echo "downloading seeds file from $url..."
curl $url > tmp/seeds.pgsql

echo "restoring data to postgres..."
. ${0%/*}/pg_restore_data.sh $DATABASE_URL tmp/seeds.pgsql

echo "done"
