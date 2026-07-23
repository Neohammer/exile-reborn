# Workflow de développement

## Branches

Une branche par sujet, nommée `feature/<sujet>` (ex. `feature/symfony-nexus`) ou `docs/<sujet>` pour la documentation seule. Pas de travail direct sur `main`.

Chaque branche part de `main` à jour :

```bash
git checkout main
git pull origin main
git checkout -b feature/mon-sujet
```

## Pull requests

Une PR par branche, même petite — c'est ce qui déclenche la CI. Squash-merge ou merge classique acceptés selon la taille du changement (un correctif isolé peut être squashé dans la PR qu'il corrige plutôt que de garder l'historique détaillé).

## Avant de pousser

Faire tourner localement ce que la CI vérifie, pour une app donnée (`APP=nexus` ou `APP=game`) :

```bash
make phpstan APP=nexus
make cs-check APP=nexus       # make cs-fix APP=nexus pour corriger automatiquement
make rector-check APP=nexus   # make rector-fix APP=nexus pour appliquer
docker exec exile-php bash -c "cd /var/www/html/nexus && php bin/phpunit"
```

## CI

`.github/workflows/ci.yml` exécute exactement ces vérifications sur chaque push et PR, pour `nexus` et `game` en parallèle. Voir [technical-debt.md](technical-debt.md#ci) pour le détail (pourquoi PHP natif plutôt que l'image Docker, absence volontaire de service PostgreSQL pour l'instant).

## Messages de commit

Impératif, présent, explique le *pourquoi* plutôt que le *quoi* (le diff montre déjà le quoi). Voir l'historique du dépôt pour le ton attendu — en particulier documenter les décisions non évidentes (pourquoi tel choix technique plutôt qu'un autre) directement dans le message, pas seulement dans la doc.

## Documentation

Toute décision technique non triviale (pourquoi ce choix, quel problème ça résout) va dans [technical-debt.md](technical-debt.md) si c'est un sujet reporté/résolu, ou dans [architecture.md](../architecture.md) si c'est une décision structurante durable. Garder [docs/README.md](../README.md) à jour comme index si un nouveau document apparaît.
