# Exile Reborn - Development Commands

DOCKER_DIR=.docker
COMPOSE=docker compose -f $(DOCKER_DIR)/compose.yaml

# Symfony app targeted by composer-install/cache-clear (nexus, game, ...)
APP ?= nexus


## Generate PostgreSQL init script from the legacy dump
db-prepare:
	bash scripts/db/generate-init-sql.sh


## Start environment
start: db-prepare
	$(COMPOSE) up -d --build


## Stop environment
stop:
	$(COMPOSE) down


## Restart containers
restart:
	$(COMPOSE) restart


## Show containers status
status:
	$(COMPOSE) ps


## Follow logs
logs:
	$(COMPOSE) logs -f


## PHP container shell
php:
	docker exec -it exile-php bash


## PostgreSQL shell
db:
	docker exec -it exile-postgres bash


## Redis CLI
redis:
	docker exec -it exile-redis redis-cli


## Build without cache
build:
	$(COMPOSE) build --no-cache


## Reset database completely
## WARNING: deletes Docker volumes
reset-db: db-prepare
	$(COMPOSE) down -v
	$(COMPOSE) up -d


## Generate database schema documentation (SchemaSpy)
schema-doc:
	$(COMPOSE) --profile tools run --rm schemaspy


## Generate/renew local HTTPS certificates for *.exile.dev / *.nexus.dev (requires mkcert)
certs:
	mkcert -install
	mkdir -p .docker/traefik/certs
	mkcert -cert-file .docker/traefik/certs/exile-dev.pem -key-file .docker/traefik/certs/exile-dev-key.pem exile.nexus.dev game.exile.dev s01.exile.dev db.exile.dev


## Composer install for one app (default: nexus, override with APP=game)
composer-install:
	docker exec exile-php bash -c "cd /var/www/html/$(APP) && composer install"


## Clear Symfony cache for one app (default: nexus, override with APP=game)
cache-clear:
	docker exec exile-php bash -c "cd /var/www/html/$(APP) && php bin/console cache:clear"

## Environment diagnostics
doctor:
	@echo "== Docker containers =="
	@$(COMPOSE) ps
	@echo ""

	@echo "== PHP version =="
	@docker exec exile-php php -v || true
	@echo ""

	@echo "== PHP extensions =="
	@docker exec exile-php php -m | grep -E "intl|pdo_pgsql|redis|zip" || true
	@echo ""

	@echo "== Composer =="
	@docker exec exile-php composer --version || true
	@echo ""

	@echo "== Redis =="
	@docker exec exile-redis redis-cli ping || true
	@echo ""

	@echo "== PostgreSQL =="
	@docker exec exile-postgres pg_isready || true
	@echo ""

	@echo "== Mailpit =="
	@echo "Open http://localhost:8025"