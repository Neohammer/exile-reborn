#!/usr/bin/env bash
set -euo pipefail

# Génère le script d'init PostgreSQL utilisé par Docker à partir du dump legacy.
# Ne modifie jamais exile_original/db/exile.sql (dépôt en lecture seule).
#
# Corrections apportées :
# - suppression de "CREATE DATABASE exile ..." : la base est déjà créée par
#   POSTGRES_DB, et la locale du dump (French_France.1252) est une locale
#   Windows absente des images PostgreSQL Linux.
# - suppression de "ALTER DATABASE exile OWNER TO postgres;" (même raison).
# - remplacement de "OWNER TO postgres" par "OWNER TO exile" : le rôle
#   "postgres" n'existe pas dans l'image (POSTGRES_USER=exile est le seul
#   superutilisateur créé).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SOURCE_SQL="$REPO_ROOT/../exile_original/db/exile.sql"
OUTPUT_DIR="$REPO_ROOT/.docker/postgres/init"
OUTPUT_SQL="$OUTPUT_DIR/01-exile.sql"

if [ ! -f "$SOURCE_SQL" ]; then
    echo "Dump introuvable : $SOURCE_SQL" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

sed \
    -e '/^CREATE DATABASE exile WITH TEMPLATE/d' \
    -e '/^ALTER DATABASE exile OWNER TO postgres;$/d' \
    -e 's/OWNER TO postgres/OWNER TO exile/g' \
    "$SOURCE_SQL" > "$OUTPUT_SQL"

echo "Généré : $OUTPUT_SQL"
