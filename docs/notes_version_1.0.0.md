Première version diffusée de **Ma Cave** : gestion d'une cave personnelle (vins, bières, spiritueux, softs) sur téléphone Android et ordinateur Windows ou Linux. Elle fonctionne entièrement hors ligne ; la synchronisation entre appareils par votre serveur Nextcloud ou WebDAV est facultative.

## Quel fichier télécharger ?

| Pour | Fichier |
|---|---|
| Presque tous les téléphones Android (Android 8 ou plus récent) | `MaCave-1.0.0-android.apk` |
| Versions antérieures d'Android, si le précédent refuse de s'installer | `MaCave-1.0.0-android-armv7.apk` |
| Windows 10 ou 11 (64 bits) | `MaCave-1.0.0-windows-setup.exe` |
| Linux 64 bits (Ubuntu 24.04, Linux Mint 22, Debian 13, Fedora 39 ou plus récents) | `MaCave-1.0.0-linux-x86_64.AppImage` |

Pas à pas, avec les avertissements de sécurité expliqués (Play Protect, SmartScreen) : [guide d'installation](https://github.com/Max-horion/MaCave/blob/main/docs/guide_installation.md). Utilisation : [guide d'utilisation](https://github.com/Max-horion/MaCave/blob/main/docs/guide_utilisation.md).

## Contenu

- Références, lots (millésime × volume) et stock, avec l'historique des entrées, sorties et inventaires.
- Recherche, filtres, tris, favoris, fiches « à compléter ».
- Retrait d'une bouteille d'un geste (« −1 »), avec Annuler.
- Sur le téléphone : scan du code-barres et lecture de l'étiquette par photo (sur l'appareil) ; fiche pré-remplie par Open Food Facts (facultatif). Sur ordinateur : saisie du code au clavier ou avec une douchette USB.
- Inventaire guidé, statistiques, import Vivino ou tableur, export CSV.
- Sauvegardes automatiques ; synchronisation entre plusieurs appareils.

## Vérifier les fichiers (facultatif)

Empreintes SHA-256 (aussi dans `SHA256SUMS.txt`) :

```
946c4dd4ee61b16135b214061ebc2741f1a64bd926a06c9ac6cc9d5d753d8fa7  MaCave-1.0.0-android.apk
24cd01d3f76ae38d01c6341b3a51f27848ca29209a4a3b4adb9739cd5e46dfcc  MaCave-1.0.0-android-armv7.apk
ec8ea65ee8b769bd36981e145a06e86408b39b55ffb7c67cc9b004f5719eb382  MaCave-1.0.0-linux-x86_64.AppImage
64a0535eaf0528403cd5bcae233b1ec5bcf1b2f0503770a00ed677826f20cada  MaCave-1.0.0-windows-setup.exe
```

Les APK sont signés par la clé de Ma Cave, d'empreinte SHA-256 `af941f5159bf226af3c8b2e1c8ca10d0c47b971b2771a4efdbac0cb3391cc3ea`. Toutes les mises à jour seront signées par cette même clé.

## Un problème, une idée ?

Ouvrez un [ticket](https://github.com/Max-horion/MaCave/issues) ou écrivez à maxence@bouthon.fr (liens aussi dans **Paramètres → À propos**).

Logiciel libre sous licence GNU GPL v3 ou ultérieure, fourni sans aucune garantie.
