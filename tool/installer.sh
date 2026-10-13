#!/usr/bin/env bash
# Compile l'APK de production et l'installe sur le téléphone EN CONSERVANT
# SES DONNÉES (mise à jour sur place).
#
# Ne jamais utiliser `flutter install` : il désinstalle d'abord l'appli, ce qui
# efface sa base de données (incident du 5 octobre 2026).
#
# Usage : tool/installer.sh            (compile puis installe)
#         tool/installer.sh --no-build (installe l'APK déjà compilé)
#         CAVE_SIGNING=debug tool/installer.sh  (clé de débogage, même si
#                                                android/key.properties existe)
set -euo pipefail

cd "$(dirname "$0")/.."
ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
# APK arm64 (voir plus bas).
APK=build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
PACKAGE=fr.bouthon.cave

if ! "$ADB" get-state >/dev/null 2>&1; then
  echo "Téléphone non détecté : branchez-le, mode « Transfert de fichiers »," >&2
  echo "débogage USB activé (adb devices doit l'afficher)." >&2
  exit 1
fi

if [[ "${1:-}" != "--no-build" ]]; then
  # Un APK par architecture ; on installe celui en arm64 : le téléphone du
  # porteur (et tout téléphone récent). Il est plus de deux fois plus léger
  # que l'APK universel (code natif de ML Kit et Tesseract). Un simple
  # --target-platform ne suffit pas : il ne filtre pas le code natif des
  # bibliothèques.
  flutter build apk --release --split-per-abi
fi

first_install() {
  "$ADB" shell dumpsys package "$PACKAGE" | sed -n 's/.*firstInstallTime=//p' | head -1
}

before="$(first_install)"
# -r : remplace l'appli existante sans toucher à ses données.
if ! output="$("$ADB" install -r "$APK" 2>&1)"; then
  echo "$output" >&2
  if [[ "$output" == *INSTALL_FAILED_UPDATE_INCOMPATIBLE* ]]; then
    # Clé de l'APK différente de celle de l'appli installée (lot 10 : clé de
    # débogage → clé de diffusion). Rien n'a été modifié sur le téléphone.
    echo >&2
    echo "L'appli du téléphone est signée avec une autre clé : Android refuse" >&2
    echo "la mise à jour (rien n'a été touché). NE PAS désinstaller sans avoir" >&2
    echo "vérifié une sauvegarde : la désinstallation efface la base." >&2
    echo "Pour rester sur la clé de débogage : CAVE_SIGNING=debug $0" >&2
  fi
  exit 1
fi
echo "$output"
after="$(first_install)"

if [[ -n "$before" && "$before" != "$after" ]]; then
  echo "ATTENTION : l'appli a été réinstallée de zéro, ses données sont perdues." >&2
  exit 2
fi
echo "Installé${before:+ (mise à jour, données conservées ; installée le $before)}."
