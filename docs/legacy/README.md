# Legacy

Le code historique d'Exile vit dans un dépôt séparé :

```
../exile_original
```

**Ne jamais modifier ce dépôt.** Il sert uniquement de référence pour comprendre le comportement existant avant de le porter dans `exile-reborn`.

## Contenu

| Dossier | Contenu |
|---|---|
| `web-nexus/` | Site principal ASP (`.asp`), équivalent legacy de `apps/nexus` — auth, comptes, accueil, localisation. |
| `web-game/` | Serveur de jeu ASP, équivalent legacy de `apps/game`. |
| `db/exile.sql` | Dump PostgreSQL complet (schémas, fonctions, données). Source de l'import documenté dans [technical-debt.md](../development/technical-debt.md#import-legacy-postgresql). |
| `jobs/` | Tâches planifiées (XML) : mises à jour périodiques du jeu, événements, batailles, news. |
| `libs/` | Objets COM+ (32 bits) utilisés par l'ASP pour les templates et les combats — logique métier compilée, pas de source lisible directement. |
| `ad/`, `misc/` | Annexes (bannières publicitaires, divers). |

## Architecture d'origine

D'après le README du dépôt legacy, la stack de production était : Windows Server + IIS (ASP classique) + PostgreSQL + pilotes ODBC 32 bits + objets COM+ enregistrés via `libs/reg.bat`. Les DSN système `exile_nexus` et `exile_s03` de l'époque correspondent directement aux schémas PostgreSQL du même nom qu'on retrouve après import (voir [docs/database/README.md](../database/README.md)) — la nomenclature des schémas est donc historique, pas un choix fait pendant la migration.

## Utilisation pendant la migration

1. Lire le code ASP/COM+/SQL concerné pour comprendre le comportement réel (pas seulement ce qui semble logique).
2. Ne pas traduire ligne à ligne : identifier la logique métier, puis l'exprimer via un service Symfony (voir [docs/migration/README.md](../migration/README.md) pour l'approche).
3. Ne jamais supprimer une logique métier sans validation explicite — même si elle semble redondante ou obsolète.
