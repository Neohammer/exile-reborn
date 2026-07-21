# Développement - Base de données

Commandes et workflow spécifiques à la base de données. Pour les commandes Docker générales, voir [docker.md](docker.md). Pour la description du schéma, voir [docs/database/README.md](../database/README.md).

---

# Import du dump legacy

## Génération du script d'init

```bash
make db-prepare
```

Génère `.docker/postgres/init/01-exile.sql` à partir de `exile_original/db/exile.sql` (jamais modifié), en corrigeant les incompatibilités du dump avec l'image `postgres:10` Linux :

- suppression du `CREATE DATABASE` (locale Windows absente sous Linux, base déjà créée par `POSTGRES_DB`) ;
- réécriture de `OWNER TO postgres` en `OWNER TO exile` (le rôle `postgres` n'existe pas dans le cluster).

Détails dans [technical-debt.md](technical-debt.md#import-legacy-postgresql).

Cette étape est automatiquement exécutée par `make start` et `make reset-db` (pas besoin de la lancer manuellement en usage normal).

## Réinitialisation complète

```bash
make reset-db
```

⚠️ Supprime le volume Docker PostgreSQL et réimporte le dump depuis zéro.

---

# Connexion à la base

| Paramètre | Valeur |
|---|---|
| Hôte | `localhost` (depuis l'hôte) / `postgres` (depuis les containers) |
| Port | `5432` |
| Base | `exile` |
| Utilisateur | `exile` |
| Mot de passe | `exile` |

## Shell psql

```bash
make db
```

## DBeaver / SchemaSpy

Utiliser les mêmes paramètres de connexion que ci-dessus. Voir aussi les identifiants dans `.docker/.env`.

---

# Documentation du schéma (SchemaSpy)

```bash
make schema-doc
```

Génère la documentation HTML du schéma (tables, colonnes, relations, fonctions) dans `docs/database/generated/` à partir des schémas `public`, `exile_nexus`, `exile_s03`, `static`.

Points d'attention :

- le service `schemaspy` est défini avec le profil Docker Compose `tools` : il ne démarre jamais avec `make start`, uniquement via `make schema-doc` ;
- le type de base utilisé est `-t pgsql` (générique) et non `pgsql11` : ce dernier interroge la colonne `pg_proc.prokind`, introduite en PostgreSQL 11, absente de notre PostgreSQL 10 et provoquant l'échec de l'extraction des fonctions ;
- les fichiers générés ne sont pas versionnés (`.gitignore`) ; à régénérer après toute modification du schéma.
