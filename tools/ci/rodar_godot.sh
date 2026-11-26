#!/usr/bin/env bash
# Roda um script de teste do Godot e falha também se aparecer um erro de script no log.
# O Godot nem sempre muda o código de saída quando um script quebra no meio de um teste
# (o erro é impresso e a execução segue). Este invólucro trata isso como falha.
#
# Uso: rodar_godot.sh <godot> <argumentos do Godot...>
set -uo pipefail

GODOT="$1"
shift
LOG=$(mktemp)
"$GODOT" "$@" 2>&1 | tee "$LOG"
STATUS=${PIPESTATUS[0]}
if grep -qE "SCRIPT ERROR|Parse Error|Invalid call|Invalid access" "$LOG"; then
  echo "ERRO: o log tem erro de script (veja as linhas acima)."
  grep -nE "SCRIPT ERROR|Parse Error|Invalid call|Invalid access" "$LOG" | head -20
  exit 1
fi
exit "$STATUS"
