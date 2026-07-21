# Base de données

Vue d'ensemble du schéma PostgreSQL importé depuis le legacy. Pour la mise en place technique (import, commandes), voir [développement / base de données](../development/database.md).

---

## Origine

Le schéma provient du dump legacy :

```
exile_original/db/exile.sql
```

Caractéristiques :

- PostgreSQL 10.6, dump réalisé avec pg_dump 11.1 ;
- environ 1.3 Mo, ~36 000 lignes SQL ;
- 132 tables, 489 fonctions PostgreSQL.

Le détail des incompatibilités rencontrées lors de l'import (locale, ownership) et de leur résolution est documenté dans [technical-debt.md](../development/technical-debt.md#import-legacy-postgresql).

---

## Schémas

| Schéma | Tables | Rôle |
|---|---|---|
| `exile_nexus` | 7 | Données du site principal (Nexus) : `users`, `universes`, `news`, `awards`, `banned_domains`, `log_logins`, `users_successes`. |
| `exile_s03` | 87 | Données de gameplay de l'instance de serveur `s03` (planètes, flottes, alliances, rapports, etc.). |
| `static` | 38 | Données de référence et fonctions métier partagées entre instances de jeu. |
| `public` | 0 | Schéma par défaut PostgreSQL, actuellement vide. |

Chaque nouvelle instance de serveur de jeu (`s01`, `s02`, ...) aura son propre schéma sur le même modèle que `exile_s03`.

---

## Documentation générée (SchemaSpy)

Une documentation HTML détaillée (tables, colonnes, relations, fonctions) est générée via SchemaSpy :

```bash
make schema-doc
```

Résultat dans `docs/database/generated/index.html` (fichiers générés, non versionnés — voir `.gitignore`).

À régénérer après toute modification du schéma.

---

## Accès

Voir [développement / base de données](../development/database.md) pour les commandes (`make db`, `make reset-db`, connexion DBeaver).
