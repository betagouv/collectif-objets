die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required : the path to the pgsql dump file"

dropdb collectif_objets_dev
createdb collectif_objets_dev
pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname collectif_objets_dev $1
