# Ma Cave — guide d'installation

Ce guide explique comment installer Ma Cave sur un téléphone Android, un ordinateur Windows ou un ordinateur Linux, puis la mettre à jour. Pour l'utilisation de l'appli, voir le [guide d'utilisation](guide_utilisation.md).

Ma Cave est gratuite, sans compte ni publicité. Elle n'est pas distribuée par le Play Store ni par le Microsoft Store : vous l'installez à partir d'un fichier. Votre téléphone ou votre ordinateur affichera donc des avertissements, expliqués ci-dessous ; ils sont normaux pour une appli installée de cette façon.

## Sommaire

1. [Ce qu'il vous faut](#1-ce-quil-vous-faut)
2. [Où télécharger](#2-où-télécharger)
3. [Android](#3-android)
4. [Windows](#4-windows)
5. [Linux](#5-linux)
6. [Premier lancement](#6-premier-lancement)
7. [Créer un mot de passe d'application Nextcloud](#7-créer-un-mot-de-passe-dapplication-nextcloud)
8. [Mises à jour](#8-mises-à-jour)
9. [Changer d'appareil, désinstaller](#9-changer-dappareil-désinstaller)
10. [Un problème ?](#10-un-problème-)

---

## 1. Ce qu'il vous faut

| Support | Minimum |
|---|---|
| **Téléphone Android** | Android 8 ou plus récent |
| **Ordinateur Windows** | Windows 10 ou 11, 64 bits |
| **Ordinateur Linux** | Distribution 64 bits récente (Ubuntu, Kubuntu, Debian, Fedora, Mint…), avec un bureau graphique |

Pour **synchroniser** votre cave entre plusieurs appareils (facultatif), il faut aussi un serveur **Nextcloud** ou un autre serveur **WebDAV** (NAS, hébergeur) auquel vous avez accès. Sans serveur, l'appli fonctionne très bien sur un seul appareil.

---

## 2. Où télécharger

Les fichiers de chaque version sont publiés sur la page **https://github.com/Max-horion/MaCave/releases** (ou envoyés directement par lien). Prenez la version la plus récente, en haut de la page, rubrique « Assets » :

| Pour | Fichier |
|---|---|
| Presque tous les téléphones Android | `MaCave-1.0.0-android.apk` |
| Vieux téléphones Android (avant 2017 environ), si le précédent refuse de s'installer | `MaCave-1.0.0-android-armv7.apk` |
| Windows | `MaCave-1.0.0-windows-setup.exe` |
| Linux | `MaCave-1.0.0-linux-x86_64.AppImage` |

(Le numéro 1.0.0 change à chaque version.)

---

## 3. Android

### Installer

1. **Téléchargez** `MaCave-1.0.0-android.apk` depuis le téléphone (navigateur), ou copiez-le depuis un ordinateur dans le dossier *Téléchargements* du téléphone.
2. **Ouvrez le fichier** : touchez la notification de fin de téléchargement, ou ouvrez-le depuis l'appli *Fichiers*.
3. Android indique que, pour votre sécurité, l'installation d'applis inconnues est bloquée : touchez **Paramètres**, activez **Autoriser cette source** (pour le navigateur ou l'appli *Fichiers*, selon ce que vous avez utilisé), puis revenez en arrière.
4. Touchez **Installer**.
5. **Play Protect** peut afficher « Appli non sécurisée bloquée » ou « Application inconnue » : touchez **Plus de détails**, puis **Installer quand même**. Ma Cave n'est pas analysée par Google parce qu'elle ne passe pas par le Play Store ; son code source est public.
6. Touchez **Ouvrir**. L'icône « Ma Cave » (une bouteille blanche sur fond bordeaux) est dans la liste de vos applis.

Après l'installation, vous pouvez désactiver à nouveau « Autoriser cette source ».

**« Appli non installée » ou « Problème d'analyse du paquet »** : votre téléphone est peut-être ancien ; essayez `MaCave-1.0.0-android-armv7.apk`.

### Autorisations

L'appli ne demande que ce qui lui sert :
- **Appareil photo** : pour scanner les codes-barres et lire les étiquettes, demandé à la première utilisation ;
- **Stockage** (Android 8 à 10 seulement) : pour écrire les sauvegardes dans *Documents* ;
- **Internet** : pour la synchronisation avec votre serveur et la recherche facultative sur Open Food Facts.

---

## 4. Windows

### Installer

1. **Téléchargez** `MaCave-1.0.0-windows-setup.exe`.
2. **Ouvrez-le.** Windows affiche « Windows a protégé votre ordinateur » (SmartScreen) : cliquez sur **Informations complémentaires**, puis **Exécuter quand même**. Cet avertissement apparaît pour toute appli dont l'éditeur n'a pas acheté de certificat de signature ; il ne signale pas un danger.
3. Suivez l'installateur. Il installe Ma Cave **pour votre compte uniquement**, sans droits d'administrateur.
4. Ma Cave est ensuite dans le **menu Démarrer**.

Votre antivirus peut aussi demander une confirmation la première fois : autorisez Ma Cave.

### Où sont vos données ?

- La cave : `%APPDATA%\fr.bouthon\cave` (collez ce chemin dans la barre d'adresse de l'Explorateur).
- Les sauvegardes : `Documents\Cave\Sauvegardes`.

---

## 5. Linux

L'appli est fournie en **AppImage** : un seul fichier qui fonctionne sur la plupart des distributions, sans installation.

### Lancer

1. **Téléchargez** `MaCave-1.0.0-linux-x86_64.AppImage`, et rangez-le où vous voulez (par exemple dans un dossier `Applications` de votre dossier personnel).
2. **Rendez-le exécutable** : clic droit sur le fichier → **Propriétés** → **Permissions** → cochez **Est exécutable** (ou « Autoriser l'exécution du fichier comme un programme »). En ligne de commande :
   ```
   chmod +x MaCave-1.0.0-linux-x86_64.AppImage
   ```
3. **Double-cliquez** dessus.

**Rien ne se passe, ou un message parle de « FUSE »** : certaines distributions récentes n'installent plus FUSE 2, dont les AppImage ont besoin. Sur Ubuntu 24.04 et suivantes (et leurs dérivées) :
```
sudo apt install libfuse2t64
```
Sur les versions plus anciennes d'Ubuntu ou Debian : `sudo apt install libfuse2`.

### Ajouter Ma Cave au menu des applications (facultatif)

Une AppImage ne s'ajoute pas seule au menu. Le plus simple : installer **Gear Lever** (logithèque de votre distribution, ou Flathub) ou **AppImageLauncher**, qui proposent d'intégrer l'appli au menu à son premier lancement.

### Synchronisation sous Linux

Le mot de passe de votre serveur est rangé dans le **trousseau** de votre session (KWallet sous KDE, GNOME Keyring sous GNOME), présent sur la plupart des bureaux. Si l'appli indique que « le mot de passe ne peut pas être rangé dans le coffre sécurisé de l'appareil », installez ou déverrouillez ce trousseau.

### Où sont vos données ?

- La cave : `~/.local/share/fr.bouthon.cave`.
- Les sauvegardes : `~/Documents/Cave/Sauvegardes`.

---

## 6. Premier lancement

Au premier démarrage, l'appli vous pose trois questions ; chacune peut être passée.

1. **Où ranger votre cave ?**
   - **Sur cet appareil uniquement** : rien à configurer. Pensez à copier de temps en temps le dossier des sauvegardes ailleurs (clé USB, autre ordinateur).
   - **Synchroniser avec un serveur** : il vous faut l'adresse de votre serveur, votre identifiant et un **mot de passe d'application** (voir [section 7](#7-créer-un-mot-de-passe-dapplication-nextcloud)). Si votre cave est déjà sur le serveur (deuxième appareil), elle est récupérée et l'appli est prête.
2. **Vous avez déjà une cave ?** : import d'un export Vivino ou d'un fichier préparé dans un tableur.
3. **Volumes par défaut** : le volume proposé pour une nouvelle bouteille selon son type.

Tout se change plus tard dans **⋮ → Paramètres**.

---

## 7. Créer un mot de passe d'application Nextcloud

Ma Cave ne vous demande jamais votre mot de passe Nextcloud principal, mais un **mot de passe d'application** : un mot de passe dédié, que vous pouvez révoquer à tout moment sans changer le vôtre.

1. Ouvrez Nextcloud dans un navigateur et connectez-vous.
2. Cliquez sur votre avatar (en haut à droite) → **Paramètres personnels** → **Sécurité**.
3. En bas, rubrique « Appareils et sessions » : tapez un nom (par exemple « Ma Cave – téléphone ») puis **Créer un nouveau mot de passe d'application**.
4. Copiez le mot de passe affiché : il ne sera plus montré ensuite.

Dans Ma Cave (**Synchroniser avec un serveur**, ou **⋮ → Paramètres → Synchronisation**) :
- choisissez **Nextcloud** ;
- **Adresse du serveur** : celle de votre Nextcloud, par exemple `cloud.exemple.fr` ;
- **Identifiant** : votre identifiant Nextcloud ;
- **Mot de passe d'application** : celui que vous venez de copier ;
- **Dossier sur le serveur** : `Cave` par défaut ; il est créé s'il n'existe pas ; changez-le à votre convenance ;
- **Activer la synchronisation**.

**Sur chacun de vos appareils, utilisez le même serveur et le même dossier.** Vous pouvez créer un mot de passe d'application par appareil : si vous perdez votre téléphone, vous révoquez le sien sans toucher aux autres.

Si vous synchronisez aussi vos fichiers Nextcloud sur votre ordinateur avec le client Nextcloud, ne touchez pas au dossier `Cave` ainsi copié (ou excluez-le de la synchronisation) : c'est Ma Cave qui gère ce dossier.

**Autre serveur WebDAV** (NAS, hébergeur) : choisissez **Autre serveur WebDAV** et indiquez l'**adresse complète du dossier**, fournie par votre NAS ou votre hébergeur (par exemple `https://nas.exemple.fr/webdav/cave`).

---

## 8. Mises à jour

Une nouvelle version vous sera signalée directement (l'appli ne vérifie pas elle-même les mises à jour). Téléchargez les nouveaux fichiers depuis la même page, puis :

| Support | Mise à jour | Vos données |
|---|---|---|
| **Android** | Ouvrez le nouvel APK et touchez **Mettre à jour**. **Ne désinstallez pas l'ancienne version avant** : désinstaller efface la cave du téléphone. | Conservées |
| **Windows** | Lancez le nouvel installateur : il remplace l'ancienne version. | Conservées |
| **Linux** | Remplacez l'ancien fichier AppImage par le nouveau (et rendez-le exécutable). | Conservées |

**Avec la synchronisation, mettez à jour tous vos appareils** quand une nouvelle version sort. Si un appareil a une version plus ancienne que la cave du serveur, il suspend sa synchronisation (sans rien abîmer) et vous invite à le mettre à jour.

---

## 9. Changer d'appareil, désinstaller

**Changer d'appareil**
- **Avec la synchronisation** : installez l'appli sur le nouvel appareil, choisissez **Synchroniser avec un serveur** avec les mêmes paramètres : votre cave est récupérée.
- **Sans synchronisation** : copiez une sauvegarde (le fichier `.sqlite` le plus récent du dossier `Documents/Cave/Sauvegardes`) sur le nouvel appareil, puis **⋮ → Paramètres → Sauvegardes → Restaurer depuis un fichier…**.

**Désinstaller**
- **Android** : appui long sur l'icône → **Désinstaller**. ⚠️ La cave du téléphone est effacée ; les sauvegardes du dossier *Documents/Cave* restent.
- **Windows** : **Paramètres → Applications → Ma Cave → Désinstaller**. La cave (`%APPDATA%\fr.bouthon\cave`) et les sauvegardes restent sur l'ordinateur.
- **Linux** : supprimez le fichier AppImage. La cave (`~/.local/share/fr.bouthon.cave`) et les sauvegardes restent.

---

## 10. Un problème ?

Écrivez-moi à **maxence@bouthon.fr**, ou ouvrez un ticket sur **https://github.com/Max-horion/MaCave/issues**. Précisez votre appareil et son système, la version de l'appli (**⋮ → Paramètres → À propos**), ce que vous avez fait et ce qui s'est passé ; une capture d'écran aide beaucoup. N'envoyez jamais de mot de passe.
