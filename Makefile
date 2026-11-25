DOCKER-RUN = docker compose run -e TERM --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

DATABASE_URL     = postgresql://postgres:dummy@primary-db:5434

.PHONY: db

build:
	docker compose build

up:
	docker compose up

down:
	docker compose down

die:
	docker compose down --remove-orphans --volumes

sh:
	$(DOCKER-RUN) web bash

cl:
	$(DOCKER-RUN) web bin/rails c

lint:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rubocop

debug:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rdbg -nA web 12345

# NOTE: don't use the things below
dev:
	bin/dev

tunnel:
	loophole http 3000 --hostname collectifobjets

tunnel_webhooks:
	loophole http 3000 --hostname collectifobjets-mail-inbound --path /api/v1/inbound_emails
