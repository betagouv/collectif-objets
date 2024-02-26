# ./scripts/pg_dump_data_full.sh collectif_objets_dev tmp/seeds.pgsql
pg_dump \
  --data-only \
  --format c \
  --exclude-table ar_internal_metadata \
  --exclude-table schema_migrations \
  --exclude-table good_jobs \
  --exclude-table good_job_settings \
  --exclude-table good_job_processes \
  --exclude-table good_job_executions \
  --exclude-table good_job_batches \
  -f $2 \
  $1
