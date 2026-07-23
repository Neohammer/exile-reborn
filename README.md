# Exile Reborn

Réécriture progressive d'Exile (jeu de stratégie spatiale, legacy ASP/PostgreSQL) vers une architecture PHP Symfony moderne.

Priorité : remettre l'application en service rapidement, puis améliorer progressivement la qualité du code. Voir [CLAUDE.md](CLAUDE.md) pour la philosophie complète du projet et les instructions destinées à Claude Code.

---

## Démarrage rapide

Prérequis : Docker Desktop, Make, [mkcert](https://github.com/FiloSottile/mkcert).

```bash
make start      # construit les images et démarre l'environnement
make certs      # génère le certificat HTTPS local (une seule fois par poste)
make urls       # liste les URLs disponibles et les entrées à ajouter au fichier hosts
```

Détails complets : [docs/development/docker.md](docs/development/docker.md).

## Structure

```
apps/
├── nexus     Site principal (auth, comptes, gestion des serveurs)
├── game      Serveur de jeu (une instance par galaxie : s01, s02, ...)
└── shared    Code partagé entre applications

exile_original/   Dépôt legacy ASP/PostgreSQL (jamais modifié, lecture seule)
```

## Documentation

Index complet : [docs/README.md](docs/README.md).

- [docs/roadmap.md](docs/roadmap.md) — plan de travail : fait, prochaine étape, ordre à suivre.
- [docs/architecture.md](docs/architecture.md) — architecture générale et stratégie de migration.
- [docs/development/technical-debt.md](docs/development/technical-debt.md) — état d'avancement détaillé (fait / reste à faire, avec le pourquoi).
- [docs/development/workflow.md](docs/development/workflow.md) — workflow de développement (branches, qualité, CI).
- [docs/database/README.md](docs/database/README.md) — schéma de la base de données.
