# Docker Development

## Prérequis

- Docker Desktop
- Docker Compose
- Make
- [mkcert](https://github.com/FiloSottile/mkcert) (certificats HTTPS locaux)

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

Le volume `apps/` est monté sur `/var/www/html` : chaque application Symfony
vit dans son propre sous-dossier (`apps/nexus`, `apps/game`, ...). Pour lancer
Composer ou une commande Symfony directement sans ouvrir de shell :

```bash
make composer-install APP=nexus
make cache-clear APP=nexus
```

`APP` vaut `nexus` par défaut.

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
| PHP | PHP-FPM, exécute les applications Symfony |
| webserver | nginx, pont HTTP entre Traefik et PHP-FPM (un `server{}` par app) |
| traefik | Reverse proxy local, TLS, routage par domaine |
| PostgreSQL | Base legacy migrée |
| Redis | Cache et sessions |
| Mailpit | Capture emails locaux |
| db-docs | Doc du schéma (SchemaSpy) |

Le service `schemaspy` (profil `tools`) n'est pas dans cette liste : il génère la doc puis s'arrête, voir [database.md](database.md).

---

# Ports locaux

Seuls les ports non-HTTP (accès direct par un client, pas un navigateur)
restent publiés. Tout le reste (dashboard Traefik, Mailpit, doc du schéma,
apps Symfony) passe uniquement par les domaines `*.exile.dev` en HTTPS.

| Service | Adresse |
|---|---|
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |
| Mailpit (SMTP) | localhost:1025 |
| Traefik (HTTPS uniquement) | 443 |

---

# HTTPS local (Traefik)

```bash
make urls
```

Rappelle les URLs disponibles ainsi que les prérequis (`make certs` et les
entrées à ajouter dans le fichier hosts).

URLs servies via Traefik une fois le certificat généré et le fichier hosts
configuré (voir [technical-debt.md](technical-debt.md#https-local)) :

| URL | Application |
|---|---|
| https://nexus.exile.dev | Nexus |
| https://game.exile.dev | Game |
| https://s01.exile.dev | Game (instance s01) |
| https://db.exile.dev | Documentation du schéma (SchemaSpy) |
| https://traefik.exile.dev | Dashboard Traefik |
| https://mailpit.exile.dev | Interface Mailpit |

Générer/renouveler le certificat local (mkcert) :

```bash
make certs
```

Certificat wildcard (`*.exile.dev` + `exile.dev`) : tout nouveau sous-domaine
Traefik fonctionne sans regénérer de certificat, il suffit de l'ajouter au
fichier hosts et de créer le router correspondant.

À faire une seule fois par poste de développement : ajouter les domaines
ci-dessus dans le fichier hosts Windows
(`C:\Windows\System32\drivers\etc\hosts`, édition manuelle avec droits
administrateur) pointant vers `127.0.0.1`.

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
├── nginx/
│   └── default.conf
├── postgres/
├── redis/
├── mailpit/
├── traefik/
│   ├── traefik.yml
│   ├── dynamic/
│   └── certs/        (généré par mkcert, gitignoré)
└── schemaspy/
```

---

# Règles importantes

- Ne jamais modifier le dépôt legacy `exile_original`.
- Les migrations doivent être réalisées dans `exile-reborn`.
- Les fichiers générés automatiquement ne doivent pas être versionnés.
- La documentation générée par SchemaSpy doit rester ignorée par Git.
- Toute décision d'architecture importante doit être documentée dans `docs/architecture.md`.