# Migration ASP → Symfony

## État actuel

Aucune logique métier n'a encore été portée. Ce qui existe :

- `apps/nexus` et `apps/game` : squelettes Symfony 8.1 fonctionnels (Twig, Doctrine ORM, PHPUnit, PHPStan/CS-Fixer/Rector, CI) — voir [technical-debt.md](../development/technical-debt.md#installation-framework).
- Base PostgreSQL importée et documentée — voir [docs/database/README.md](../database/README.md).
- Aucun contrôleur, service ou entité applicatif écrit à ce stade.

## Approche

Ne pas traduire l'ASP ligne à ligne. Pour chaque page/fonctionnalité :

```
ASP (+ COM+ + fonctions PostgreSQL)
   → comprendre le comportement réel (lire le legacy, voir docs/legacy/README.md)
   → identifier la logique métier indépendamment de sa forme actuelle
   → service Symfony (la logique)
   → contrôleur (l'orchestration HTTP)
   → template Twig (l'affichage)
```

Exemple de correspondance structurelle :

```
ASP                                  Symfony
--------------------------------------------------------------
<!--#include virtual="/master.asp"-->   templates/base.html.twig
loadTemplate('about') + display()       Controller::about() + templates/about.html.twig
fonction PostgreSQL (sp_*)              soit conservée telle quelle (appelée depuis
                                         un Repository Doctrine), soit portée en PHP
                                         si la migration progressive le justifie
```

## Décisions à prendre au cas par cas

- **Fonctions PostgreSQL (`sp_*`) et COM+** : la base contient ~489 fonctions PostgreSQL portant une grande partie de la logique métier (combats, calculs de ressources, etc. — voir [technical-debt.md](../development/technical-debt.md#import-legacy-postgresql)). Les garder actives et les appeler depuis Doctrine est acceptable en phase 1 ; les porter en PHP est un objectif de phase 2/3 (voir [architecture.md](../architecture.md#stratégie-base-de-données)), pas un prérequis.
- **Schémas par instance de jeu** : `apps/game` doit pouvoir cibler `exile_s01`, `exile_s02`, `exile_s03`, ... — le mapping Doctrine (search_path / schema_filter) n'est pas encore fait, à traiter à l'arrivée des premières entités (voir [technical-debt.md](../development/technical-debt.md#solution-game)).

## Règles

- Ne jamais modifier `exile_original`.
- Ne jamais supprimer une logique métier sans validation.
- Documenter les décisions de migration non évidentes (pourquoi telle fonction est portée plutôt qu'appelée telle quelle, pourquoi tel comportement legacy est changé) dans le message de commit et, si structurant, dans ce document.
