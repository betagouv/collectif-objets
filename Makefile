install:
	cd www && bundle install
	cd admin && bundle install
	npm install --global husky
	npx husky install
	brew install overmind mailhog redis

dev:
	overmind start -f Procfile.dev

dump:
	pg_dump --format c --data-only --table=objets --table=communes --table=users --table=active_storage_variant_records --table=active_storage_blobs --table=active_storage_attachments --table=recensements --file tmp/dump.pgsql collectif_objets_dev
	echo "DB dumped to tmp/dump.pgsql !"
