# Exile Reborn - Architecture

## Objectif

Exile Reborn est une modernisation progressive d'une application legacy ASP/PostgreSQL vers une architecture PHP Symfony moderne.

L'objectif n'est pas de réécrire immédiatement toute l'application, mais de remettre le service en fonctionnement rapidement puis de migrer progressivement les fonctionnalités.

---

# Principes directeurs

## Priorité au fonctionnement

La priorité initiale est :

1. remettre l'application en service ;
2. conserver les comportements existants ;
3. sécuriser progressivement ;
4. améliorer l'architecture.

Une architecture parfaite n'est pas un prérequis au démarrage.

---

# Architecture cible

Le projet est un monorepo contenant plusieurs applications.

Structure :

```
apps/

├── nexus
│
├── game
│
└── shared
```

---

# Nexus

## Rôle

Nexus est le site principal.

Responsabilités :

- authentification ;
- comptes utilisateurs ;
- gestion des serveurs ;
- interface utilisateur principale ;
- administration globale.

URL locale :

```
https://nexus.exile.dev
```

---

# Game

## Rôle

Game représente une instance de serveur de jeu.

Plusieurs instances pourront fonctionner :

```
s01.exile.dev
s02.exile.dev
s03.exile.dev
```

Chaque serveur peut avoir :

- sa configuration ;
- ses règles ;
- ses paramètres métier ;
- ses données spécifiques.

---

# Technologie cible

## Backend

- PHP 8.5
- Symfony dernière version stable
- Doctrine ORM
- PostgreSQL

## Frontend

- Twig
- Bootstrap
- JavaScript

---

# Infrastructure locale

L'environnement de développement est fourni par Docker.

Services :

| Service | Rôle |
|---|---|
| PHP | Application Symfony |
| webserver (nginx) | Pont HTTP entre Traefik et PHP-FPM |
| Traefik | Reverse proxy local, TLS (mkcert), routage par domaine |
| PostgreSQL | Base historique |
| Redis | Cache |
| Mailpit | Emails locaux |

Détails de configuration : [développement / docker.md](development/docker.md).

---

# Base de données

## Source

La base initiale provient du legacy :

```
exile_original/db/exile.sql
```

Caractéristiques :

- PostgreSQL 10.6 ;
- dump généré avec pg_dump 11.1 ;
- taille actuelle du dump : environ 1.3 Mo.

---

# Stratégie base de données

La base existante contient une grande quantité de logique métier :

- fonctions PostgreSQL ;
- procédures longues ;
- calculs complexes.

La migration suivra une approche progressive.

---

## Phase 1

Objectif :

Faire fonctionner Symfony avec la base existante.

Actions :

- importer le dump ;
- analyser le schéma ;
- documenter les fonctions importantes ;
- comprendre les relations.

---

## Phase 2

Objectif :

Déplacer progressivement la logique métier.

Actions :

- création de services Symfony ;
- migration des calculs métier ;
- tests sur les comportements critiques.

---

## Phase 3

Objectif :

Modernisation complète.

Actions possibles :

- suppression progressive des procédures SQL ;
- optimisation du modèle ;
- amélioration architecture.

---

# Migration Legacy

Le code historique ASP n'est pas traduit ligne par ligne.

Exemple legacy :

```
ASP
 |
 + include master
 |
 + chargement template
 |
 + affichage
```

Devient :

```
Symfony Controller

        |
        v

Service métier

        |
        v

Twig Template
```

---

# Organisation du code

## Applications

Chaque application possède son propre cycle :

```
apps/nexus

apps/game
```

Le code commun va dans :

```
apps/shared
```

---

# Tests

Les tests sont introduits progressivement.

Priorité :

1. tests des fonctionnalités critiques ;
2. tests des calculs métier ;
3. tests de non-régression.

Outils prévus :

- PHPUnit ;
- PHPStan ;
- PHP-CS-Fixer ;
- Rector.

---

# Outils d'analyse

## DBeaver

Utilisé pour :

- exploration PostgreSQL ;
- analyse des données ;
- validation des migrations.

## SchemaSpy

Utilisé pour :

- génération automatique de documentation SQL ;
- visualisation des relations.

Les fichiers générés ne sont pas versionnés.

---

# Déploiement futur

L'environnement local doit rester proche de la production.

Objectif :

```
Développement
      |
      v
Docker
      |
      v
Serveur Linux
      |
      v
Production
```

---

# Décisions importantes

## PostgreSQL conservé

Le choix PostgreSQL est stratégique car :

- la base existante est PostgreSQL ;
- de nombreuses fonctions métier existent déjà ;
- une migration vers MariaDB ajouterait un risque inutile.

---

## Redis ajouté dès le départ

Redis est prévu pour :

- cache Symfony ;
- sessions ;
- données temporaires ;
- futurs traitements asynchrones.

---

## Mailpit ajouté en développement

Mailpit permet :

- capture des emails ;
- tests sans envoi réel ;
- validation des workflows email.