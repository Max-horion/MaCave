# Ma Cave

Gestion d'une cave personnelle (vins, bières, spiritueux, softs) sur téléphone **Android** et ordinateur **Windows** ou **Linux**. Elle fonctionne **entièrement hors ligne**. La synchronisation entre appareils par votre propre serveur **Nextcloud** ou **WebDAV** est facultative.

Gratuite, sans compte, sans publicité, sans pistage : vos données restent sur vos appareils et votre serveur.

## Ce qu'elle fait

- Références, lots (millésime × volume) et stock, avec l'historique des entrées, sorties et inventaires.
- Recherche dans tout ce qui est affiché, filtres, tris, favoris, fiches « à compléter ».
- Retrait d'une bouteille d'un geste (« −1 »), avec **Annuler**.
- Scan du code-barres et lecture de l'étiquette par photo, sur le téléphone. Le texte est lu sur l'appareil ; une fiche peut être pré-remplie par Open Food Facts (facultatif, seul le code-barres est envoyé).
- Inventaire guidé, statistiques, import Vivino ou tableur, export CSV.
- Sauvegardes automatiques, synchronisation entre plusieurs appareils sans perte (les mouvements faits hors ligne s'additionnent).

## Installer

Téléchargez la dernière version sur la page [**Releases**](https://github.com/Max-horion/MaCave/releases) :

| Pour | Fichier |
|---|---|
| Android 8 ou plus récent | `MaCave-<version>-android.apk` (ancien téléphone : `…-android-armv7.apk`) |
| Windows 10 ou 11 (64 bits) | `MaCave-<version>-windows-setup.exe` |
| Linux 64 bits (Ubuntu 24.04, Debian 13, Fedora 39 ou plus récents) | `MaCave-<version>-linux-x86_64.AppImage` |

Pas à pas, avertissements de sécurité expliqués, mises à jour : [guide d'installation](docs/guide_installation.md). Utilisation : [guide d'utilisation](docs/guide_utilisation.md).

L'APK Android est signé par une clé dont l'empreinte SHA-256 est :
`af941f5159bf226af3c8b2e1c8ca10d0c47b971b2771a4efdbac0cb3391cc3ea`

## Retours

Une idée, un défaut, une question : ouvrez un [ticket](https://github.com/Max-horion/MaCave/issues) ou écrivez à **maxence@bouthon.fr**.

## Pour les développeurs

Application [Flutter](https://flutter.dev) (Dart) : base SQLite locale (drift), état de l'interface avec Riverpod, synchronisation WebDAV maison. Reconnaissance de texte par Tesseract et codes-barres par ZXing, tous deux libres.

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d linux        # ou : un téléphone Android branché, ou -d windows sous Windows
```

- [`docs/cahier_des_charges_v0.10.md`](docs/cahier_des_charges_v0.10.md) : cahier des charges, qui fait foi.
- [`docs/architecture.md`](docs/architecture.md) : bibliothèques, schéma de la base, synchronisation.
- [`CLAUDE.md`](CLAUDE.md) : état d'avancement, conventions et pièges rencontrés.
- [`docs/diffusion.md`](docs/diffusion.md) : construction des fichiers de diffusion.

Le code, les commentaires et la documentation sont en français ; les noms dans le code sont en anglais.

## Licence

© 2026 Maxence Pithon. Logiciel libre sous licence **GNU GPL version 3 ou ultérieure** ([`LICENSE`](LICENSE)), fourni sans aucune garantie. Éléments de tiers et leurs licences (INAO, Open Food Facts, Tesseract, ZXing, icône…) : [`COPYING.md`](COPYING.md).
