# Exile Reborn - Development Commands

DOCKER_DIR=.docker
COMPOSE=docker compose -f $(DOCKER_DIR)/compose.yaml


## Start environment
start:
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
reset-db:
	$(COMPOSE) down -v
	$(COMPOSE) up -d


## Composer install in PHP container
composer-install:
	docker exec exile-php composer install


## Clear Symfony cache
cache-clear:
	docker exec exile-php php bin/console cache:clear