# or STAGING_DB_URL=postgres://xxxx:zzzz@localhost:10000/xxxx
STAGING_DB_URL=`bundle exec rails runner "puts Rails.application.credentials.staging.tunneled_database_url"`
psql --command "TRUNCATE users; TRUNCATE objets; TRUNCATE communes;" $STAGING_DB_URL
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname $STAGING_DB_URL tmp/dump.pgsql
