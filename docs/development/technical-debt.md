# Technical Debt

Ce document liste les sujets volontairement reportés afin de privilégier la remise en service rapide de l'application.

Les éléments listés ici ne sont pas oubliés : ils représentent des améliorations prévues après stabilisation de l'environnement.

---

# PHP

## OPcache

Statut : À configurer

L'extension est présente dans PHP 8.5.
Il reste uniquement la configuration dev/prod.

## Contexte

OPcache améliore les performances PHP en conservant le bytecode compilé en mémoire.

L'installation avec PHP 8.5 dans l'image Docker actuelle présente un problème lors de l'étape :

docker-php-ext-install opcache

Le démarrage de l'environnement ne doit pas être bloqué pour cette optimisation.

## À faire

- vérifier la méthode d'installation compatible PHP 8.5 ;
- ajouter une configuration dédiée :
  - développement : revalidation des fichiers activée ;
  - production : revalidation désactivée.

---

# PHP Debug

## Xdebug

Statut : À faire

Priorité : Haute

## Objectif

Ajouter Xdebug uniquement dans l'environnement de développement.

Utilisations :

- debug avec PhpStorm ;
- analyse du code ;
- couverture de tests PHPUnit.

## Attention

Xdebug ne doit pas être activé en production.

---

# Configuration PHP

## php.ini personnalisé

Statut : À faire

Priorité : Haute

## Objectif

Ajouter une configuration PHP adaptée au projet Symfony.

Éléments à définir :

- memory_limit ;
- upload_max_filesize ;
- post_max_size ;
- timezone ;
- erreurs PHP ;
- logs ;
- OPcache.

Structure prévue :

.docker/php/

php.ini

conf.d/

---

# HTTPS local

## Traefik et certificats

Statut : À faire

Priorité : Haute

## Objectif

Fournir les URLs locales :

https://exile.nexus.dev

https://game.exile.dev

https://s01.exile.dev

https://db.exile.dev (documentation du schéma, voir ci-dessous)

avec certificats locaux valides.

## Solution prévue

Traefik comme reverse proxy local.

Gestion certificat :

- mkcert ;
- certificat de développement local ;
- confiance système Windows.

## Solution temporaire

En attendant, la documentation SchemaSpy est servie par un conteneur nginx
statique (service `db-docs`) directement accessible sur
`http://localhost:8090`, sans domaine ni HTTPS. À remplacer par
`https://db.exile.dev` une fois Traefik en place.

---

# Symfony

## Installation framework

Statut : Nexus fait, Game à faire

Priorité : Haute

## Objectif

Initialiser les applications :

apps/nexus

apps/game

avec :

- Symfony ;
- Twig ;
- Bootstrap ;
- Doctrine ;
- PHPUnit.

## Solution (Nexus)

`apps/nexus` initialisé via `composer create-project symfony/skeleton`
(Symfony 8.1), puis packs ajoutés un par un :

- `composer require twig` ;
- `composer require symfony/orm-pack` (Doctrine ORM + migrations) ;
- `composer require --dev symfony/test-pack` (PHPUnit).

`DATABASE_URL` réel dans `apps/nexus/.env.local` (gitignoré) :
`postgresql://exile:exile@postgres:5432/exile?serverVersion=10&charset=utf8`.
Connexion à la base et `bin/phpunit` vérifiés.

`Makefile` : `composer-install` et `cache-clear` acceptent désormais un
paramètre `APP` (défaut `nexus`), ex. `make cache-clear APP=game`.

Bootstrap (assets frontend) pas encore intégré — à faire avec la première
vraie page Twig.

`apps/game` reste à initialiser sur le même modèle.

---

# Base de données

## Import legacy PostgreSQL

Statut : Fait

Priorité : Haute

## Objectif

Importer :

exile_original/db/exile.sql

dans PostgreSQL Docker.

## Problèmes rencontrés

Le dump brut ne s'importait pas tel quel dans l'image `postgres:10` (Linux) :

- `CREATE DATABASE exile ... LC_COLLATE = 'French_France.1252'` : locale Windows
  absente sous Linux, faisait échouer l'import dès la ligne 25 (base déjà créée
  par `POSTGRES_DB` de toute façon) ;
- `ALTER ... OWNER TO postgres` (754 occurrences) : le rôle `postgres` n'existe
  pas dans le cluster (seul `POSTGRES_USER=exile` est créé comme superutilisateur).

## Solution

`exile_original` n'est jamais modifié. À la place :

- `scripts/db/generate-init-sql.sh` génère une copie filtrée du dump dans
  `.docker/postgres/init/01-exile.sql` (généré, gitignoré) :
  - suppression du `CREATE DATABASE` et du `ALTER DATABASE ... OWNER TO postgres` ;
  - remplacement de `OWNER TO postgres` par `OWNER TO exile`.
- `compose.yaml` monte désormais `.docker/postgres/init/` (dossier) au lieu du
  fichier brut sur `/docker-entrypoint-initdb.d`.
- `make start` et `make reset-db` dépendent de la cible `db-prepare` qui
  régénère ce fichier avant de démarrer les containers.

## Vérifié

4 schémas (`exile_nexus`, `exile_s03`, `static`, `public`), 132 tables,
489 fonctions, données chargées, aucune erreur dans les logs `exile-postgres`.

## Reste à faire

Rien : import et documentation du schéma sont terminés (voir section SchemaSpy ci-dessous).

---

# Analyse base de données

## SchemaSpy

Statut : Fait

Priorité : Moyenne

## Objectif

Générer une documentation automatique du schéma PostgreSQL.

Utilisation :

- compréhension du legacy ;
- aide migration ;
- support Claude Code.

Les fichiers générés ne doivent pas être versionnés.

## Solution

Service `schemaspy` ajouté dans `compose.yaml` avec le profil Docker Compose
`tools` (ne démarre jamais avec `make start`). Lancement via :

```bash
make schema-doc
```

Sortie dans `docs/database/generated/` (gitignoré).

Point d'attention : le type de base `-t pgsql11` interroge `pg_proc.prokind`
(colonne introduite en PostgreSQL 11), absente de notre PostgreSQL 10 —
utiliser `-t pgsql` (générique) à la place, sous peine de perdre la
documentation des fonctions.

Voir [docs/database/README.md](../database/README.md) pour le détail des schémas.

---

# Qualité code

## PHPStan

Statut : À faire

Priorité : Moyenne

Objectif :

Ajouter progressivement l'analyse statique.

Approche :

- démarrage permissif ;
- augmentation progressive du niveau.

---

## PHP-CS-Fixer

Statut : À faire

Priorité : Moyenne

Objectif :

Uniformiser le style PHP.

---

## Rector

Statut : À faire

Priorité : Faible

Objectif :

Aider aux transformations automatiques de code lors des migrations.

---

# Règle

Les éléments de cette liste peuvent être reportés si leur réalisation bloque la remise en service de l'application.