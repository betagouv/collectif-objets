install:
	bundle install
	npm install --global husky
	npx husky install
	brew install overmind mailhog redis libvips
	rails db:reset

dev:
	overmind start -f Procfile.dev
