die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required : the path to the pgsql dump file"

# pg_dump --format c --clean --if-exists --file tmp/dump.pgsql postgres://collectif_o_xxx:xxxx@localhost:10000/collectif_o_2777

# or STAGING_DB_URL=postgres://xxxx:zzzz@localhost:10000/xxxx
STAGING_DB_URL=`bundle exec rails runner "puts Rails.application.credentials.staging.tunneled_database_url"`
psql --command "DROP TABLE active_admin_comments, active_storage_attachments, active_storage_blobs, active_storage_variant_records, admin_users, communes, conservateurs, dossiers, objets, recensements, users;" $STAGING_DB_URL
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname $STAGING_DB_URL $1
