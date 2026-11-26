#!/usr/bin/env bash
# Baixa o branch gh-pages (só a última versão) numa pasta, ou cria o branch vazio se ainda não existir.
# Precisa de GH_TOKEN com permissão de escrita no conteúdo (o GITHUB_TOKEN do workflow).
# Uso: abrir_gh_pages.sh <pasta>
set -euo pipefail

PASTA="$1"
URL="https://x-access-token:${GH_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

rm -rf "$PASTA"
if git ls-remote --exit-code --heads "$URL" gh-pages > /dev/null 2>&1; then
  git clone --quiet --depth 1 --branch gh-pages "$URL" "$PASTA"
  echo "Branch gh-pages aberto ($(git -C "$PASTA" rev-parse --short HEAD))."
else
  mkdir -p "$PASTA"
  git -C "$PASTA" init --quiet
  git -C "$PASTA" checkout --quiet --orphan gh-pages
  git -C "$PASTA" remote add origin "$URL"
  echo "Branch gh-pages ainda não existe: será criado."
fi
git -C "$PASTA" config user.name "github-actions[bot]"
git -C "$PASTA" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
