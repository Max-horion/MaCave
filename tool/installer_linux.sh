#!/usr/bin/env bash
# Compile la version de production de l'appli PC (Linux) et l'installe pour
# l'utilisateur courant, sans sudo, avec son lanceur dans le menu des
# applications.
#
# Les DONNÉES ne sont jamais touchées : la base et les préférences sont dans
# ~/.local/share/fr.bouthon.cave, les sauvegardes dans ~/Documents/Cave. Seuls
# les fichiers de l'appli (~/.local/share/ma-cave) et le lanceur sont
# remplacés.
#
# Usage : tool/installer_linux.sh             (compile puis installe)
#         tool/installer_linux.sh --no-build  (installe la version déjà compilée)
#         tool/installer_linux.sh --remove    (retire l'appli et le lanceur)
set -euo pipefail

cd "$(dirname "$0")/.."
BUNDLE=build/linux/x64/release/bundle
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA/ma-cave"
DESKTOP="$DATA/applications/fr.bouthon.cave.desktop"
ICON="$DATA/icons/hicolor/scalable/apps/fr.bouthon.cave.svg"

refresh_menu() {
  # Facultatif : le menu se met aussi à jour seul après quelques secondes.
  update-desktop-database "$DATA/applications" 2>/dev/null || true
  gtk-update-icon-cache -q "$DATA/icons/hicolor" 2>/dev/null || true
  kbuildsycoca6 >/dev/null 2>&1 || true
}

if pgrep -x -f "$APP_DIR/cave" >/dev/null; then
  echo "Ma Cave est ouverte : fermez-la d'abord (sa sauvegarde de fermeture" >&2
  echo "doit pouvoir se faire)." >&2
  exit 1
fi

if [[ "${1:-}" == "--remove" ]]; then
  rm -rf "$APP_DIR"
  rm -f "$DESKTOP" "$ICON"
  refresh_menu
  echo "Appli retirée. Données conservées dans $DATA/fr.bouthon.cave."
  exit 0
fi

if [[ "${1:-}" != "--no-build" ]]; then
  flutter build linux --release
fi
if [[ ! -x "$BUNDLE/cave" ]]; then
  echo "Version compilée introuvable ($BUNDLE)." >&2
  exit 1
fi

# Copie à côté puis échange : une installation interrompue ne laisse jamais
# une appli à moitié copiée.
rm -rf "$APP_DIR.new"
mkdir -p "$(dirname "$APP_DIR")"
cp -r "$BUNDLE" "$APP_DIR.new"
rm -rf "$APP_DIR"
mv "$APP_DIR.new" "$APP_DIR"

mkdir -p "$(dirname "$DESKTOP")" "$(dirname "$ICON")"
cp linux/packaging/fr.bouthon.cave.svg "$ICON"
sed "s|@EXEC@|$APP_DIR/cave|" linux/packaging/fr.bouthon.cave.desktop \
  > "$DESKTOP"
refresh_menu

echo "Installé dans $APP_DIR ; « Ma Cave » est dans le menu des applications."
