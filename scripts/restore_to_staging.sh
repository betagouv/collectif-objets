die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required : the path to the pgsql dump file"

# or STAGING_DB_URL=postgres://xxxx:zzzz@localhost:10000/xxxx
STAGING_DB_URL=`bundle exec rails runner "puts Rails.application.credentials.staging.tunneled_database_url"`
psql --command "TRUNCATE users, recensements, objets, communes;" $STAGING_DB_URL
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname $STAGING_DB_URL $1
