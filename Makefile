install:
	bundle install
	npm install --global husky
	npx husky install
	brew install overmind mailhog redis libvips

dev:
	overmind start -f Procfile.dev
