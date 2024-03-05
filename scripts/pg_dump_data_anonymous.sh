# ./scripts/pg_dump_data_anonymous.sh collectif_objets_dev tmp/seeds.pgsql
pg_dump \
  --data-only \
  --format c \
  --exclude-table recensements \
  --exclude-table active_storage_attachments \
  --exclude-table active_storage_blobs \
  --exclude-table active_storage_variant_records \
  --exclude-table ar_internal_metadata \
  --exclude-table schema_migrations \
  --exclude-table good_jobs \
  --exclude-table good_job_settings \
  --exclude-table good_job_processes \
  --exclude-table good_job_executions \
  --exclude-table good_job_batches \
  -f $2 \
  $1
