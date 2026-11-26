#!/usr/bin/env bash
# Confere que a build de PRODUÇÃO não contém a ponte de testes e que a build de QA contém.
# A segunda conferência garante que a primeira não passa por engano (marcador errado).
#
# Uso: verificar_producao.sh <pasta-da-producao> <pasta-da-qa>
set -euo pipefail

PRODUCAO="$1"
QA="$2"
MARCADOR="scripts/web_bridge"

na_producao=$(grep -a -c "$MARCADOR" "$PRODUCAO/index.pck" || true)
na_qa=$(grep -a -c "$MARCADOR" "$QA/index.pck" || true)
echo "== Ponte de testes ($MARCADOR) no .pck: produção $na_producao · QA $na_qa"
if [ "$na_qa" -eq 0 ]; then
  echo "ERRO: a build de QA deveria conter a ponte; a verificação não é confiável."
  exit 1
fi
if [ "$na_producao" -ne 0 ]; then
  echo "ERRO: a build de produção contém a ponte de testes."
  exit 1
fi
echo "OK: a build de produção não contém a ponte de testes."
