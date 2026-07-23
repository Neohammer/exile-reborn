# Plan de travail

Suivi séquencé de ce qui a été fait et de ce qui reste, à un niveau plus concret que [architecture.md](architecture.md) (les grandes phases) et plus actionnable que [technical-debt.md](development/technical-debt.md) (le détail technique par sujet).

À tenir à jour à chaque étape franchie : cocher, ajouter le lien vers la doc/PR concernée, et ajuster l'ordre si les priorités changent.

---

## Fait — Infrastructure (phase 0)

- [x] Import de la base PostgreSQL legacy, corrigée pour Docker/Linux.
- [x] Documentation automatique du schéma (SchemaSpy).
- [x] Symfony 8.1 scaffoldé dans `apps/nexus` et `apps/game` (Twig, Doctrine ORM, PHPUnit).
- [x] HTTPS local (Traefik, certificat wildcard `*.exile.dev`, tous les outils dev routés par domaine).
- [x] Configuration PHP dev (Xdebug, OPcache, php.ini).
- [x] Qualité de code (PHPStan niveau 8, PHP-CS-Fixer, Rector) + CI GitHub Actions.

Détails et décisions techniques : [technical-debt.md](development/technical-debt.md).

---

## En cours / prochaine étape — Nexus : authentification

Rien n'est encore écrit côté code applicatif. Première brique concrète à poser, dans cet ordre :

1. **Pages statiques simples** (`about.asp`, `intro.asp`, `faq.asp`, `conditions.asp`) — aucune auth, aucune écriture en base. Sert à valider le pipeline routing → contrôleur → Twig sur un cas trivial avant d'attaquer l'auth.
2. **Inscription** (`register.asp` → `registered.asp`) — première entité Doctrine (`User`), première migration, premier appel à une fonction PostgreSQL legacy (`sp_account_create` ou équivalent — voir [docs/legacy/README.md](legacy/README.md)).
3. **Connexion** (`login.asp`, `authenticate.asp`, `logout.asp`) — Symfony Security, comparaison avec le hashing legacy (`sp_account_hashpassword`) pour décider migration douce vs réhash au premier login.
4. **Mot de passe oublié** (`lostpassword.asp` → `passwordreset.asp` → `passwordsent.asp`) — premier usage réel de Mailpit en dev.
5. **Gestion du compte** (`account-options.asp` + variantes email/password, `account-awards.asp`).
6. **Liste des serveurs** (`servers.asp`) — première jonction Nexus ↔ instances Game.

Chaque étape : lire l'ASP correspondant dans `exile_original/web-nexus/`, comprendre le comportement réel avant de porter — voir [docs/migration/README.md](migration/README.md) pour l'approche.

---

## Ensuite — Game

Pas commencé. Dépend d'avoir une session Nexus fonctionnelle (connexion à un serveur = lien Nexus → Game). Premier sujet ouvert à trancher : mapping Doctrine par schéma d'instance (`exile_s03` aujourd'hui, `exile_s01`/`s02` à venir) — voir [technical-debt.md](development/technical-debt.md#solution-game).

## Plus tard — Phases 2/3 (architecture.md)

- Migration progressive de la logique métier portée par les ~489 fonctions PostgreSQL (`sp_*`) vers des services Symfony, au cas par cas.
- Modernisation architecture une fois le legacy fonctionnellement remplacé (pas avant).

---

## Backlog (non séquencé)

Sujets connus mais pas encore priorisés — voir [technical-debt.md](development/technical-debt.md) pour le détail :

- Traefik/mkcert pour les futures instances `s02.exile.dev`, `s03.exile.dev` (le certificat wildcard les couvre déjà, il manque juste les routers).
- Image PHP de production distincte (Xdebug, `display_errors`, `opcache.validate_timestamps` doivent y être différents du dev).
