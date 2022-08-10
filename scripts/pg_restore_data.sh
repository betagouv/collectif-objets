pg_restore \
    --data-only \
    --no-owner \
    --no-privileges \
    --no-comments \
    --dbname $1 \
    $2