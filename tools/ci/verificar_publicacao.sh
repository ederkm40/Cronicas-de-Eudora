#!/usr/bin/env bash
# Confere se uma publicação está realmente no ar: espera o versao.json mostrar o commit certo
# e depois testa os arquivos do jogo e da Wiki.
#
# Uso: verificar_publicacao.sh <url-base com / no fim> <commit esperado> [minutos de espera, padrão 10]
# Sai com 0 se tudo abriu, 1 se não. Escreve o resultado em $GITHUB_OUTPUT (verificado=sim|nao), se existir.
set -uo pipefail

URL="$1"
ESPERADO="$2"
MINUTOS="${3:-10}"
SAIDA="${GITHUB_OUTPUT:-/dev/null}"

resultado() {
  echo "verificado=$1" >> "$SAIDA"
  echo "detalhe=$2" >> "$SAIDA"
  echo "$2"
  [ "$1" = "sim" ]
}

echo "Aguardando ${URL}versao.json mostrar o commit ${ESPERADO:0:7} (até ${MINUTOS} min)..."
fim=$(( $(date +%s) + MINUTOS * 60 ))
achado=""
while [ "$(date +%s)" -lt "$fim" ]; do
  achado=$(curl -fsSL --max-time 20 "${URL}versao.json?v=$(date +%s%N)" 2>/dev/null \
    | python3 -c "import json,sys; print(json.load(sys.stdin).get('commit',''))" 2>/dev/null || true)
  if [ "$achado" = "$ESPERADO" ]; then
    break
  fi
  sleep 15
done

if [ "$achado" != "$ESPERADO" ]; then
  resultado nao "Não abriu: ${URL}versao.json não mostrou o commit ${ESPERADO:0:7} em ${MINUTOS} min (visto: '${achado:-nada}'). Confira se o GitHub Pages usa o branch gh-pages." || exit 1
fi

falhas=""
for caminho in "" index.html index.js index.pck index.wasm wiki/ wiki/search-index.json wiki/assets/wiki.css; do
  codigo=$(curl -s -o /dev/null -w '%{http_code}' --max-time 60 "${URL}${caminho}?v=$(date +%s%N)")
  echo "  ${codigo}  ${URL}${caminho}"
  [ "$codigo" = "200" ] || falhas="$falhas ${caminho:-/}($codigo)"
done

if [ -n "$falhas" ]; then
  resultado nao "Publicado, mas com arquivos faltando:${falhas}" || exit 1
fi
resultado sim "Verificado: jogo (index.html, .js, .pck, .wasm) e Wiki respondem com o commit ${ESPERADO:0:7}."
