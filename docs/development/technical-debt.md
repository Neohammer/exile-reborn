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

avec certificats locaux valides.

## Solution prévue

Traefik comme reverse proxy local.

Gestion certificat :

- mkcert ;
- certificat de développement local ;
- confiance système Windows.

---

# Symfony

## Installation framework

Statut : À faire

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

---

# Base de données

## Import legacy PostgreSQL

Statut : À faire

Priorité : Haute

## Objectif

Importer :

exile_original/db/exile.sql

dans PostgreSQL Docker.

Étapes :

- validation compatibilité PostgreSQL moderne ;
- import ;
- analyse des erreurs ;
- documentation du schéma.

---

# Analyse base de données

## SchemaSpy

Statut : À faire

Priorité : Moyenne

## Objectif

Générer une documentation automatique du schéma PostgreSQL.

Utilisation :

- compréhension du legacy ;
- aide migration ;
- support Claude Code.

Les fichiers générés ne doivent pas être versionnés.

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