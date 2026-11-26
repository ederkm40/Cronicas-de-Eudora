#!/usr/bin/env bash
# Faz o commit do site montado e envia para o branch gh-pages. Não faz nada se não houver mudança.
# Depois pede ao GitHub Pages uma nova publicação (ignora erro: o push normalmente já dispara).
# Uso: enviar_gh_pages.sh <pasta> <mensagem>
set -euo pipefail

PASTA="$1"
MENSAGEM="$2"

git -C "$PASTA" add -A
if git -C "$PASTA" diff --cached --quiet; then
  echo "Nada mudou no site; nada a enviar."
  exit 0
fi
git -C "$PASTA" commit --quiet -m "$MENSAGEM"
git -C "$PASTA" push --quiet origin gh-pages
echo "Enviado para gh-pages: $(git -C "$PASTA" rev-parse --short HEAD) — $MENSAGEM"
gh api -X POST "repos/${GITHUB_REPOSITORY}/pages/builds" > /dev/null 2>&1 \
  && echo "Publicação do GitHub Pages solicitada." \
  || echo "Aviso: não foi possível solicitar a publicação ao GitHub Pages (normal se ele ainda não usa o branch gh-pages)."
