# ./scripts/pg_dump_data_full.sh collectif_objets_dev tmp/seeds.pgsql
pg_dump \
  --data-only \
  --format c \
  --exclude-table ar_internal_metadata \
  --exclude-table schema_migrations \
  -f $2 \
  $1