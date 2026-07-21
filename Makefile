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


## Generate/renew the local wildcard HTTPS certificate for *.exile.dev (requires mkcert)
certs:
	mkcert -install
	mkdir -p .docker/traefik/certs
	mkcert -cert-file .docker/traefik/certs/exile-dev.pem -key-file .docker/traefik/certs/exile-dev-key.pem "*.exile.dev" exile.dev


## List local HTTPS URLs and the hosts file entries they require
urls:
	@echo "== URLs locales (Traefik, HTTPS uniquement) =="
	@echo "  https://nexus.exile.dev     Nexus"
	@echo "  https://game.exile.dev      Game"
	@echo "  https://s01.exile.dev       Game (instance s01)"
	@echo "  https://db.exile.dev        Documentation du schema (SchemaSpy)"
	@echo "  https://traefik.exile.dev   Dashboard Traefik"
	@echo "  https://mailpit.exile.dev   Mailpit"
	@echo ""
	@echo "  Le certificat est un wildcard *.exile.dev : tout nouveau sous-domaine"
	@echo "  fonctionne sans regenerer de certificat, il faut juste l'ajouter au hosts."
	@echo ""
	@echo "== Prerequis =="
	@echo "  1. make certs   (genere le certificat wildcard via mkcert, une seule fois)"
	@echo "  2. Ajouter ces lignes dans C:\\Windows\\System32\\drivers\\etc\\hosts"
	@echo "     (edition manuelle, droits administrateur requis) :"
	@echo ""
	@echo "     127.0.0.1 nexus.exile.dev"
	@echo "     127.0.0.1 game.exile.dev"
	@echo "     127.0.0.1 s01.exile.dev"
	@echo "     127.0.0.1 db.exile.dev"
	@echo "     127.0.0.1 traefik.exile.dev"
	@echo "     127.0.0.1 mailpit.exile.dev"


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