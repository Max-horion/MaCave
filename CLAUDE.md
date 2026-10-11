# Ma Cave — notes pour reprendre le projet

Application Android (Flutter) de gestion d'une cave personnelle : références (boissons), lots (millésime × volume) qui portent le stock, mouvements (entrées, sorties, inventaires). Fonctionne entièrement hors ligne ; synchronisation facultative avec un serveur WebDAV (Nextcloud).

## Documents de référence

- `docs/cahier_des_charges_v0.9.md` — **cahier des charges** (CDC), converti de `cahier_des_charges_gestion_cave_v0.9.docx` (source officielle ; les .docx v0.4 à v0.8 sont conservés pour l'historique). Toute décision qui modifie le CDC : nouvelle version du .docx (historique + journal des décisions), puis report dans le Markdown. Méthode des v0.6 à v0.9 (pas de pandoc ni de python-docx sur le PC) : .docx décompressé, `word/document.xml` modifié par un script Python (remplacements de texte, lignes de tableau dupliquées), titre dans `docProps/core.xml` et version dans `word/footer1.xml`, recompressé, rendu vérifié avec `soffice --convert-to pdf` ; mêmes modifications appliquées au Markdown (renommé à la nouvelle version avec `git mv`). Piège : ne remplacer que des phrases contenues dans un seul `<w:t>` (le vérifier par un comptage avant de remplacer). En cas de doute fonctionnel, c'est le CDC qui fait foi ; citer la section (ex. « CDC §6.3 »).
- `docs/architecture.md` — bibliothèques, schéma de la base, principe de synchronisation.
- `docs/bilan_v1.md` — bilan de la V1 (2026-10-08) : critères de réussite, fonctions, exigences non fonctionnelles, limites, décisions à venir.
- Ce fichier — état d'avancement et conventions. **À mettre à jour à la fin de chaque lot.**

## Le porteur du projet

Débutant (un peu de Python, découvre Flutter/Dart). Communiquer en français, tutoiement. Expliquer brièvement chaque étape. **Demander l'accord avant toute commande `sudo` ou action difficile à annuler** (suppression, push forcé, publication, modification du dépôt GitHub…). Il lance lui-même les commandes `sudo`.

## Environnement de développement

- PC Kubuntu 26.04, **8 Go de RAM** : fermer Android Studio pendant les compilations. Gradle est volontairement limité dans `android/gradle.properties` (1,5 Go, 2 workers, Kotlin dans le même processus) — ne pas remonter ces valeurs.
- Flutter stable dans `~/development/flutter` (dans le PATH via `~/.bashrc`). Ne jamais proposer `snap install flutter`.
- Téléphone de test : OnePlus 13 (CPH2653), Android 16, en USB (`adb` : `~/Android/Sdk/platform-tools/adb`).
- Dépôt : https://github.com/Max-horion/MaCave (privé), branche `main`.

```bash
flutter pub get                      # dépendances
flutter gen-l10n                     # régénère les traductions (aussi fait automatiquement au build)
dart run build_runner build          # code généré de drift (~1 min, ~800 Mo de RAM)
dart run drift_dev make-migrations   # après tout changement de schéma : photo + tests de migration
flutter analyze                      # analyse statique : doit afficher « No issues found »
flutter test                         # tests automatiques
tool/installer.sh                    # compile et installe sur le téléphone EN GARDANT LES DONNÉES
flutter run -d linux                 # lance l'appli PC (vraie base : ~/.local/share/fr.bouthon.cave/)
flutter build linux --debug          # appli PC seule (build/linux/x64/debug/bundle/cave), ~40 s
flutter build apk --release --split-per-abi   # APK seuls, un par architecture (installation : tool/installer.sh --no-build, prend l'arm64)
```

> ⚠️ **Ne jamais utiliser `flutter install`** sur le téléphone du porteur : il désinstalle l'appli avant de la réinstaller, ce qui **efface sa base**. Utiliser `tool/installer.sh` (`adb install -r`, mise à jour sur place, avec vérification). `flutter run` est acceptable (il ne désinstalle qu'en cas de conflit de signature), mais l'éviter quand le téléphone contient des données réelles. La sauvegarde Android est désactivée sur ce téléphone : rien ne permet de récupérer une base effacée avant le lot 4.

## Choix techniques (détails dans docs/architecture.md)

- Flutter / Dart, Android en V1 (min. Android 8 = API 26), PC Windows/Linux plus tard avec le même code.
- Identifiant Android `fr.bouthon.cave`, nom affiché « Ma Cave ».
- Base SQLite locale via drift ; état de l'interface via Riverpod.
- Synchro WebDAV maison (sur `http`) : mouvements identifiés par UUID et additionnés, fiches « la plus récente l'emporte », envoi conditionnel par ETag (`If-Match`) pour ne jamais écraser.
- Reconnaissance de texte interchangeable : Tesseract (ML Kit essayé en parallèle pendant la bêta, retiré le 2026-10-10). Codes-barres : ZXing.
- Budget nul. Licence prévue : GPL v3 ou ultérieure, sans exception (ML Kit retiré). Dépôt GitHub privé en V1.

## Plan en lots

| Lot | Contenu | État |
|---|---|---|
| 0 | Squelette : projet, traductions FR, thèmes clair/sombre, premier test, CLAUDE.md, architecture, Git/GitHub, installation sur le téléphone | **terminé** |
| 1 | Base de données et stock : schéma drift, classification initiale, références, lots, mouvements, calcul du stock (tests) | **terminé** |
| 2 | Liste, recherche plein texte (FTS5, migration de schéma v1 → v2), filtres/tris, fiche référence et lots, ajout, sortie rapide « −1 » avec annulation | **terminé** |
| 3 | Inventaire guidé, statistiques, import Vivino, import/export CSV, historique sur la fiche | **terminé** |
| 4 | Synchronisation WebDAV, traitement des erreurs, sauvegardes automatiques, purge — en 5 étapes : 4a sauvegardes, 4b moteur de fusion, 4c client WebDAV + cycle de synchro, 4d écran Synchronisation + indicateur, 4e purge | **terminé** |
| 5 | Scan code-barres (+ Open Food Facts), reconnaissance de texte (ML Kit / Tesseract), lampe torche, doublons — en 5 étapes, dans cet ordre : 5a scan + lampe, 5b Open Food Facts, 5e doublons, 5c photo d'étiquette + ML Kit, 5d Tesseract + comparaison | **terminé** |
| 6 | Premier lancement (3 étapes), écran des paramètres, finitions | **terminé** (Android 10 vérifié le 2026-10-10) |
| 7 | Lecteur de codes-barres sans ML Kit (bibliothèque libre, piste ZXing), à essayer et approuver par le porteur — **condition pour terminer la V1** (décision du 2026-10-08). Prévu le 2026-10-09 : le porteur testera les deux alternatives libres (Tesseract pour le texte, ce lecteur pour les codes-barres) pendant la saisie de sa cave ; si elles sont validées, on clôt la V1 en appliquant le choix définitif (retrait de ML Kit, exception de `COPYING.md`, CDC) | **terminé** (2026-10-10) : ML Kit retiré, ZXing + Tesseract seuls, vérifiés sur le téléphone, CDC v0.7 |
| 8 | **V2 — portage PC Linux**, en 5 étapes : 8a socle (dossier `linux/`, base dans le dossier des applis, fenêtre, CDC v0.9), 8b fonctions sans caméra ni partage sur PC, 8c écrans adaptés à la largeur + clavier/souris, 8d synchro et trousseau, 8e essai réel téléphone + PC et livraison. Windows ensuite | **en cours** : 8a, 8b et 8c terminées (2026-10-11) |

**Décisions du porteur** (toutes reportées dans le CDC v0.6) :
- une fiche incomplète est enregistrée avec le marqueur « à compléter », jamais refusée (2026-10-05) ;
- l'appellation est **facultative** pour le vin ; la région *ou* le pays restent obligatoires (2026-10-05).
- **Pas de tâches de fond en V1** (2026-10-05) : sauvegarde et synchro se font appli ouverte (ouverture, mise en arrière-plan, après modification, bouton) ; pas de workmanager ni de notification « erreur > 24 h » (affichée dans l'appli à la place). Écart au CDC §8.3/§8.4 à reporter dans sa prochaine version.
- Sauvegardes : **3 conservées par défaut**, nombre réglable sur l'écran Sauvegardes (2026-10-05).
- En mode synchronisé, sauvegardes **sur le téléphone ET sur le serveur** (dossier `Sauvegardes` à côté de la cave, même nombre conservé) (2026-10-06). Le CDC §8.4 ne prévoyait que le serveur : écart à reporter.
- Doublons (5e) faits **avant** la reconnaissance de texte, et utilisés aussi dans la fiche « Code inconnu » quand Open Food Facts trouve le produit (« Déjà dans votre cave ? ») et, au 5c, pour le nom lu sur l'étiquette (2026-10-06, idée du porteur).
- Synchronisation automatique : **activée par défaut**, interrupteur gardé dans l'écran Synchronisation pour pouvoir la couper (CDC §7) (2026-10-07).
- Le marqueur « à compléter » est calculé à l'enregistrement de chaque fiche. **Ne jamais le recalculer en masse** silencieusement : le porteur s'en sert comme liste de fiches à revoir (ex. après un import).

Les fonctions marquées V2 dans le CDC (emplacements, dates de consommation, photos, PDF, appli PC) ne sont pas développées en V1, mais le schéma de la base les prévoit.

## À reprendre (prochaine séance)

**La V1 est terminée** (2026-10-10, décision du porteur) et son **usage réel aussi** (2026-10-11 : cave entièrement saisie, stock vérifié à la main). Bilan : `docs/bilan_v1.md`. Appli entièrement libre (Tesseract, ZXing), APK arm64 36,1 Mo.

**En cours : lot 8, portage Linux** (CDC v0.9). Prochaine étape : **8d** — synchronisation sur PC avec le Nextcloud du porteur (même serveur, utilisateur et dossier que le téléphone ; cave neuve → reprise de celle du serveur), mot de passe dans KWallet par libsecret, message clair si aucun trousseau n'est disponible. Vérifier aussi `connectivity_plus` (réseau détecté par NetworkManager) et le dossier des sauvegardes (`~/Documents/Cave/Sauvegardes`, choix d'un autre dossier par le portail XDG).

Suite possible, **à décider avec le porteur** :
1. Usage réel : fin de la saisie de la cave, inventaire, synchro avec un deuxième appareil ; corriger ce qui en ressortira.
2. Diffusion : choisir le canal (dépôt public + APK, F-Droid, Play Store) ; avant cela, mesurer les performances sur un vieux téléphone (`tool/perf/cave_perf_test.dart` ne mesure que le PC) et passer le dépôt en public (accord du porteur).
3. V2 (CDC §11) : emplacements, période de consommation, accords mets et vins, statistiques dans le temps, photos d'étiquette, export PDF, appli PC.
4. Plus tard : noms en arc de cercle (redresser l'image avant Tesseract), optimisation de la lecture des étiquettes courbes.

**Plan de démarrage de la V2** (accord du porteur 2026-10-10, lancé le 2026-10-11 : lot 8) : **portage PC avant toute nouvelle fonction**, pour que chaque fonction de la V2 soit conçue une seule fois pour les deux plateformes. Après la fin de l'usage réel de la V1 (point 1), pour ne pas mêler corrections et portage.
- Ordre : **Linux d'abord** (compilé sur ce PC), puis **Windows** (Flutter ne compile pas pour Windows depuis Linux : PC Windows avec Visual Studio Community, ou GitHub Actions).
- Ce qui passe par `MainActivity.kt` n'existe pas sur PC : Tesseract, ZXing, autorisation de stockage. Proposition : scan et photo **désactivés sur PC** au début (saisie du code à la main ; une douchette USB se comporte comme un clavier). Décision à reporter dans le CDC (§10).
- Process d'ajout d'une fonction une fois les deux versions faites : CDC (préciser les plateformes concernées) → logique commune dans `lib/domain` / `lib/data` + tests → un seul écran, adapté **à la largeur de la fenêtre** et non au système → partie propre à une plateforme derrière une interface Dart (comme `LabelRecognizer`, `StorageAccess`) → `flutter analyze` + `flutter test` une fois → essai sur le téléphone **et** sur le PC → livraison des deux. Une seule base pour les deux : après une migration de schéma, **mettre à jour les deux applis ensemble** (la synchro refuse une base plus récente que l'appli).

## Où trouver quoi (lot 1)

- `lib/domain/` — logique pure : `enums.dart` (valeurs stockées en base, ne jamais renommer), `stock.dart` (calcul du stock), `field_rules.dart` (champs par type, marqueur « à compléter »), `initial_classification.dart` (CDC §6.1).
- `lib/data/` — `tables.dart` (schéma), `database.dart` (création, classification initiale à identifiants fixes UUID v5, `cave_id`), `cave_repository.dart` (**seule porte d'entrée** vers les données : références, lots, mouvements, stock), `providers.dart` (Riverpod), `write_context.dart` (appareil, horloge, UUID v7).
- `drift_schemas/` — photos du schéma par version (générées, à commiter).
- `test/helpers.dart` — base en mémoire et `TestContext` (horloge et identifiants prévisibles).

Règles du dépôt : chaque mouvement recalcule le stock en cache dans la même transaction ; on ne retire jamais plus que le stock ; les suppressions sont logiques ; le cache `stock` ne modifie pas `updatedAt`.

## Où trouver quoi (lot 2)

- `lib/data/search.drift` — index plein texte FTS5 (schéma v4 : champs de la fiche + nom du type + caractéristiques + millésimes des lots). La vue `drink_search_rows` calcule la ligne d'index ; déclencheurs et `CaveDatabase.rebuildSearchIndex()` l'utilisent tous. Pour indexer une info de plus : vue + colonne FTS + déclencheur de la table source + étape de migration qui recrée l'index (`_dropSearchIndex`, `_createSearchTriggers`).
- Migrations : `onUpgrade: stepByStep(...)` dans `database.dart`, aidé par `database.steps.dart` (généré par `make-migrations`). Une étape par version.
- `lib/data/cave_queries.dart` — lectures « en direct » : liste filtrée (`watchDrinkList`), classification, fiche, lots, régions.
- `lib/domain/drink_filter.dart` (filtres, tris, `ftsQuery`), `lib/domain/text.dart` (`fold` : tri sans accents).
- `lib/features/cellar/` (liste, filtres), `lib/features/drink/` (fiche, formulaire), `lib/features/stock_actions.dart` (−1, ajout, retrait avec motif, correction, nouveau lot, bandeau Annuler).
- `lib/ui/` — `formats.dart` (volumes, dates, nombres selon la langue), `widgets.dart` (sélecteur de quantité, étoiles, message vide).
- `test/drift/cave/` — tests de migration générés par `make-migrations` + test de conservation des données v1 → v2.

Pièges rencontrés :
- `SnackBar` avec action : préciser `persist: false`, sinon il ne disparaît jamais (Flutter ≥ 3.3x).
- Formulaires : `SingleChildScrollView` + `Column`, pas `ListView` — une ListView ne construit pas les champs hors écran et `Form.validate()` les ignore.
- Recherche : le porteur s'attend à trouver par tout ce qu'il voit (type, caractéristiques, millésime) → tout cela est dans l'index ; les pluriels en s/x sont ramenés au singulier (`ftsQuery`).
- Tests d'interface avec drift : écrire en base dans `tester.runAsync`, attendre avec le helper `settle` ; un test en échec peut bloquer le lanceur jusqu'au délai (`--timeout 60s`).

## Où trouver quoi (lot 3)

- `lib/domain/csv.dart` — lecture/écriture CSV maison (séparateur deviné, guillemets, marque UTF-8 pour Excel), `CsvTable` (colonnes retrouvées par nom, sans casse ni accents).
- `lib/domain/vivino.dart` — interprétation de l'export Vivino (nom/appellation, pays, type → caractéristique).
- `lib/data/exchange/exchange_format.dart` — **le format des fichiers** (noms de colonnes, valeurs « entrée/sortie/inventaire », « consommée/offerte/cassée ») : ne pas traduire, ne pas renommer (les sauvegardes existantes doivent rester relisibles).
- `lib/data/exchange/csv_export.dart`, `cave_import.dart` — export ; import avec détection du type de fichier, aperçu par transaction annulée (`preview`) puis `apply`.
- `lib/features/exchange/`, `inventory/`, `stats/` — écrans ; menu « ⋮ » dans `cellar_screen.dart`.

Règles d'import :
- **Stock** (sauvegarde ou tableur) : références/lots retrouvés par ID, sinon par nom + producteur + type / millésime + volume, sinon créés (avec l'ID du fichier s'il est libre). Le stock est fixé par un ajustement d'inventaire. Les fiches existantes ne sont pas modifiées.
- **Historique** : mouvements ajoutés avec leur date d'origine s'ils sont inconnus (par ID) et si leur lot existe.
- **Vivino** : un lot déjà présent avant l'import est ignoré → réimporter ne double pas le stock. Note communautaire et lien Vivino non importés.
- Restauration complète = importer le fichier de stock, puis celui d'historique.

## Où trouver quoi (lot 4)

- `lib/sync/cave_file.dart` — opérations sur un fichier de base entier, réutilisées par la synchro : `inspectCaveFile` (intégrité, version ≤ actuelle, `cave_id` ; lève `CaveFileException`), `snapshotDatabase` (`VACUUM INTO`), `migratedCopy` (met une copie au schéma actuel avec les migrations drift), `replaceDatabaseContents` (`ATTACH` + remplacement en une transaction, `meta` comprise).
- `lib/sync/backup.dart` — `BackupService` : sauvegarde = `cave_<date>.sqlite` + `_stock.csv` + `_historique.csv` (**noms = format, ne pas changer**), `backupIfDue` (au plus 1 par jour, seulement si l'« empreinte » de la base a changé, jamais d'exception), `restore` (copie mise à niveau d'abord, puis sauvegarde de sécurité, puis remplacement).
- `lib/sync/merge.dart` — **moteur de fusion** (4b) : `mergeCaveFile(db, ctx, chemin)` fusionne un fichier de la même cave (vérifié + `migratedCopy` d'abord) en une transaction, via `ATTACH` + `INSERT … ON CONFLICT DO UPDATE … WHERE <gagnant>`. Fiches et réglages : le plus récent gagne (`updated_at`, puis `updated_by`). Mouvements : ajoutés s'ils sont inconnus ; seule une annulation peut modifier un mouvement connu, et elle l'emporte toujours (indépendant des horloges). Lots en double regroupés sur le plus ancien (`created_at`, `id`), choix identique sur tous les appareils. `MergeResult.localAhead` = il faut renvoyer la base au serveur. `OtherCaveException` si le `cave_id` diffère.
- `lib/sync/webdav.dart` — client WebDAV maison sur `http` (4c) : `download` (avec `If-None-Match` → 304), `upload` (`If-Match`, ou `If-None-Match: *` au premier envoi), `etag` (PROPFIND), `move`, `createFolder`. Erreurs → `WebDavProblem` (injoignable, identifiants, 412, introuvable, espace plein, serveur).
- `lib/sync/sync_service.dart` — **cycle de synchro** (4c) : `sync()` (architecture §4 : GET conditionnel → vérification → `mergeCaveFile` → PUT conditionnel, 3 essais si 412), `useServerCave` / `replaceServerCave` (CDC §8.2), `forget()` (changement de serveur). Erreurs → `SyncException(SyncProblem…)`, une par message du CDC §8.3. Préférences locales : `sync_etag` (ETag connu) et `sync_fingerprint` (empreinte de la base quand elle était identique au serveur : sert à savoir s'il faut envoyer après un 304). **Pas encore branché dans l'appli** (4d : réglages, mot de passe, déclencheurs, indicateur).
- `contentFingerprint` (`cave_file.dart`) — empreinte partagée par sauvegarde et synchro : **somme** des `updated_at` + nombre de lignes (pas le maximum : une modification datée par une horloge en retard ne le ferait pas bouger).
- `lib/data/history_purge.dart` — **purges** (4e) : `purgeBefore(date)` (manuelle) = report de stock (inventaire à la date, ID UUID v5 `purge/<lot>/<date>` identique sur tous les appareils) puis **suppression physique** des mouvements antérieurs, date enregistrée dans `settings` (`history_purged_before`, ne recule jamais). La fusion prend la plus récente des deux dates, n'importe jamais de mouvement antérieur et applique la purge reçue (`applyPurge`) ; l'import d'historique les ignore aussi. `autoPurge` (réglage synchronisé `auto_purge`, désactivé par défaut) : lots à stock 0 sans mouvement depuis N mois → suppression logique du lot, de ses mouvements et de la référence sans autre lot ; lancée à l'ouverture après la sauvegarde, une fois par jour.
- `lib/features/storage/storage_screen.dart` — écran « Espace disque » (Paramètres) : taille, purge manuelle (date ≤ aujourd'hui − 30 jours, sauvegarde puis `VACUUM`), purge automatique.
- `lib/sync/sync_settings.dart` — paramètres de synchro propres à l'appareil (`SyncSettings` : Nextcloud = adresse du serveur → `…/remote.php/dav/files/<user>/<dossier>/`, ou adresse WebDAV complète), mot de passe dans le coffre (`SecureSecretStore`, `MemorySecretStore` pour les tests), `SyncSettingsStore`.
- `lib/sync/sync_controller.dart` — `SyncController` (Riverpod) : état affiché (`SyncState` : off, synced, syncing, waiting, error + cause, `errorSince` → rouge après 24 h), `start` (ouverture), `localChanged` (regroupe 10 s), `paused`, `syncNow`, nouvelles tentatives 1, 5, 30 min (pas pour identifiants/dossier/version/autre cave), journal des 20 dernières erreurs, `activate` (paramètres enregistrés seulement si ça marche) puis `resolveOtherCave`, `deactivate`. Dépendances regroupées dans `SyncEnvironment` (`syncEnvironmentProvider`, remplacé dans les tests par `localSyncEnvironment` de `test/helpers.dart`).
- `lib/sync/server_backups.dart` — `mirrorLatestBackup` : copie la dernière sauvegarde locale dans `Sauvegardes/` du serveur et n'y garde que les N plus récentes (règle commune à tous les appareils). Appelé après chaque synchro réussie.
- `AutomaticTasks` (`lib/sync/providers.dart`, ex-`AutoBackup`) : synchro à l'ouverture (puis sauvegarde), au retour au premier plan, après modification ; sauvegarde + synchro en attente à la mise en arrière-plan.
- `lib/features/sync/` — écran Synchronisation (formulaire, choix « autre cave », état, journal, désactivation), indicateur `SyncIndicator` dans la barre de la liste (invisible en mode local), textes communs `sync_messages.dart`.
- `test/sync/fake_webdav_server.dart` — faux serveur WebDAV (vrai serveur HTTP local, règles d'ETag de Nextcloud) ; `test/sync/device.dart` — appareils simulés (base + horloge + ID préfixés).
- `lib/sync/providers.dart` — dossier `Documents/Cave/Sauvegardes` (Android 11+ : écriture sans autorisation, vérifié sur le téléphone ; l'appli ne voit plus ses fichiers après une réinstallation → « Restaurer depuis un fichier »), widget `AutoBackup` (dans `main.dart`).
- `lib/data/local_store.dart` — préférences propres à l'appareil (`PrefsLocalStore`, `MemoryLocalStore` pour les tests).
- `lib/features/backup/backup_screen.dart` — écran Sauvegardes (Paramètres).

Pièges rencontrés :
- Tests d'interface avec de vraies écritures de fichiers : faire le `tap` dans `tester.runAsync`, sinon l'action ne progresse pas.
- Ne jamais lire un fichier (taille…) pendant `build` : il peut avoir été supprimé (plantage trouvé par un test).
- Fusion : un appareil resté hors ligne longtemps qui ajoute un mouvement sur un lot entre-temps regroupé (doublon supprimé) le verra arriver sur le lot supprimé, donc non compté. Cas très rare (3 appareils hors ligne) ; à revoir si ça arrive.
- Fusion : les ID des appareils de test doivent être distincts (`_DeviceContext` dans `test/sync/merge_test.dart`), sinon les `id-0001` se croisent.
- Faux serveur HTTP : fixer `statusCode` **avant** d'écrire le contenu (sinon « Header already sent » et les tests se bloquent).
- Tests d'écran qui font du vrai réseau : `HttpOverrides.global = null` dans `setUp` (Flutter remplace sinon toutes les requêtes par des réponses « 400 »).
- `StreamController` simple jamais écouté : `close()` ne se termine jamais (test bloqué) → `.broadcast()`.
- `AndroidManifest.xml` principal : l'autorisation INTERNET n'est ajoutée par Flutter qu'en débogage ; elle est déclarée à la main (vérifiable avec `aapt2 dump permissions`).
- Ne pas lancer `pkill -f flutter_tester` dans une commande qui contient ce mot : elle se tue elle-même.
- Purge manuelle : un mouvement fait hors ligne sur un autre appareil, **daté d'avant la purge** et pas encore synchronisé, serait ignoré (le report de stock ne le connaît pas). D'où la date limite à aujourd'hui − 30 jours (choix technique, `StorageScreen.minimumAge`).
- Purge automatique : un lot purgé ici puis réapprovisionné hors ligne sur un autre appareil avant la synchro resterait supprimé (mouvement rattaché à un lot supprimé). Cas rare, non traité.
- Tests d'écran d'un déroulé qui lit la base puis ouvre une fenêtre : faire chaque `tap` dans `tester.runAsync` puis `settle`, sinon la fenêtre n'apparaît jamais.
- Écran en `ListView` dans un test : les éléments hors écran ne sont pas construits → `scrollUntilVisible`, puis `pumpAndSettle` après `ensureVisible` avant de toucher.
- APK : **seul l'APK arm64 est installé** (`tool/installer.sh` : `--split-per-abi`, puis `app-arm64-v8a-release.apk`, décision du porteur du 2026-10-06). L'APK universel pesait 141 Mo avec ML Kit (code natif par architecture) ; arm64 seul : 36,1 Mo sans ML Kit. `--target-platform` seul ne suffit pas : il ne filtre pas le code natif des bibliothèques. ⚠️ L'APK arm64 a un numéro de version plus élevé (versionCode + 2000) que l'APK universel : **ne plus réinstaller l'APK universel** sur ce téléphone (Android le refuserait comme un retour en arrière, et le contourner par une désinstallation effacerait la base).
- Deux bibliothèques utilisent la caméra (au lot 5 : `mobile_scanner` pour le scan, `camera` pour la photo ; depuis le lot 7 le scan ZXing utilise aussi `camera`, mais la règle reste) : **arrêter le lecteur (`controller.stop()`) avant de fermer l'écran de scan**, sinon la caméra n'est libérée qu'après l'animation et l'écran photo ouvert aussitôt reste figé (bug trouvé par le porteur). L'écran photo réessaie aussi une fois au démarrage.
- La caméra n'existe pas en test : tester `handleScannedCode` directement (`test/scan_flow_test.dart`).
- Android 8 à 10 : l'écriture dans Documents demandera une autorisation (pas encore gérée ; à voir au lot 6 avant toute diffusion).

## Où trouver quoi (lot 5)

- `lib/domain/barcode.dart` — `normalizeBarcode` : forme enregistrée d'un code (UPC-A 12 chiffres → EAN-13 avec un 0 devant, espaces/tirets retirés ; QR code gardé tel quel). Appliquée par `findOrCreateLot`, `lotsByBarcode`, `setLotBarcode` (dépôt).
- `lib/features/scan/scan_screen.dart` — écran de scan (ZXing, voir lot 7 ; fonctionne sans réseau), lampe torche, saisie du code à la main ; retourne le code lu.
- `lib/features/scan/scan_flow.dart` — `startScan` / `handleScannedCode` : code connu → lots avec « −1 » / « Ajouter » / nouveau lot / fiche (le scan ne retire jamais rien seul) ; code inconnu → nouvelle référence (`DrinkFormScreen(barcode:)`) ou association à un lot existant (`DrinkPickerScreen`). Les actions s'exécutent dans le contexte de la liste, pour que le bandeau « Annuler » reste visible.
- Bouton « Scanner » au-dessus d'« Ajouter » sur la liste.
- Code-barres **dans les deux sens** (demande du porteur) : bouton « Scanner le code-barres » dans le formulaire de création (`_scanBarcode` : code déjà connu → continuer ou voir la référence ; Open Food Facts complète les champs **vides** seulement) et « Associer un code-barres » dans le menu de chaque lot de la fiche (`scanBarcodeForLot`). `barcodeScannerProvider` (dans `scan_flow.dart`) remplaçable dans les tests ; `ScanScreen(offerLabel: false)` masque « Pas de code-barres ? ».
- `lib/scan/open_food_facts.dart` — recherche d'un code inconnu (5b) : `OpenFoodFacts.lookUp` → `OffFound(DrinkDraft)` / `OffNotFound` / `OffOffline` (aucune requête) / `OffUnavailable`. **Seuls les codes de 8 à 14 chiffres sont envoyés** (jamais le contenu d'un QR code), avec un User-Agent sans adresse personnelle. `draftFromProduct` : nom, marque → producteur, degré, volume, catégories (`en:red-wines`…) → profil + noms de caractéristiques. `openFoodFactsProvider` (`lib/scan/providers.dart`, réseau via `syncEnvironmentProvider.isOnline`).
- `lib/domain/drink_draft.dart` — `DrinkDraft` : fiche proposée (type par **profil**, caractéristiques par **nom**, retrouvés dans la classification de l'utilisateur) ; `DrinkFormScreen(draft:)` la pré-remplit, rien n'est enregistré sans validation.
- `lib/domain/similarity.dart` — **doublons** (5e) : `similarityScore` (mots sans accents ni petits mots, abréviations « Ch. », « Dom. », « St »… développées, millésimes et volumes retirés, une faute de frappe tolérée sur les mots de 5 lettres et plus, coefficient de Dice ; compare aussi nom + producteur), seuil `similarityThreshold` = 0,66. Ne fait que **proposer** : l'import, lui, garde un rapprochement exact (`compactKey`).
- Ressemblance **pour la photo** (`labelMatchScore`, même fichier) : chaque référence de la cave est cherchée dans **tout** le texte lu ; confusions de reconnaissance ramenées à une même forme (0/o, 1/i/l, 5/s, rn/m…), une lettre fausse tolérée de 5 à 7 lettres, deux au-delà, mots collés ou coupés ; il faut 75 % des mots de la référence dont au moins un distinctif (pas « Château », « Domaine »…). `CaveQueries.drinksOnLabel` combine les deux comparaisons. La saisie à la main garde la comparaison stricte.
- `LabelMatcher` (`similarity.dart`) : texte lu préparé une seule fois pour toute la cave (formes canoniques rangées par longueur, mots déjà cherchés retenus, tri rapide par paires de lettres avant la distance de Levenshtein) ; `labelMatchScore` n'est qu'un raccourci pour une seule référence.
- `CaveQueries.similarDrinks` — références proches (autre profil écarté), utilisée par le formulaire de création (`_askSimilar` : ajouter les bouteilles à la référence existante via `addToExistingDrink`, créer quand même, ou revenir) et par la fiche « Code inconnu » (`_lookUp` dans `scan_flow.dart`).
- `lib/domain/label_reading.dart` — **lecture d'étiquette** (5c), logique pure : `readLabel(lignes, AppellationIndex)` → millésime (année plausible, jamais « depuis 1850 »), degré, volume, appellation INAO la plus précise (pays « France » alors rempli), profil et caractéristiques d'après les mots, nom suggéré (ligne au plus gros texte, hors mentions légales), producteur (« mis en bouteille par… », « Brasserie… »). `LabelReading.toDraft()`.
- `assets/appellations.txt` — 1 659 appellations françaises de vins et spiritueux, **construit par `tool/build_appellations.py`** à partir de deux jeux de données de l'INAO sur data.gouv.fr (Licence Ouverte, citer la source). Le script télécharge tout lui-même (le .dbf de l'archive parcellaire est lu à distance, sans les 267 Mo) ; relire `--show-excluded` après une mise à jour.
- `lib/scan/label_recognizer.dart` — interface `LabelRecognizer` (moteur interchangeable, CDC §10) ; Tesseract seul depuis le lot 7 (`MlKitLabelRecognizer` retiré). `labelRecognizerProvider`, `appellationIndexProvider` dans `lib/scan/providers.dart`.
- **Tesseract** (5d) : `TesseractLabelRecognizer` appelle **Tesseract4Android 4.9.0 (Tesseract 5.5)** par un canal maison `fr.bouthon.cave/tesseract` (`android/app/src/main/kotlin/fr/bouthon/cave/MainActivity.kt` : une instance gardée, un fil de fond). Le paquet `flutter_tesseract_ocr` a été **abandonné** : sa partie Android utilise `jcenter()`, refusé par Gradle 9. Dépôt JitPack limité au groupe `cz.adaptech.tesseract4android` (`android/build.gradle.kts`). Dictionnaire `assets/tessdata/fra.traineddata` (tessdata_best, 4 Mo, Apache 2.0), copié au premier usage dans le dossier privé. Résultat en hOCR → `parseHocr` (taille des lettres, mots de confiance < 40 écartés).
- Tesseract **ne lit pas l'orientation EXIF** des photos (ML Kit, retiré depuis, le faisait) : `MainActivity.loadUpright` redresse et réduit (2 000 px) l'image avant lecture. Sans cela, une photo prise en portrait arrive tournée d'un quart de tour et Tesseract ne rend que du charabia, entièrement écarté par le filtre de confiance (« aucun texte », vu par le porteur). Vérifié sur PC avec le Tesseract 5.5 du système : droite = lecture quasi parfaite, tournée = charabia. Si tous les mots sont peu sûrs, ils sont gardés quand même (`readHocr`) ; le mode comparaison affiche le diagnostic « N mots gardés, M écartés ».
- `lib/features/label/` — `LabelCaptureScreen` (package `camera`, lampe torche) ; `label_flow.dart` : `readLabelWithCamera` (photo **supprimée** après lecture, CDC §6.2), `LabelReadingScreen` (suggestions, lignes à toucher pour nom / producteur / appellation, « Déjà dans votre cave ? »), `continueAfterLabel`, `addToExistingFromLabel` (fenêtre « nouveau lot » pré-remplie). Points d'entrée : bouton « Lire l'étiquette » du formulaire de création (ne remplit que les champs vides), fiche « Code inconnu » (complète Open Food Facts), écran de scan (« Pas de code-barres ? »). `labelPhotoProvider` remplaçable dans les tests.
- **Mise en forme des lignes lues** (2026-10-10, demande du porteur) : `joinLeadWords` (`label_reading.dart`, appelé par `readLabel`, les deux moteurs) colle à la ligne suivante une ligne faite seulement de mots « jamais seuls » (`leadWords` : Château, Domaine, Clos, Cuvée, Brasserie… + de/du/la) ; `tidyLabelText` (ex-`_tidy`) remet en forme les lignes en capitales, à l'affichage et à l'attribution. Tesseract : `_sideBySide` (`label_recognizer.dart`) regroupe les « lignes » côte à côte (centres à moins de 0,9 hauteur, lettres de taille voisine, sans chevauchement en largeur, écart ≤ 2,5 hauteurs) — texte en pente ou courbe ; réglé sur un vrai résultat de Tesseract (`test/fixtures/etiquette_courbe_tesseract5.hocr`). Écran de lecture : « Ajouter à la suite du nom / du producteur ». Un nom en **arc prononcé** reste illisible (charabia de Tesseract) : il faudrait redresser l'image.
- `lib/domain/label_parsing.dart` — `parseVolumeMl` (« 75 cl », « 0,75 L », « 6 x 33 cl »), `parseAbv` ; resserviront à la lecture des étiquettes (5c).

## Où trouver quoi (lot 6)

- `lib/features/welcome/welcome_screen.dart` — **premier lancement** (CDC §6.8) : `WelcomeGate` (si la préférence `welcome_done` est absente : accueil pour une cave neuve, sinon la liste directement et la préférence est posée — un téléphone qui a déjà une cave ne voit jamais l'accueil) ; `WelcomeScreen` : 1. mode de stockage (local → alerte « données sur cet appareil seulement », CDC §8.4, montrée une fois ; synchro → `SyncScreen`), 2. import (`startImport`), 3. volumes par défaut par type (`setDefaultVolumeMl`). Chaque étape peut être passée. `main.dart` lit la préférence avant `runApp` et passe `CaveApp(firstLaunch:)` (faux par défaut : les tests existants ouvrent la liste).
- `lib/data/app_preferences.dart` — **réglages propres à l'appareil** (`AppPreferences` : thème, taille du texte ×1 / ×1,15 / ×1,3, tri à l'ouverture, épuisés affichés à l'ouverture, durée du bandeau « Annuler », recherche Open Food Facts). Lus dans `main.dart` avant `runApp` (`initialAppPreferencesProvider`, pas de clignotement du thème), modifiés par `appPreferencesProvider.notifier.change`. Clés `pref_*` : ne pas renommer. `DrinkFilterNotifier` part du tri et des épuisés réglés ; « Effacer les filtres » (`clearFilters`) y revient.
- `lib/features/settings/settings_screen.dart` — **écran Paramètres** (menu ⋮ → Paramètres) : Apparence, Volumes par défaut (`DefaultVolumeTiles`, `default_volumes.dart`, partagé avec l'accueil ; seul réglage synchronisé, il est dans la base), Affichage, Reconnaissance (moteur — le sélecteur reste aussi sur l'écran photo pendant la bêta — et Open Food Facts), Données (liens vers Synchronisation, Sauvegardes, Espace disque, import, export). Le menu ⋮ ne garde que Inventaire, Statistiques, Importer, Exporter, Paramètres.
- `lib/features/settings/classification_screen.dart` — **classification** (Paramètres → Types et caractéristiques, CDC §6.1) : créer un type (nom, profil de champs **non modifiable ensuite**, volume), une famille, une valeur ; renommer ; supprimer avec le nombre de références concernées. Noms vides ou en double au même endroit refusés (sans accents ni majuscules, `validateClassName`). Pas de réordonnancement (nouveaux éléments en dernier).
- Dépôt : `createType` / `createFamily` / `createCharacteristic`, `rename…`, `deleteType` (familles et valeurs avec, **refusé pour le dernier type**), `deleteFamily` (valeurs avec), `deleteCharacteristic`, compteurs `drinkCountOfType`, `drinkCountWithCharacteristics`. Suppressions logiques : les références gardent leur `type_id` et s'affichent « Sans catégorie » ; réenregistrée, une telle fiche perd son type et passe « à compléter ». L'index de recherche suit seul (déclencheurs sur `drink_types` et `characteristics`). La fusion de synchro les traite comme toute fiche (test dans `merge_test.dart`).
- **Licence** : `LICENSE` = texte exact de la GPL v3 (copié de `/usr/share/common-licenses/GPL-3`) ; `COPYING.md` = auteur (© 2026 Maxence Pithon), **GPL v3 ou ultérieure** (choix du porteur), tableau des éléments de tiers (l'autorisation supplémentaire pour ML Kit a été retirée au lot 7).
- `lib/features/settings/about_screen.dart` — **À propos** (Paramètres, en bas) : version (`package_info_plus`, `appVersionProvider` remplaçable en test), licence, sources (INAO, Open Food Facts, Tesseract, ZXing + Leptonica/libpng/libjpeg — la phrase « basé en partie sur les travaux de l'Independent JPEG Group » est **exigée** par libjpeg —, icône), bouton « Licences des logiciels » (`showLicensePage`). `lib/licenses.dart` (`registerExtraLicenses`, appelé dans `main`) y ajoute les licences sans paquet Dart, textes dans `assets/licenses/`.
- **Icône** (choix du porteur, 2026-10-07) : bouteille « bottle » de Tabler Icons (MIT, source et licence dans `tool/icon/`) en blanc sur le bordeaux du thème `#7B1E3A`. Icône adaptative **vectorielle** : `res/drawable/ic_launcher_foreground.xml` (tracés SVG recopiés, agrandis ×2,25 au centre), `res/values/ic_launcher_background.xml`, `res/mipmap-anydpi-v26/ic_launcher.xml` (+ monochrome pour les icônes à thème d'Android 13+). Les PNG `mipmap-*/ic_launcher.png` et `assets/icon.png` (écran À propos) sont des rendus de secours. Pas d'outil de conversion SVG sur le PC : rendu fait avec `firefox --headless --screenshot` + Pillow.
- Open Food Facts désactivé : `OpenFoodFacts.lookUp` rend `OffDisabled` **sans aucune requête** ; le scan et le formulaire ne lancent alors pas la recherche.
- **Synchronisation automatique** activable (écran Synchronisation, préférence `sync_automatic` de l'appareil, remise par défaut à la désactivation) : désactivée, ni ouverture, ni retour au premier plan (`SyncController.resumed`), ni modification, ni retour du réseau, ni nouvel essai ne synchronisent ; une modification fait passer l'état à `SyncStatus.pending` (« Modifications à envoyer ») jusqu'à « Synchroniser maintenant ».
- **Sauvegardes** : fréquence (chaque jour / semaine / mois, `backup_every_days`) et **dossier choisi** (`backup_folder`, sélecteur de dossier de `file_picker`) dans `BackupService` ; un dossier est essayé (fichier `.essai-ma-cave` écrit puis supprimé) avant d'être accepté — sur Android 11+, seuls Documents et Download (et leurs sous-dossiers) sont utilisables par chemin. Les sauvegardes déjà faites restent dans l'ancien dossier.
- **Android 8 à 10** (vérifié sur un Mi 9T Pro, Android 10) : autorisation `WRITE_EXTERNAL_STORAGE` (`maxSdkVersion` 29, remplace celle du paquet camera limitée à 28 par `tools:replace`) + `requestLegacyExternalStorage` ; demandée par un canal maison `fr.bouthon.cave/storage` (`MainActivity.kt`, `lib/sync/storage_access.dart`, `GrantedStorageAccess` hors Android et en test) : au premier lancement après l'alerte du mode local, une fois à l'ouverture si la cave n'est pas vide (`storage_permission_asked`), avant « Sauvegarder maintenant » / un changement de dossier, et par le bouton « Autoriser » de l'écran Sauvegardes. **Refus définitif** (« Ne plus demander ») : Android n'affiche plus la fenêtre ; `MainActivity` le note quand une demande est refusée sans `shouldShowRequestPermissionRationale` (`StorageAccess.blocked`) et l'écran propose alors « Ouvrir les réglages » (page de l'appli dans Android) ; il se met à jour au retour (`AppLifecycleListener`). Sans autorisation, l'écran Sauvegardes ne lit pas le dossier (Android refuse même de le lister).
- **Import « maison »** (demande du porteur, pour la diffusion) : « Importer » ouvre d'abord un choix (`startImport` : « Choisir le fichier » → `pickAndImport`, ou « Préparer un fichier dans un tableur ») ; `lib/features/exchange/import_guide_screen.dart` = consignes (règles, colonnes, types et caractéristiques **de la cave de l'utilisateur**) + « Obtenir le fichier modèle » (partage ou enregistrement, même code que l'export : `_askTarget` / `_deliver`). `lib/data/exchange/import_template.dart` : modèle = colonnes du stock sans ID ni date d'ajout + 2 lignes « EXEMPLE … (à supprimer) » écrites avec la classification de l'utilisateur (testé : importé tel quel sans erreur). L'aperçu d'un fichier non reconnu propose les consignes. La colonne « Volume (ml) » accepte aussi « 75 cl », « 1,5 l » (`parseVolumeMl`).
- Activation de la synchro avec une **cave neuve** (`CaveRepository.isEmpty` : aucune référence ni lot, même supprimés) et une autre cave sur le serveur : celle du serveur est reprise **sans poser la question** (nouvel appareil, CDC §6.8) ; sinon la question « Utiliser / Remplacer » reste.

Pièges rencontrés :
- Test d'un écran en `ListView` : `scrollUntilVisible` avec un pas positif ne fait que descendre → toucher les lignes dans l'ordre de l'écran ; viser la bonne liste par une clé (`Key('settings-list')`).
- `tester.pageBack()` ne trouve pas le bouton retour ici : toucher `find.byTooltip('Retour')`.
- Android 10 sans autorisation de stockage : **même lister** un dossier de Documents échoue (`PathAccessException`, errno 13). Tout écran qui lit ce dossier doit d'abord vérifier `StorageAccess.granted()`.
- Xiaomi (MIUI) : « Installer via USB » exige un compte Xiaomi et une carte SIM ; à défaut, copier l'APK avec `adb push … /sdcard/Download/` et l'installer depuis le gestionnaire de fichiers. `pm revoke` est aussi refusé par MIUI. Si `adb devices` est vide alors que le téléphone est branché : `adb kill-server; adb start-server`.

## Où trouver quoi (lot 8, portage PC)

- `linux/` — projet natif Linux généré par `flutter create --platforms=linux` (à commiter ; `linux/flutter/ephemeral` ignoré). Fenêtre dans `linux/runner/my_application.cc` (titre « Ma Cave », taille, taille minimale, icône), identifiant `fr.bouthon.cave` dans `linux/CMakeLists.txt`.
- `CaveDatabase.open` (`lib/data/database.dart`) : sur PC, base dans le dossier des données d'applications (`~/.local/share/fr.bouthon.cave/cave.sqlite`) ; Android **inchangé** (dossier par défaut de drift — le changer perdrait la base du téléphone). Tableau des emplacements : `docs/architecture.md` §7.
- Essayer l'appli PC **sans toucher à sa vraie base** : `XDG_DATA_HOME=<dossier temporaire> build/linux/x64/debug/bundle/cave` (préférences et base y sont créées).

- **Capacités de l'appareil** (8b) : `lib/platform/device_capabilities.dart` — `deviceCapabilitiesProvider` (`camera`, `shareFiles`, `icon`), tiré de `defaultTargetPlatform` (Android dans les tests : les anciens tests voient le téléphone ; `test/desktop_test.dart` remplace le fournisseur par `DeviceCapabilities.desktop`). Sans caméra : `startScan` et `barcodeScannerProvider` ouvrent `askBarcodeByHand(scanner: true)` (`scan_screen.dart`, aide « douchette USB » ; une douchette tape le code puis Entrée), bouton « Code-barres » sur la liste, « Saisir le code-barres » dans le formulaire, « Lire l'étiquette » et la photo de la fiche « Code inconnu » masqués. Sans partage : export et fichier modèle en « Enregistrer » seul (`_askTarget`), pas de « Partager » dans l'écran Sauvegardes. `file_picker` sous Linux passe par le portail XDG (fenêtre de KDE) et écrit bien le fichier.
- **Mise en page selon la largeur** (8c) : `lib/ui/layout.dart` — `isWideLayout` (≥ 840 dp, `wideLayoutMinWidth`), `ReadableWidth` (contenu centré, 720 dp au plus) autour du corps de tous les écrans de formulaire / texte. Fenêtre large : `CellarScreen` = liste (2/5) + `_DetailPane` (3/5) avec son propre `ScaffoldMessenger` (bandeau « Annuler » de la fiche dans la partie droite) ; référence choisie dans `selectedDrinkProvider` (`lib/features/cellar/selected_drink.dart`). **Toujours ouvrir une fiche par `openDrink(context, ref, id, replace:)`** : fenêtre large → retour à la liste avec la fiche à droite ; étroite → écran par-dessus (comportement du téléphone). `DrinkDetailScreen(onDeleted:)` : vide la partie droite au lieu de fermer l'écran (sinon la liste se fermerait).
- **Clavier** (8c) : Ctrl+F → recherche (`CallbackShortcuts` dans `CellarScreen`) ; Échap (`_escape` dans `app.dart`) : fenêtre ou menu → Flutter les ferme ; champ de texte → le quitte ; sinon écran précédent (`maybePop`).
- Textes : « ce téléphone » → « cet appareil » partout (valables sur les deux plateformes, téléphone compris).

Pièges rencontrés :
- Échap sur une page : Flutter trouve d'abord l'action « fermer » de la page (désactivée pour un écran ordinaire) et **s'arrête là** (`Actions.maybeFind` / `Actions.invoke` ne remontent pas plus haut) : une action `DismissIntent` au niveau de l'appli n'est jamais appelée. D'où l'interception de la touche (`Focus(onKeyEvent:)` dans le `builder` de `MaterialApp`), qui laisse passer Échap quand le curseur est dans une `PopupRoute` (fenêtre, menu, feuille du bas).
- Deux `Scaffold` côte à côte sous le même `ScaffoldMessenger` affichent chacun le bandeau : la partie droite a son propre `ScaffoldMessenger`.
- Tests en fenêtre large : `tester.view.physicalSize = Size(1200, 800)` + `devicePixelRatio = 1` + `addTearDown(tester.view.reset)` ; la fenêtre de test par défaut (800 × 600) reste « étroite ».
- Préférences sous Linux : `~/.local/share/fr.bouthon.cave/shared_preferences.json`, clés **sans** préfixe `flutter.` (API `SharedPreferencesAsync`). Pour passer l'accueil dans un essai : `{"welcome_done":"1"}`.
- `flutter create` sur le projet existant **met à jour `pubspec.lock`** en douce (une dizaine de bibliothèques) et remplace la plateforme `android` par `linux` dans `.metadata` : remettre le lock (`git checkout pubspec.lock`) et compléter `.metadata` à la main.

## Où trouver quoi (lot 7)

- `lib/scan/zxing_reader.dart` — `LuminanceFrame` (plan Y d'une image de la caméra), `ZxingFrameDecoder` (canal `fr.bouthon.cave/zxing`), `ReadConfirmer` : un code linéaire n'est retenu que **lu deux fois de suite** à l'identique (somme de contrôle faible) ; un QR code / Data Matrix dès la première lecture.
- `lib/features/scan/zxing_scanner.dart` — `ZxingScannerController` (caméra du paquet `camera` en 1280 × 720, flux d'images, une image lue à la fois, lampe, `stop()` qui libère la caméra) et `ZxingScannerView` (aperçu, suit la vie de l'appli).
- `ScanScreen` (`scan_screen.dart`) : un seul `ZxingScannerController`, créé dans `initState`, arrêté avant de fermer l'écran.
- `MainActivity.kt` — ZXing **Java** (`com.google.zxing:core:3.5.4`, Maven Central, sans code natif, +0,2 Mo) sur un fil à part : formats EAN-13/8, UPC-A/E, Code 128/39/93, ITF, QR, Data Matrix, `TRY_HARDER` ; l'image est lue telle quelle puis **tournée d'un quart de tour** (capteur en paysage : un code horizontal à l'écran y est vertical, et les codes linéaires ne sont lus que dans le sens des lignes).
- Licences : ZXing dans `COPYING.md`, l'écran À propos et `lib/licenses.dart` (texte Apache 2.0 déjà présent).

## Conventions

- **Textes de l'interface** : jamais en dur dans le code. Tout passe par `lib/l10n/app_fr.arb` (avec une `description` pour chaque clé), puis `AppLocalizations.of(context).cle`. Pluriels au format ICU (voir `bottleCount`). Dates et nombres formatés selon la langue de l'appareil (`intl`).
- **Langue du code** : noms (classes, variables, tables) en anglais, selon l'usage Dart ; **commentaires en français**. Vocabulaire : référence = `drink`, lot = `lot`, mouvement = `movement`, volume = `volume`, millésime = `vintage`.
- **Style** : `dart format` + `flutter analyze` sans avertissement avant chaque commit.
- **Tests** : obligatoires pour le stock, la fusion de synchronisation, les imports/exports (CDC §9). Base drift en mémoire pour les tests.
- **Interface** : utilisable d'une main dans le noir — boutons ≥ 56 dp (`AppTheme.minButtonHeight`), contraste élevé, couleurs prises dans `Theme.of(context).colorScheme`, jamais en dur.
- **Base** : toute modification de schéma = nouvelle version + migration drift + test de migration. Jamais de suppression physique d'une ligne synchronisée : `deleted_at`. Seule exception : la purge manuelle de l'historique, protégée par la date synchronisée `history_purged_before` (voir `history_purge.dart`).
- **Données personnelles** : le code partagé doit rester **vierge** — l'appli est livrée sans aucune donnée de cave (seulement la classification et les valeurs par défaut du CDC). `docs/cellar.csv` (export Vivino du porteur) reste local : on peut le lire pour concevoir l'import, mais jamais le commiter ni recopier son contenu (noms de vins, etc.) dans le code, les tests ou la documentation. Idem pour les bases `.sqlite`/`.db`, sauvegardes et exports CSV (voir `.gitignore`). Les tests utilisent des données inventées dans `test/fixtures/` (dont un faux `cellar.csv` au format Vivino). Rappel : un fichier commité reste dans l'historique Git même après suppression.
- **Performances** : `flutter test tool/perf/cave_perf_test.dart` (hors de `test/`, donc pas lancé par `flutter test`) crée une cave factice de 5 000 références et 21 000 mouvements et chronomètre les opérations courantes. À relancer après toute modification de la liste, de la recherche, des doublons ou de la synchro. Valeurs du 2026-10-10 sur le PC : ouverture 0,2 s, « −1 » 0,16 s, recherche < 0,1 s, photo → « Déjà dans votre cave ? » 0,3 s, sauvegarde 0,6 s, fusion 1 s. Leçons : les index SQL n'apportaient rien (SQLite crée des index temporaires) ; le coût était côté Dart (`fold` recalculé à chaque comparaison de tri, texte lu reparcouru pour chaque référence → `LabelMatcher`).
- **Aides d'interface communes** (`lib/ui/widgets.dart`) : `confirm(context, title:, message:, action:)` et `showMessage(context, texte)` ; un champ de texte d'une fenêtre appartient à un petit `StatefulWidget` qui le détruit lui-même (sinon erreur pendant l'animation de fermeture).
- **Git** : commits en français, petits et thématiques ; un lot terminé = CLAUDE.md à jour + tests verts.

## Journal

Journal des séances : `docs/journal.md` (ajouter une entrée à la fin de chaque lot).
