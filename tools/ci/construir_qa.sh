#!/usr/bin/env bash
# Exporta a build de QA (preset "Web QA", funcionalidade `qa`), com a ponte de testes
# scripts/web_bridge.gd. Ela serve SÓ para os testes do Playwright no CI: nunca é enviada
# ao job de publicação, ao site oficial ou às prévias.
#
# Uso: construir_qa.sh <pasta-do-projeto> <saída>
set -euo pipefail

PROJETO="$(cd "$1" && pwd)"
SAIDA="$2"
GODOT="${GODOT:-$HOME/godot/godot}"

rm -rf "$SAIDA"
mkdir -p "$SAIDA"
echo "== Exportando a build de QA de $PROJETO"
"$GODOT" --headless --path "$PROJETO" --export-release "Web QA" "$SAIDA/index.html" > /tmp/godot-export-qa.log 2>&1 \
  || { cat /tmp/godot-export-qa.log; exit 1; }
for arquivo in index.html index.js index.pck index.wasm; do
  if [ ! -s "$SAIDA/$arquivo" ]; then
    echo "ERRO: build de QA sem $arquivo"; cat /tmp/godot-export-qa.log; exit 1
  fi
done
ls -la "$SAIDA"
