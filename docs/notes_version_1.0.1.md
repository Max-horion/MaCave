Version corrective de **Ma Cave**, après un audit de sécurité de la 1.0.0 sur Android, Windows et Linux. Aucune faille grave n'a été trouvée ; cette version renforce surtout la synchronisation et la lecture des fichiers. Mise à jour conseillée sur tous vos appareils. Votre cave est conservée.

## Quel fichier télécharger ?

| Pour | Fichier |
|---|---|
| Presque tous les téléphones Android (Android 8 ou plus récent) | `MaCave-1.0.1-android.apk` |
| Téléphones anciens (processeur 32 bits), si le précédent refuse de s'installer | `MaCave-1.0.1-android-armv7.apk` |
| Windows 10 ou 11 (64 bits) | `MaCave-1.0.1-windows-setup.exe` |
| Linux 64 bits (Ubuntu 24.04, Linux Mint 22, Debian 13, Fedora 39 ou plus récents) | `MaCave-1.0.1-linux-x86_64.AppImage` |

Mise à jour : installez le nouveau fichier par-dessus l'ancien, sans désinstaller (voir le [guide d'installation](https://github.com/Max-horion/MaCave/blob/main/docs/guide_installation.md), « Mises à jour »).

## Ce qui change

- **Synchronisation chiffrée obligatoire** : l'adresse du serveur doit commencer par `https://`. Une adresse en `http://` n'est plus acceptée que pour un appareil de votre réseau local (un NAS à la maison, par exemple). Si votre appareil utilisait une adresse `http://` sur Internet, la synchronisation affiche une erreur : remplacez l'adresse par celle en `https://` dans **Paramètres → Synchronisation**.
- **Fichiers reçus mieux vérifiés** : cave du serveur et fichier à restaurer (structure et taille contrôlées), fichiers à importer (50 Mo au plus).
- **Export CSV** : une cellule qu'un tableur prendrait pour une formule (commençant par `=`, `+`, `-` ou `@`) est précédée d'une apostrophe. Ces fichiers se réimportent sans changement.
- **Sauvegarde Android du système** : votre cave y figure toujours, mais plus le mot de passe de synchronisation. Sur un nouveau téléphone restauré depuis votre compte Google, réactivez la synchronisation.
- **Liste** : le résumé en haut de l'écran précise « … références en stock » ; les références épuisées n'y sont pas comptées, même quand elles sont affichées.
- Corrections de robustesse de la synchronisation (une date de purge erronée reçue du serveur ne peut plus effacer l'historique).

## Vérifier les fichiers (facultatif)

Empreintes SHA-256 (aussi dans `SHA256SUMS.txt`) :

```
5fe331d1a04d45494e66c951d0041ff237aa310c63016b65636bd2c95d533851  MaCave-1.0.1-android.apk
9c4dd84453a9b1177af829fe4eade45794c9fffad28919f2f67e9ff0ee91be55  MaCave-1.0.1-android-armv7.apk
23d9c0b42cca3d4116825992ef4fbafa1fbde75c97e23b38bebc18d6dd7d4749  MaCave-1.0.1-linux-x86_64.AppImage
0498cc63efde26fcdb04f1ff946f42c2f0fe0b650d6b115d0b5cb6e9ec826f4a  MaCave-1.0.1-windows-setup.exe
```

Les APK sont signés par la clé de Ma Cave, d'empreinte SHA-256 `af941f5159bf226af3c8b2e1c8ca10d0c47b971b2771a4efdbac0cb3391cc3ea`, la même que pour la 1.0.0.

## Un problème, une idée ?

Ouvrez un [ticket](https://github.com/Max-horion/MaCave/issues) ou écrivez à maxence@bouthon.fr (liens aussi dans **Paramètres → À propos**).

Logiciel libre sous licence GNU GPL v3 ou ultérieure, fourni sans aucune garantie.
