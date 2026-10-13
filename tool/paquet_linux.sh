#!/usr/bin/env bash
# Construit l'AppImage de diffusion de l'appli PC Linux (lot 10) :
#   build/diffusion/MaCave-<version>-linux-x86_64.AppImage
# (nom fixé par docs/guide_installation.md ; version lue dans pubspec.yaml).
#
# Outils téléchargés une seule fois dans ~/.cache/ma-cave/appimage, versions
# figées et vérifiées par leur somme SHA-256 (publiée sur GitHub) :
# appimagetool 1.9.1 et le « runtime » type 2 du 2025-11-08 (sans FUSE 2 :
# il fonctionne aussi sur les distributions qui ne l'installent plus).
#
# L'appli utilise les bibliothèques du système (GTK 3, libsecret…), présentes
# sur tout bureau. Compilée sur Kubuntu 26.04, elle exige glibc 2.38 :
# Ubuntu 24.04, Debian 13, Fedora 39 ou plus récents (vérifié à la fin).
#
# Usage : tool/paquet_linux.sh             (compile puis construit)
#         tool/paquet_linux.sh --no-build  (reprend la version déjà compilée)
set -euo pipefail

cd "$(dirname "$0")/.."
BUNDLE=build/linux/x64/release/bundle
OUT=build/diffusion
VERSION="$(sed -n 's/^version: *\([^+]*\).*/\1/p' pubspec.yaml)"
TARGET="$OUT/MaCave-$VERSION-linux-x86_64.AppImage"

TOOLS="$HOME/.cache/ma-cave/appimage"
TOOL="$TOOLS/appimagetool-1.9.1-x86_64.AppImage"
TOOL_URL=https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage
TOOL_SHA=ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0
RUNTIME="$TOOLS/runtime-20251108-x86_64"
RUNTIME_URL=https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64
RUNTIME_SHA=2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d
# Version de glibc la plus récente admise (Ubuntu 24.04 : 2.39).
MAX_GLIBC=2.39

fetch() { # fichier adresse sha256
  if [[ ! -f "$1" ]]; then
    mkdir -p "$TOOLS"
    curl -fsSL -o "$1.part" "$2"
    mv "$1.part" "$1"
  fi
  if ! echo "$3  $1" | sha256sum -c --quiet; then
    echo "Somme de contrôle incorrecte pour $1 : fichier supprimé." >&2
    rm -f "$1"
    exit 1
  fi
}
fetch "$TOOL" "$TOOL_URL" "$TOOL_SHA"
fetch "$RUNTIME" "$RUNTIME_URL" "$RUNTIME_SHA"
chmod +x "$TOOL"

if [[ "${1:-}" != "--no-build" ]]; then
  flutter build linux --release
fi
if [[ ! -x "$BUNDLE/cave" ]]; then
  echo "Version compilée introuvable ($BUNDLE)." >&2
  exit 1
fi

# glibc exigée par l'exécutable et ses bibliothèques.
needed="$(for f in "$BUNDLE/cave" "$BUNDLE"/lib/*.so; do
  objdump -T "$f" | grep -oE 'GLIBC_[0-9.]+'
done | sed 's/GLIBC_//' | sort -V | tail -1)"
if [[ "$(printf '%s\n%s\n' "$needed" "$MAX_GLIBC" | sort -V | tail -1)" != "$MAX_GLIBC" ]]; then
  echo "L'appli exige glibc $needed (> $MAX_GLIBC) : elle ne tournerait plus" >&2
  echo "sur Ubuntu 24.04. Revoir docs/guide_installation.md avant de diffuser." >&2
  exit 1
fi

# Arborescence de l'AppImage : l'appli entière dans app/ (Flutter cherche
# lib/ et data/ à côté de l'exécutable), lanceur et icône à la racine.
APPDIR="$OUT/MaCave.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/share/metainfo" "$APPDIR/usr/share/applications" \
  "$APPDIR/usr/share/icons/hicolor/scalable/apps"
cp -r "$BUNDLE" "$APPDIR/app"
cat > "$APPDIR/AppRun" <<'RUN'
#!/bin/sh
exec "$(dirname "$(readlink -f "$0")")/app/cave" "$@"
RUN
chmod +x "$APPDIR/AppRun"
# Lanceur et icône rangés comme sur le système (exigé par la validation
# AppStream, et lu par Gear Lever), avec des liens à la racine.
sed "s|@EXEC@|cave|" linux/packaging/fr.bouthon.cave.desktop \
  > "$APPDIR/usr/share/applications/fr.bouthon.cave.desktop"
cp linux/packaging/fr.bouthon.cave.svg \
  "$APPDIR/usr/share/icons/hicolor/scalable/apps/fr.bouthon.cave.svg"
ln -s usr/share/applications/fr.bouthon.cave.desktop "$APPDIR/fr.bouthon.cave.desktop"
ln -s usr/share/icons/hicolor/scalable/apps/fr.bouthon.cave.svg "$APPDIR/fr.bouthon.cave.svg"
ln -s fr.bouthon.cave.svg "$APPDIR/.DirIcon"
# Nom attendu par appimagetool : <id du .desktop>.appdata.xml.
cp linux/packaging/fr.bouthon.cave.metainfo.xml \
  "$APPDIR/usr/share/metainfo/fr.bouthon.cave.appdata.xml"

# Description et lanceur vérifiés ici, sans réseau (appimagetool, lui,
# vérifie aussi les liens, introuvables tant que le dépôt GitHub est privé).
appstreamcli validate-tree --no-net "$APPDIR"

rm -f "$TARGET"
# APPIMAGE_EXTRACT_AND_RUN : appimagetool lui-même sans FUSE.
ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 "$TOOL" --no-appstream \
  --runtime-file "$RUNTIME" "$APPDIR" "$TARGET"
rm -rf "$APPDIR"
echo
echo "AppImage : $TARGET ($(du -h "$TARGET" | cut -f1), glibc $needed exigée)"
sha256sum "$TARGET"
