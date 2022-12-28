install:
	bundle install
	npm install --global husky
	npx husky install
	brew install mailhog redis libvips
	rails db:reset

dev:
	bin/dev
