install:
	bundle install
	npm install --global husky
	npm install
	npx husky install
	brew install mailhog redis libvips
	brew services start postgresql
	brew services start redis
	rails db:drop db:create db:schema:load
	rails r scripts/create_postgres_sequences_memoire_photos_numbers.rb
	rails db:seed

dev:
	bin/dev

tunnel:
	loophole http 3000 --hostname collectifobjets

tunnel_webhooks:
	loophole http 3000 --hostname collectifobjets-mail-inbound --path /api/v1/inbound_emails
