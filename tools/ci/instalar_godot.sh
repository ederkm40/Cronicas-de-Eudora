#!/usr/bin/env bash
# Baixa o Godot (versão em GODOT_VERSION) e os modelos de exportação Web, se ainda não estiverem em ~/godot.
# Tudo vem das versões oficiais do Godot no GitHub. Gratuito.
set -euo pipefail

: "${GODOT_VERSION:?defina GODOT_VERSION, por exemplo 4.7.2}"
DESTINO_GODOT="$HOME/godot"
MODELOS="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"

if [ -x "$DESTINO_GODOT/godot" ] && [ -f "$MODELOS/web_nothreads_release.zip" ]; then
  echo "Godot ${GODOT_VERSION} já instalado."
  exit 0
fi

BASE="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable"
mkdir -p "$DESTINO_GODOT" "$MODELOS"
curl -fsSL -o /tmp/godot.zip "$BASE/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
unzip -q -o /tmp/godot.zip -d "$DESTINO_GODOT"
mv -f "$DESTINO_GODOT/Godot_v${GODOT_VERSION}-stable_linux.x86_64" "$DESTINO_GODOT/godot"
curl -fsSL -o /tmp/modelos.tpz "$BASE/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
unzip -q -o -j /tmp/modelos.tpz 'templates/web_*' 'templates/version.txt' -d "$MODELOS"
rm -f /tmp/godot.zip /tmp/modelos.tpz
echo "Godot ${GODOT_VERSION} instalado."
