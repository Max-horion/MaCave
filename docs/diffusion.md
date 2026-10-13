# Diffusion — procédures du porteur

Procédures pour publier une version (lot 10 et suivantes). À compléter au fil du lot 10 (paquets PC, publication).

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

### Téléphone du porteur (au moment de la 1.0.0)

Son appli est signée avec la clé de débogage : Android refusera la version signée avec la clé de diffusion (`tool/installer.sh` l'explique, sans rien toucher). Passage, avec l'accord du porteur le moment venu :

1. synchronisation à jour (indicateur « synchronisé ») et sauvegarde récente vérifiée (fichier présent dans `Documents/Cave/Sauvegardes` et sur le serveur) ;
2. désinstallation (efface la base du téléphone) ;
3. installation de l'APK 1.0.0 signé ;
4. accueil → « Synchroniser avec un serveur » → cave reprise du serveur ; vérifier le nombre de bouteilles.
