#!/usr/bin/env bash
# Compile l'APK de production et l'installe sur le téléphone EN CONSERVANT
# SES DONNÉES (mise à jour sur place).
#
# Ne jamais utiliser `flutter install` : il désinstalle d'abord l'appli, ce qui
# efface sa base de données (incident du 5 octobre 2026).
#
# Usage : tool/installer.sh            (compile puis installe)
#         tool/installer.sh --no-build (installe l'APK déjà compilé)
set -euo pipefail

cd "$(dirname "$0")/.."
ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
APK=build/app/outputs/flutter-apk/app-release.apk
PACKAGE=fr.bouthon.cave

if ! "$ADB" get-state >/dev/null 2>&1; then
  echo "Téléphone non détecté : branchez-le, mode « Transfert de fichiers »," >&2
  echo "débogage USB activé (adb devices doit l'afficher)." >&2
  exit 1
fi

if [[ "${1:-}" != "--no-build" ]]; then
  flutter build apk --release
fi

first_install() {
  "$ADB" shell dumpsys package "$PACKAGE" | sed -n 's/.*firstInstallTime=//p' | head -1
}

before="$(first_install)"
# -r : remplace l'appli existante sans toucher à ses données.
"$ADB" install -r "$APK"
after="$(first_install)"

if [[ -n "$before" && "$before" != "$after" ]]; then
  echo "ATTENTION : l'appli a été réinstallée de zéro, ses données sont perdues." >&2
  exit 2
fi
echo "Installé${before:+ (mise à jour, données conservées ; installée le $before)}."
