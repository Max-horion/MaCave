# Diffusion — procédures du porteur

Procédures pour publier une version (lot 10 et suivantes). À compléter au fil du lot 10 (publication).

## 1. Clé de diffusion Android

Android n'accepte une mise à jour que si elle est signée avec **la même clé** que la version installée. Cette clé est donc à garder **toute la vie de l'appli** :

- **perdue** : plus aucune mise à jour possible pour les utilisateurs (ils devraient désinstaller, donc effacer leur cave, puis réinstaller une nouvelle appli) ;
- **volée** (avec son mot de passe) : quelqu'un pourrait diffuser une fausse mise à jour.

### Créer la clé (une seule fois)

Le porteur lance lui-même ces commandes, pour que le mot de passe ne passe que par son clavier. `keytool` est fourni avec Android Studio.

```bash
mkdir -p ~/cles-ma-cave && chmod 700 ~/cles-ma-cave
/snap/android-studio/current/jbr/bin/keytool -genkeypair -v \
  -keystore ~/cles-ma-cave/ma-cave-diffusion.jks -storetype PKCS12 \
  -keyalg RSA -keysize 4096 -validity 10000 -alias ma-cave
```

- Mot de passe : long (une phrase de plusieurs mots), noté dans un gestionnaire de mots de passe. Le format PKCS12 n'a qu'**un seul** mot de passe (fichier et clé).
- Questions (nom, organisation, ville…) : facultatives, sauf le nom (« Maxence Pithon »). Elles sont lisibles par quiconque a l'APK.
- Validité 10 000 jours (27 ans) : Google Play exige au moins jusqu'en 2033.

Puis créer `android/key.properties` d'après `android/key.properties.exemple` (chemin **absolu** du fichier de clé, alias `ma-cave`, le mot de passe deux fois) et le protéger :

```bash
cp android/key.properties.exemple android/key.properties
nano android/key.properties
chmod 600 android/key.properties
git status          # key.properties ne doit PAS apparaître (.gitignore)
```

### Sauvegarder la clé (tout de suite)

Copier `ma-cave-diffusion.jks` **et** le mot de passe en au moins deux endroits sûrs, séparés du PC : clé USB rangée ailleurs, gestionnaire de mots de passe (pièce jointe), dossier chiffré sur le Nextcloud… Ne jamais la mettre dans le dépôt Git, ni sur GitHub, ni l'envoyer par courriel en clair. Vérifier une copie en relisant son empreinte (même résultat que l'original) :

```bash
/snap/android-studio/current/jbr/bin/keytool -list -v -keystore <copie>.jks | grep SHA256
```

### Fonctionnement

- `android/app/build.gradle.kts` lit `android/key.properties` : s'il existe, l'APK de production est signé avec la clé de diffusion ; sinon avec la clé de **débogage**, à ne jamais diffuser (Gradle l'écrit dans son journal, mais `flutter build` ne l'affiche pas : **toujours vérifier la signature** avant de publier).
- `CAVE_SIGNING=debug` force la clé de débogage même si `key.properties` existe (ex. `CAVE_SIGNING=debug tool/installer.sh`, tant que le téléphone du porteur a l'ancienne signature).
- Vérifier la signature d'un APK :

```bash
# apksigner a besoin de Java : celui d'Android Studio
PATH=/snap/android-studio/current/jbr/bin:$PATH \
  ~/Android/Sdk/build-tools/36.0.0/apksigner verify --print-certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

  La clé de débogage affiche `CN=Android Debug` ; la clé de diffusion, le nom donné à sa création.

Vérifié le 2026-10-13 avec une clé d'essai jetable : APK signé avec elle quand `key.properties` existe, avec la clé de débogage sinon.

**Clé de diffusion** créée le 2026-10-13 (`~/cles-ma-cave/ma-cave-diffusion.jks`, alias `ma-cave`, RSA 4096) : certificat `CN=Maxence Pithon`, empreinte SHA-256 `af941f5159bf226af3c8b2e1c8ca10d0c47b971b2771a4efdbac0cb3391cc3ea`. Cette empreinte est publique : elle permet à chacun de vérifier qu'un APK vient bien de Ma Cave (à indiquer avec chaque version publiée).

### Téléphone du porteur (fait le 2026-10-13)

Son appli est signée avec la clé de débogage : Android refusera la version signée avec la clé de diffusion (`tool/installer.sh` l'explique, sans rien toucher). Passage, avec l'accord du porteur le moment venu :

1. synchronisation à jour (indicateur « synchronisé ») et sauvegarde récente vérifiée (fichier présent dans `Documents/Cave/Sauvegardes` et sur le serveur) ;
2. désinstallation (efface la base du téléphone) ;
3. installation de l'APK 1.0.0 signé ;
4. accueil → « Synchroniser avec un serveur » → cave reprise du serveur ; vérifier le nombre de bouteilles.

## 2. Paquets PC

Fichiers produits dans `build/diffusion/` (ignoré par Git), noms fixés par `docs/guide_installation.md`, version lue dans `pubspec.yaml`.

### Linux : AppImage

```bash
tool/paquet_linux.sh             # compile puis construit MaCave-<version>-linux-x86_64.AppImage
tool/paquet_linux.sh --no-build  # reprend la version déjà compilée
```

- Outils téléchargés une fois dans `~/.cache/ma-cave/appimage`, versions figées et vérifiées par SHA-256 : **appimagetool 1.9.1** et le **runtime type 2 du 2025-11-08**. Ce runtime n'a pas besoin de FUSE 2 (`libfuse2`) ; à défaut de FUSE, l'AppImage se lance avec `--appimage-extract-and-run`.
- L'appli utilise les bibliothèques du bureau (GTK 3, libsecret…). Compilée sur Kubuntu 26.04, elle exige **glibc 2.38** : Ubuntu 24.04, Mint 22, Debian 13, Fedora 39 ou plus récents. Le script s'arrête si une mise à jour de Flutter ou du PC fait monter cette exigence au-delà de 2.39 (Ubuntu 24.04). Pour viser plus ancien, il faudrait compiler dans une Ubuntu 22.04 (conteneur), non prévu.
- Contenu : l'appli dans `app/`, lanceur et icône (`linux/packaging/`), description AppStream `linux/packaging/fr.bouthon.cave.metainfo.xml` (lue par Gear Lever ; validée sans réseau par le script, car `appimagetool` vérifie aussi les liens GitHub, introuvables tant que le dépôt est privé).
- Données : les mêmes que l'appli installée par `tool/installer_linux.sh` (`~/.local/share/fr.bouthon.cave`).
- Vérifié le 2026-10-13 (version 0.1.0, 15 Mo) : lancement sur une base d'essai (`XDG_DATA_HOME=<dossier temporaire>`), base et préférences créées.

### Windows : installateur Inno Setup

Sur le PC Windows, avec **Inno Setup 6.3 ou plus récent, 7 compris** (https://jrsoftware.org/isdl.php ; Inno Setup 7, sorti en 2026, reste compatible : aucune des fonctions modifiées n'est utilisée ; le script trouve le dossier « Inno Setup N » le plus récent) :

```powershell
powershell -ExecutionPolicy Bypass -File tool\paquet_windows.ps1            # compile puis construit MaCave-<version>-windows-setup.exe
powershell -ExecutionPolicy Bypass -File tool\paquet_windows.ps1 -NoBuild   # reprend la version déjà compilée
```

- Script : `windows/packaging/MaCave.iss` (UTF-8 avec BOM, CRLF). **`AppId` ne doit jamais changer** : c'est par lui que Windows reconnaît une mise à jour.
- Installation pour l'utilisateur seul, sans droits d'administrateur, dans `%LOCALAPPDATA%\Programs\Ma Cave`, raccourci « Ma Cave » du menu Démarrer (icône du Bureau proposée, décochée) : mêmes emplacements que `tool\installer_windows.ps1`, l'un remplace l'autre. Ferme Ma Cave si elle est ouverte. Désinstallation par Paramètres → Applications ; les données (`%APPDATA%\fr.bouthon\cave`, `Documents\Cave`) ne sont jamais touchées.
- Non signé : SmartScreen avertit (« Informations complémentaires » → « Exécuter quand même »), expliqué dans le guide d'installation.

**Vérifié sur le PC Windows le 2026-10-13** (Inno Setup 7) : construction sans erreur ; installation (pas de demande d'administrateur, raccourci et icône, appli lancée à la fin, cave existante retrouvée) ; nouvelle installation par-dessus (mise à jour, appli ouverte fermée d'abord) ; désinstallation (raccourci et dossier retirés, données conservées) ; réinstallation.

## 3. Dépôt public

Rendre le dépôt public publie **tout l'historique Git** (chaque version de chaque fichier depuis le premier commit), pas seulement l'état actuel.

### Vérification de l'historique (2026-10-13, 89 commits, branche `main` seule)

| Contrôle | Résultat |
|---|---|
| Auteur des commits | `Max-horion`, adresse anonyme GitHub (`…@users.noreply.github.com`) : le courriel personnel n'apparaît pas. |
| Fichiers ayant existé | Aucune base (`.sqlite`, `.db`), sauvegarde, export, clé (`.jks`, `key.properties`), `.env`, ni `docs/cellar.csv`. Seul CSV : `test/fixtures/vivino_cellar.csv` (inventé). |
| Secrets | Aucun mot de passe réel (seulement les faux des tests), jeton GitHub, mot de passe d'application Nextcloud ou clé privée. Adresse du serveur Nextcloud, identifiant et dossier de synchro : absents. |
| Cave du porteur | Chaque nom de vin et de producteur de `docs/cellar.csv` cherché dans tout l'historique : seuls des noms d'**appellations** apparaissent (liste INAO, exemples génériques), aucun château ni producteur. Étiquettes des tests (`test/fixtures/*.hocr`) : noms inventés, sans chemin de fichier. |
| Cahiers des charges `.docx` (6 versions) | Auteur « Maxence Pithon », aucun commentaire, aucune modification suivie, aucun chemin local. |
| Taille | `.git` : 14 Mo ; plus gros fichier : dictionnaire Tesseract (3,8 Mo). |
| Rendu public volontairement | Nom « Maxence Pithon », `maxence@bouthon.fr` (contact), notes de travail (`CLAUDE.md`, `docs/journal.md`, `docs/bilan_v1.md` : modèles des téléphones d'essai, configuration du PC). |

Méthode, à refaire avant toute nouvelle publication si des fichiers sensibles ont pu être ajoutés : `git log --all --name-only` (chemins), `git grep -I -i -E <motif> $(git rev-list --all)` (contenus), noms de `docs/cellar.csv` cherchés un par un (`git grep -F`), `.docx` extraits avec `git cat-file -p` et leurs `docProps/` et `word/comments.xml` relus.

`README.md` réécrit pour le public (présentation, téléchargement, retours, développeurs, licence).

**Dépôt passé en public le 2026-10-13** (accord du porteur ; `gh repo edit --visibility public`), page lisible sans connexion vérifiée. Choix du porteur : publier tel quel, notes de travail comprises (un second dépôt public « nettoyé » a été écarté : deux dépôts à tenir à jour, risque d'oubli).

## 4. Publier une version

1. `pubspec.yaml` : `version: X.Y.Z+N`, N augmenté de 1 à chaque version (1.0.0 = `+2`). Ligne `<release>` dans `linux/packaging/fr.bouthon.cave.metainfo.xml`.
2. Ici : `flutter build apk --release --split-per-abi`, vérifier version, signature (`apksigner`, `CN=Maxence Pithon`) et autorisations (`aapt2 dump permissions`) ; copier `app-arm64-v8a-release.apk` → `build/diffusion/MaCave-X.Y.Z-android.apk` et `app-armeabi-v7a-release.apk` → `…-android-armv7.apk` ; `tool/paquet_linux.sh`.
3. Commit poussé, puis sur le PC Windows : `git pull`, `tool\paquet_windows.ps1`, installation et vérification ; installateur copié dans `build/diffusion/`.
4. `sha256sum MaCave-X.Y.Z-* > SHA256SUMS.txt` ; notes dans `docs/notes_version_X.Y.Z.md` (relues par le porteur).
5. Étiquette annotée `vX.Y.Z` sur le commit compilé, poussée ; `gh release create vX.Y.Z --title "Ma Cave X.Y.Z" --notes-file docs/notes_version_X.Y.Z.md --verify-tag <fichiers>` depuis `build/diffusion/`.
6. Vérifier : fichiers retéléchargés sans connexion et comparés à `SHA256SUMS.txt`.

**1.0.0** publiée le 2026-10-13 : https://github.com/Max-horion/MaCave/releases/tag/v1.0.0 (5 fichiers, retéléchargés et vérifiés).

## 5. Sécurité de la publication (audit du 2026-10-17)

- **Compte GitHub** : la double authentification doit être activée (*Settings › Password and authentication*). Un compte piraté pourrait remplacer les fichiers d'une version **et** leur `SHA256SUMS.txt`, publiés sur la même page.
- **Empreinte du certificat Android** (§1) : à rappeler dans les notes de chaque version ; c'est elle, et non `SHA256SUMS.txt`, qui prouve qu'un APK vient de Ma Cave.
- **Dépendance JitPack** : `android/gradle/verification-metadata.xml` contient les empreintes SHA-256 de Tesseract4Android 4.9.0 ; Gradle refuse de compiler si les fichiers téléchargés diffèrent (« Dependency verification failed »). À la mise à jour de cette bibliothèque : relever les empreintes des nouveaux `.aar`, `.pom` et `.module` sur `https://jitpack.io/cz/adaptech/tesseract4android/…` et les remplacer. Les autres dépendances (Google, Maven Central) ne sont pas vérifiées : elles changent à chaque mise à jour de Flutter.
- **Installateur Windows non signé** : SmartScreen avertit à l'installation. Piste : programme gratuit de signature pour les logiciels libres (SignPath Foundation), qui exige une compilation par GitHub Actions — point à rediscuter (CDC §12).
