install:
	bundle install
	npm install --global husky
	npx husky install
	brew install mailhog redis libvips
	rails db:reset

dev:
	bin/dev

tunnel:
	loophole http 3000 --hostname collectifobjets

tunnel_webhooks:
	loophole http 3000 --hostname collectifobjets-mail-inbound --path /api/v1/inbound_emails
