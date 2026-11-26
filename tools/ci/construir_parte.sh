#!/usr/bin/env bash
# Exporta o jogo para Web e gera a Wiki de um projeto, numa pasta pronta para publicar.
#
# Uso: construir_parte.sh <pasta-do-projeto> <saída> <canal: oficial|previa> <pr> <commit> <branch>
#
# Resultado em <saída>:
#   index.html, index.js, index.pck, index.wasm (+ arquivos auxiliares do Godot)
#   wiki/          Wiki gerada a partir de <projeto>/wiki-src e <projeto>/docs
#   versao.json    commit, canal, PR e branch desta montagem (usado na verificação da publicação)
#
# O gerador da Wiki usado é sempre o desta cópia de tools/, mesmo quando o projeto é outro checkout.
set -euo pipefail

PROJETO="$(cd "$1" && pwd)"
SAIDA="$2"
CANAL="$3"
PR="$4"
COMMIT="$5"
BRANCH="$6"
FERRAMENTAS="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-$HOME/godot/godot}"

rm -rf "$SAIDA"
mkdir -p "$SAIDA"
SAIDA="$(cd "$SAIDA" && pwd)"

echo "== Exportando o jogo de $PROJETO"
"$GODOT" --headless --path "$PROJETO" --import > /tmp/godot-import.log 2>&1 || { cat /tmp/godot-import.log; exit 1; }
"$GODOT" --headless --path "$PROJETO" --export-release "Web" "$SAIDA/index.html" > /tmp/godot-export.log 2>&1 || { cat /tmp/godot-export.log; exit 1; }
for arquivo in index.html index.js index.pck index.wasm; do
  if [ ! -s "$SAIDA/$arquivo" ]; then
    echo "ERRO: exportação sem $arquivo"; cat /tmp/godot-export.log; exit 1
  fi
done

echo "== Gerando a Wiki"
if [ -d "$PROJETO/wiki-src" ]; then
  python3 "$FERRAMENTAS/wiki/build_wiki.py" --fonte "$PROJETO/wiki-src" --docs "$PROJETO/docs" \
    --saida "$SAIDA/wiki" --canal "$CANAL" --pr "$PR" --commit "$COMMIT" --branch "$BRANCH"
else
  # Versões antigas do jogo (antes da Wiki existir) ganham uma página de aviso no lugar da Wiki.
  mkdir -p "$SAIDA/wiki"
  cat > "$SAIDA/wiki/index.html" <<'HTML'
<!DOCTYPE html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Wiki · Crônicas de Eudora</title><style>body{margin:0;padding:32px 18px;background:#121017;color:#ece9f3;font:17px/1.6 system-ui,sans-serif}main{max-width:640px;margin:0 auto}a{color:#5ae6ff}</style></head>
<body><main><h1>Wiki de Crônicas de Eudora</h1>
<p>A Wiki oficial ainda não foi publicada: ela chega junto com a etapa de infraestrutura, quando for aprovada.</p>
<p>Enquanto isso, a Wiki em teste fica nas <a href="../previews/">prévias abertas</a>.</p>
<p><a href="../">Jogar a versão oficial</a></p></main></body></html>
HTML
fi

python3 - "$SAIDA/versao.json" "$COMMIT" "$CANAL" "$PR" "$BRANCH" <<'PY'
import json, sys
destino, commit, canal, pr, branch = sys.argv[1:]
json.dump({"commit": commit, "canal": canal, "pr": pr, "branch": branch}, open(destino, "w"), indent=2, sort_keys=True)
PY
echo "== Parte pronta em $SAIDA"
ls -la "$SAIDA"
