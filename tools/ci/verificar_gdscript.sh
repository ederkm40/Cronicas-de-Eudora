#!/usr/bin/env bash
# Verificação estática do GDScript com o GDScript Toolkit (gdtoolkit, versão em requirements-ci.txt).
#
# 1. gdlint em scripts/ e tests/ (todas as regras padrão do gdtoolkit; ver docs/decisoes/0009).
# 2. gdformat --check SÓ nos arquivos .gd adicionados ou alterados em relação ao commit-base.
#    O código antigo não é reformatado em massa: cada arquivo passa a seguir o gdformat quando é alterado.
#
# Uso: verificar_gdscript.sh lint
#      verificar_gdscript.sh formato [commit-base]
#   Sem commit-base (ou com um commit inválido, como o "antes" de um branch novo), a verificação
#   de formatação não se aplica e o script avisa.
#   GDLINT e GDFORMAT podem apontar para os executáveis (padrão: os que estiverem no PATH).
set -euo pipefail

GDLINT="${GDLINT:-gdlint}"
GDFORMAT="${GDFORMAT:-gdformat}"
MODO="${1:-}"
BASE="${2:-}"

if [ "$MODO" = "lint" ]; then
  echo "== $("$GDLINT" --version 2>&1 | head -1) em scripts/ e tests/"
  "$GDLINT" scripts tests
  exit 0
fi
if [ "$MODO" != "formato" ]; then
  echo "Uso: verificar_gdscript.sh lint | formato [commit-base]" >&2
  exit 2
fi

if [ -z "$BASE" ] || [ "$BASE" = "0000000000000000000000000000000000000000" ] \
    || ! git cat-file -e "${BASE}^{commit}" 2>/dev/null; then
  echo "== gdformat: sem commit-base para comparar; verificação de formatação não se aplica."
  exit 0
fi

PONTO=$(git merge-base "$BASE" HEAD)
mapfile -t ALTERADOS < <(git diff --name-only --diff-filter=ACMR "$PONTO" HEAD -- '*.gd')
if [ "${#ALTERADOS[@]}" -eq 0 ]; then
  echo "== gdformat: nenhum arquivo .gd alterado desde ${PONTO:0:7}."
  exit 0
fi
echo "== gdformat --check em ${#ALTERADOS[@]} arquivo(s) alterado(s) desde ${PONTO:0:7}:"
printf '   %s\n' "${ALTERADOS[@]}"
if ! "$GDFORMAT" --check "${ALTERADOS[@]}"; then
  echo "ERRO: arquivos alterados fora do padrão do gdformat. Para ver o que mudaria: gdformat --diff <arquivo>"
  exit 1
fi
