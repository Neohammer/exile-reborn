# Docker Development

## Prérequis

- Docker Desktop
- Docker Compose
- Make

Le projet utilise Docker pour fournir un environnement de développement reproductible.

---

# Commandes principales

## Démarrer l'environnement

```bash
make start
```

Cette commande :
- construit les images si nécessaire ;
- démarre les conteneurs ;
- initialise les services.

---

## Arrêter l'environnement

```bash
make stop
```

Cette commande arrête les conteneurs sans supprimer les données persistantes.

---

## Redémarrer les services

```bash
make restart
```

---

## Voir l'état des conteneurs

```bash
make status
```

Affiche l'état des services Docker.

Services attendus :

| Service | Container |
|---|---|
| PHP | exile-php |
| PostgreSQL | exile-postgres |
| Redis | exile-redis |
| Mailpit | exile-mailpit |

---

## Afficher les logs

```bash
make logs
```

Affiche les logs en temps réel de tous les services.

---

# Accès aux conteneurs

## Shell PHP

```bash
make php
```

Permet d'ouvrir un shell dans le conteneur PHP.

Le conteneur contient :

- PHP 8.5
- Composer
- Extensions Symfony nécessaires

---

## Shell PostgreSQL

```bash
make db
```

Connexion :

| Paramètre | Valeur |
|---|---|
| Utilisateur | exile |
| Base | exile |

---

## Redis CLI

```bash
make redis
```

Permet d'utiliser Redis directement.

---

# Reconstruction

## Reconstruction complète des images

```bash
make build
```

Cette commande force une reconstruction complète sans utiliser le cache Docker.

---

# Base de données

## Réinitialisation complète

```bash
make reset-db
```

⚠️ Cette commande supprime les volumes Docker.

Elle provoque :

- régénération du script d'init depuis le dump legacy (cible `db-prepare`) ;
- suppression de la base PostgreSQL locale ;
- réimport du dump legacy ;
- recréation des données initiales.

À utiliser uniquement en développement.

Détails sur l'import, le schéma et la documentation SchemaSpy : voir [développement / base de données](database.md) et [docs/database/README.md](../database/README.md).

---

# Services Docker

| Service | Usage |
|---|---|
| PHP | Application Symfony |
| PostgreSQL | Base legacy migrée |
| Redis | Cache et sessions |
| Mailpit | Capture emails locaux |
| db-docs | Doc du schéma (SchemaSpy), solution temporaire avant Traefik |

Le service `schemaspy` (profil `tools`) n'est pas dans cette liste : il génère la doc puis s'arrête, voir [database.md](database.md).

---

# Ports locaux

| Service | Adresse |
|---|---|
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |
| Mailpit | http://localhost:8025 |
| db-docs | http://localhost:8090 |

---

# Organisation Docker

Les fichiers Docker sont situés dans :

```
.docker/
```

Structure :

```
.docker/

├── compose.yaml
├── php/
│   └── Dockerfile
├── postgres/
├── redis/
├── mailpit/
├── traefik/
└── schemaspy/
```

---

# Règles importantes

- Ne jamais modifier le dépôt legacy `exile_original`.
- Les migrations doivent être réalisées dans `exile-reborn`.
- Les fichiers générés automatiquement ne doivent pas être versionnés.
- La documentation générée par SchemaSpy doit rester ignorée par Git.
- Toute décision d'architecture importante doit être documentée dans `docs/architecture.md`.