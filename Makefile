dump:
	pg_dump --format c --data-only --table=objets --table=communes --table=users --dbname collectif_objets_dev --file tmp/dump.pgsql
	echo "DB dumped to tmp/dump.pgsql !"
