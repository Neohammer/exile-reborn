# Exile Reborn - Claude Instructions

## Présentation du projet

Exile Reborn est une réécriture progressive d'une application legacy ASP/PostgreSQL vers une architecture moderne PHP Symfony.

Objectif principal :

> Remettre l'application en service rapidement, puis améliorer progressivement la qualité du code.

La priorité est la fonctionnalité avant la perfection architecturale.

Index de toute la documentation : [docs/README.md](docs/README.md).
État d'avancement détaillé (ce qui est fait, ce qui reste, pourquoi) :
[docs/development/technical-debt.md](docs/development/technical-debt.md).

---

# Architecture générale

Le projet est organisé en monorepo.

Structure principale :

```
apps/

├── nexus
│   Site principal
│
├── game
│   Serveur de jeu
│
└── shared
    Code partagé
```

## Applications

### Nexus

Application principale.

Responsabilités :

- authentification ;
- gestion utilisateurs ;
- interface principale ;
- gestion des serveurs de jeu.

URL locale prévue :

https://nexus.exile.dev


### Game

Application représentant un serveur de jeu.

Plusieurs instances pourront exister :

- s01.exile.dev
- s02.exile.dev
- s03.exile.dev

Les règles peuvent varier selon :

- configuration ;
- version du serveur ;
- données en base.

---

# Infrastructure

L'environnement de développement utilise Docker.

Configuration :

```
.docker/

├── compose.yaml
├── php/
├── postgres/
├── redis/
├── mailpit/
├── traefik/
└── schemaspy/
```

Services principaux :

| Service | Rôle |
|---|---|
| PHP | Symfony / PHP 8.5 (Xdebug + php.ini custom, dev uniquement) |
| webserver (nginx) | Pont HTTP entre Traefik et PHP-FPM |
| traefik | Reverse proxy local, HTTPS uniquement, domaines `*.exile.dev` |
| PostgreSQL | Base legacy migrée |
| Redis | Cache et données temporaires |
| Mailpit | Emails locaux |

URLs locales et prérequis (certificat, fichier hosts) : `make urls`.
Détails : [docs/development/docker.md](docs/development/docker.md).

---

# Commandes principales

Le projet utilise Make.

Démarrage :

```bash
make start
```

Arrêt :

```bash
make stop
```

Statut :

```bash
make status
```

Logs :

```bash
make logs
```

Shell PHP :

```bash
make php
```

Accès base :

```bash
make db
```

Réinitialisation base :

```bash
make reset-db
```

---

# Legacy

Le code historique est situé dans :

```
../exile_original
```

Ne jamais modifier ce dépôt.

Le legacy contient :

- ASP ;
- fonctions PostgreSQL ;
- procédures métier historiques.

La migration doit conserver le comportement existant avant toute amélioration.

---

# Base de données

Source initiale :

```
exile_original/db/exile.sql
```

Origine :

- PostgreSQL 10.6
- dump réalisé avec pg_dump 11.1

La base contient beaucoup de logique métier :

- fonctions PostgreSQL ;
- procédures longues ;
- calculs métier.

Stratégie :

1. comprendre l'existant ;
2. documenter ;
3. migrer progressivement.

---

# Migration ASP vers Symfony

Le code ASP historique ressemble à :

```asp
<!--#include virtual="/master.asp"-->

<%
var content = loadTemplate('about');
display(content);
%>
```

La cible :

- Symfony ;
- Twig ;
- Bootstrap.

La migration ne doit pas chercher à traduire ligne par ligne.

Approche :

ASP
→ compréhension métier
→ service Symfony
→ contrôleur
→ Twig

---

# Qualité du code

La qualité est importante mais secondaire par rapport à la remise en service.

Priorités :

1. fonctionnalité ;
2. stabilité ;
3. tests sur les parties critiques ;
4. refactoring progressif.

Outils en place dans `apps/nexus` et `apps/game` (`make phpstan|cs-check|cs-fix|rector-check|rector-fix APP=...`) :

- PHPUnit ;
- PHPStan (niveau 8 + phpstan-symfony + phpstan-deprecation-rules) ;
- PHP-CS-Fixer (règle `@Symfony`) ;
- Rector.

CI GitHub Actions (`.github/workflows/ci.yml`) : exécute ces mêmes vérifications sur chaque push/PR, pour `nexus` et `game`.

---

# Base de données et analyse

Outils :

- DBeaver pour exploration SQL ;
- SchemaSpy pour documentation automatique (`make schema-doc`, servi sur `db.exile.dev`) ;
- scripts d'analyse dans :

```
tools/
```

La documentation générée automatiquement ne doit pas être commitée.

---

# Règles importantes

## Ne pas

- modifier `exile_original` ;
- supprimer une logique métier sans validation ;
- réécrire massivement sans comprendre le comportement.

## Toujours

- documenter les décisions importantes ;
- privilégier une migration fonctionnelle ;
- garder la compatibilité avec les données existantes.

---

# Philosophie du projet

Le projet suit une approche :

> Migration progressive d'un système legacy critique vers une architecture Symfony moderne.

Le code n'a pas besoin d'être parfait au premier jour.

Il doit d'abord fonctionner.

## Documentation technique

Les améliorations reportées sont suivies dans :

docs/development/technical-debt.md