# Ma Cave — notes pour reprendre le projet

Application Android (Flutter) de gestion d'une cave personnelle : références (boissons), lots (millésime × volume) qui portent le stock, mouvements (entrées, sorties, inventaires). Fonctionne entièrement hors ligne ; synchronisation facultative avec un serveur WebDAV (Nextcloud).

## Documents de référence

- `docs/cahier_des_charges_v0.5.md` — **cahier des charges** (CDC), converti de `cahier_des_charges_gestion_cave_v0.5.docx` (source officielle ; la v0.4 est conservée pour l'historique). Toute décision qui modifie le CDC : nouvelle version du .docx (historique + journal des décisions), puis reconversion en Markdown. En cas de doute fonctionnel, c'est lui qui fait foi ; citer la section (ex. « CDC §6.3 »).
- `docs/architecture.md` — bibliothèques, schéma de la base, principe de synchronisation.
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
flutter build apk --release          # APK seul (installation : tool/installer.sh --no-build)
```

> ⚠️ **Ne jamais utiliser `flutter install`** sur le téléphone du porteur : il désinstalle l'appli avant de la réinstaller, ce qui **efface sa base**. Utiliser `tool/installer.sh` (`adb install -r`, mise à jour sur place, avec vérification). `flutter run` est acceptable (il ne désinstalle qu'en cas de conflit de signature), mais l'éviter quand le téléphone contient des données réelles. La sauvegarde Android est désactivée sur ce téléphone : rien ne permet de récupérer une base effacée avant le lot 4.

## Choix techniques (détails dans docs/architecture.md)

- Flutter / Dart, Android en V1 (min. Android 8 = API 26), PC Windows/Linux plus tard avec le même code.
- Identifiant Android `fr.bouthon.cave`, nom affiché « Ma Cave ».
- Base SQLite locale via drift ; état de l'interface via Riverpod.
- Synchro WebDAV maison (sur `http`) : mouvements identifiés par UUID et additionnés, fiches « la plus récente l'emporte », envoi conditionnel par ETag (`If-Match`) pour ne jamais écraser.
- Reconnaissance de texte interchangeable : ML Kit et Tesseract (bêta + mode comparaison).
- Budget nul. Licence prévue : GPL v3 + exception de liaison ML Kit. Dépôt GitHub privé en V1.

## Plan en lots

| Lot | Contenu | État |
|---|---|---|
| 0 | Squelette : projet, traductions FR, thèmes clair/sombre, premier test, CLAUDE.md, architecture, Git/GitHub, installation sur le téléphone | **terminé** |
| 1 | Base de données et stock : schéma drift, classification initiale, références, lots, mouvements, calcul du stock (tests) | **terminé** |
| 2 | Liste, recherche plein texte (FTS5, migration de schéma v1 → v2), filtres/tris, fiche référence et lots, ajout, sortie rapide « −1 » avec annulation | **terminé** |
| 3 | Inventaire guidé, statistiques, import Vivino, import/export CSV, historique sur la fiche | **terminé** (vérif. téléphone en attente) |
| 4 | Synchronisation WebDAV, traitement des erreurs, sauvegardes automatiques, purge — en 5 étapes : 4a sauvegardes, 4b moteur de fusion, 4c client WebDAV + cycle de synchro, 4d écran Synchronisation + indicateur, 4e purge | **terminé** |
| 5 | Scan code-barres (+ Open Food Facts), reconnaissance de texte (ML Kit / Tesseract), lampe torche, doublons — en 5 étapes, dans cet ordre : 5a scan + lampe, 5b Open Food Facts, 5e doublons, 5c photo d'étiquette + ML Kit, 5d Tesseract + comparaison | **en cours** (5a, 5b, 5e terminées ; 5c faite, à vérifier sur le téléphone) |
| 6 | Premier lancement (3 étapes), écran des paramètres, finitions | à faire |

**Décisions du porteur** (les deux premières sont dans le CDC v0.5 ; celles du lot 4 sont à reporter dans sa prochaine version) :
- une fiche incomplète est enregistrée avec le marqueur « à compléter », jamais refusée (2026-10-05) ;
- l'appellation est **facultative** pour le vin ; la région *ou* le pays restent obligatoires (2026-10-05).
- **Pas de tâches de fond en V1** (2026-10-05) : sauvegarde et synchro se font appli ouverte (ouverture, mise en arrière-plan, après modification, bouton) ; pas de workmanager ni de notification « erreur > 24 h » (affichée dans l'appli à la place). Écart au CDC §8.3/§8.4 à reporter dans sa prochaine version.
- Sauvegardes : **3 conservées par défaut**, nombre réglable sur l'écran Sauvegardes (2026-10-05).
- En mode synchronisé, sauvegardes **sur le téléphone ET sur le serveur** (dossier `Sauvegardes` à côté de la cave, même nombre conservé) (2026-10-06). Le CDC §8.4 ne prévoyait que le serveur : écart à reporter.
- Doublons (5e) faits **avant** la reconnaissance de texte, et utilisés aussi dans la fiche « Code inconnu » quand Open Food Facts trouve le produit (« Déjà dans votre cave ? ») et, au 5c, pour le nom lu sur l'étiquette (2026-10-06, idée du porteur).
- Le marqueur « à compléter » est calculé à l'enregistrement de chaque fiche. **Ne jamais le recalculer en masse** silencieusement : le porteur s'en sert comme liste de fiches à revoir (ex. après un import).

Les fonctions marquées V2 dans le CDC (emplacements, dates de consommation, photos, PDF, appli PC) ne sont pas développées en V1, mais le schéma de la base les prévoit.

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
- `lib/features/storage/storage_screen.dart` — écran « Espace disque » (menu ⋮) : taille, purge manuelle (date ≤ aujourd'hui − 30 jours, sauvegarde puis `VACUUM`), purge automatique. À déplacer dans l'écran des paramètres au lot 6.
- `lib/sync/sync_settings.dart` — paramètres de synchro propres à l'appareil (`SyncSettings` : Nextcloud = adresse du serveur → `…/remote.php/dav/files/<user>/<dossier>/`, ou adresse WebDAV complète), mot de passe dans le coffre (`SecureSecretStore`, `MemorySecretStore` pour les tests), `SyncSettingsStore`.
- `lib/sync/sync_controller.dart` — `SyncController` (Riverpod) : état affiché (`SyncState` : off, synced, syncing, waiting, error + cause, `errorSince` → rouge après 24 h), `start` (ouverture), `localChanged` (regroupe 10 s), `paused`, `syncNow`, nouvelles tentatives 1, 5, 30 min (pas pour identifiants/dossier/version/autre cave), journal des 20 dernières erreurs, `activate` (paramètres enregistrés seulement si ça marche) puis `resolveOtherCave`, `deactivate`. Dépendances regroupées dans `SyncEnvironment` (`syncEnvironmentProvider`, remplacé dans les tests par `localSyncEnvironment` de `test/helpers.dart`).
- `lib/sync/server_backups.dart` — `mirrorLatestBackup` : copie la dernière sauvegarde locale dans `Sauvegardes/` du serveur et n'y garde que les N plus récentes (règle commune à tous les appareils). Appelé après chaque synchro réussie.
- `AutomaticTasks` (`lib/sync/providers.dart`, ex-`AutoBackup`) : synchro à l'ouverture (puis sauvegarde), au retour au premier plan, après modification ; sauvegarde + synchro en attente à la mise en arrière-plan.
- `lib/features/sync/` — écran Synchronisation (formulaire, choix « autre cave », état, journal, désactivation), indicateur `SyncIndicator` dans la barre de la liste (invisible en mode local), textes communs `sync_messages.dart`.
- `test/sync/fake_webdav_server.dart` — faux serveur WebDAV (vrai serveur HTTP local, règles d'ETag de Nextcloud) ; `test/sync/device.dart` — appareils simulés (base + horloge + ID préfixés).
- `lib/sync/providers.dart` — dossier `Documents/Cave/Sauvegardes` (Android 11+ : écriture sans autorisation, vérifié sur le téléphone ; l'appli ne voit plus ses fichiers après une réinstallation → « Restaurer depuis un fichier »), widget `AutoBackup` (dans `main.dart`).
- `lib/data/local_store.dart` — préférences propres à l'appareil (`PrefsLocalStore`, `MemoryLocalStore` pour les tests).
- `lib/features/backup/backup_screen.dart` — écran Sauvegardes (menu ⋮).

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
- Réglage « recherche Open Food Facts activée ou non » (CDC §7) : pas encore fait, à mettre dans l'écran des paramètres (lot 6). En attendant la recherche est toujours active (signalée à l'écran).
- R8 (APK release) refuse les références de ML Kit aux modèles chinois/japonais/coréen/devanagari non embarqués : `-dontwarn` dans `android/app/proguard-rules.pro`.
- Écran en `ListView` dans un test : les éléments hors écran ne sont pas construits → `scrollUntilVisible`, puis `pumpAndSettle` après `ensureVisible` avant de toucher.
- APK release 114 Mo (ML Kit texte + code-barres pour 3 architectures). Si besoin : `--target-platform android-arm64` (le téléphone du porteur) le réduirait nettement.
- La caméra n'existe pas en test : tester `handleScannedCode` directement (`test/scan_flow_test.dart`).
- Android 8 à 10 : l'écriture dans Documents demandera une autorisation (pas encore gérée ; à voir au lot 6 avant toute diffusion).

## Où trouver quoi (lot 5)

- `lib/domain/barcode.dart` — `normalizeBarcode` : forme enregistrée d'un code (UPC-A 12 chiffres → EAN-13 avec un 0 devant, espaces/tirets retirés ; QR code gardé tel quel). Appliquée par `findOrCreateLot`, `lotsByBarcode`, `setLotBarcode` (dépôt).
- `lib/features/scan/scan_screen.dart` — écran de scan (`mobile_scanner`, ML Kit **embarqué** : fonctionne sans réseau), lampe torche, saisie du code à la main ; retourne le code lu.
- `lib/features/scan/scan_flow.dart` — `startScan` / `handleScannedCode` : code connu → lots avec « −1 » / « Ajouter » / nouveau lot / fiche (le scan ne retire jamais rien seul) ; code inconnu → nouvelle référence (`DrinkFormScreen(barcode:)`) ou association à un lot existant (`DrinkPickerScreen`). Les actions s'exécutent dans le contexte de la liste, pour que le bandeau « Annuler » reste visible.
- Bouton « Scanner » au-dessus d'« Ajouter » sur la liste.
- `lib/scan/open_food_facts.dart` — recherche d'un code inconnu (5b) : `OpenFoodFacts.lookUp` → `OffFound(DrinkDraft)` / `OffNotFound` / `OffOffline` (aucune requête) / `OffUnavailable`. **Seuls les codes de 8 à 14 chiffres sont envoyés** (jamais le contenu d'un QR code), avec un User-Agent sans adresse personnelle. `draftFromProduct` : nom, marque → producteur, degré, volume, catégories (`en:red-wines`…) → profil + noms de caractéristiques. `openFoodFactsProvider` (`lib/scan/providers.dart`, réseau via `syncEnvironmentProvider.isOnline`).
- `lib/domain/drink_draft.dart` — `DrinkDraft` : fiche proposée (type par **profil**, caractéristiques par **nom**, retrouvés dans la classification de l'utilisateur) ; `DrinkFormScreen(draft:)` la pré-remplit, rien n'est enregistré sans validation.
- `lib/domain/similarity.dart` — **doublons** (5e) : `similarityScore` (mots sans accents ni petits mots, abréviations « Ch. », « Dom. », « St »… développées, millésimes et volumes retirés, une faute de frappe tolérée sur les mots de 5 lettres et plus, coefficient de Dice ; compare aussi nom + producteur), seuil `similarityThreshold` = 0,66. Ne fait que **proposer** : l'import, lui, garde un rapprochement exact (`compactKey`).
- Ressemblance **pour la photo** (`labelMatchScore`, même fichier) : chaque référence de la cave est cherchée dans **tout** le texte lu ; confusions de reconnaissance ramenées à une même forme (0/o, 1/i/l, 5/s, rn/m…), une lettre fausse tolérée de 5 à 7 lettres, deux au-delà, mots collés ou coupés ; il faut 75 % des mots de la référence dont au moins un distinctif (pas « Château », « Domaine »…). `CaveQueries.drinksOnLabel` combine les deux comparaisons. La saisie à la main garde la comparaison stricte.
- `CaveQueries.similarDrinks` — références proches (autre profil écarté), utilisée par le formulaire de création (`_askSimilar` : ajouter les bouteilles à la référence existante via `addToExistingDrink`, créer quand même, ou revenir) et par la fiche « Code inconnu » (`_lookUp` dans `scan_flow.dart`).
- `lib/domain/label_reading.dart` — **lecture d'étiquette** (5c), logique pure : `readLabel(lignes, AppellationIndex)` → millésime (année plausible, jamais « depuis 1850 »), degré, volume, appellation INAO la plus précise (pays « France » alors rempli), profil et caractéristiques d'après les mots, nom suggéré (ligne au plus gros texte, hors mentions légales), producteur (« mis en bouteille par… », « Brasserie… »). `LabelReading.toDraft()`.
- `assets/appellations.txt` — 1 659 appellations françaises de vins et spiritueux, **construit par `tool/build_appellations.py`** à partir de deux jeux de données de l'INAO sur data.gouv.fr (Licence Ouverte, citer la source). Le script télécharge tout lui-même (le .dbf de l'archive parcellaire est lu à distance, sans les 267 Mo) ; relire `--show-excluded` après une mise à jour.
- `lib/scan/label_recognizer.dart` — interface `LabelRecognizer` (moteur interchangeable, CDC §10) ; `MlKitLabelRecognizer` (lettres latines, embarqué). `labelRecognizerProvider`, `appellationIndexProvider` dans `lib/scan/providers.dart`.
- `lib/features/label/` — `LabelCaptureScreen` (package `camera`, lampe torche) ; `label_flow.dart` : `readLabelWithCamera` (photo **supprimée** après lecture, CDC §6.2), `LabelReadingScreen` (suggestions, lignes à toucher pour nom / producteur / appellation, « Déjà dans votre cave ? »), `continueAfterLabel`, `addToExistingFromLabel` (fenêtre « nouveau lot » pré-remplie). Points d'entrée : bouton « Lire l'étiquette » du formulaire de création (ne remplit que les champs vides), fiche « Code inconnu » (complète Open Food Facts), écran de scan (« Pas de code-barres ? »). `labelPhotoProvider` remplaçable dans les tests.
- `lib/domain/label_parsing.dart` — `parseVolumeMl` (« 75 cl », « 0,75 L », « 6 x 33 cl »), `parseAbv` ; resserviront à la lecture des étiquettes (5c).

## Conventions

- **Textes de l'interface** : jamais en dur dans le code. Tout passe par `lib/l10n/app_fr.arb` (avec une `description` pour chaque clé), puis `AppLocalizations.of(context).cle`. Pluriels au format ICU (voir `bottleCount`). Dates et nombres formatés selon la langue de l'appareil (`intl`).
- **Langue du code** : noms (classes, variables, tables) en anglais, selon l'usage Dart ; **commentaires en français**. Vocabulaire : référence = `drink`, lot = `lot`, mouvement = `movement`, volume = `volume`, millésime = `vintage`.
- **Style** : `dart format` + `flutter analyze` sans avertissement avant chaque commit.
- **Tests** : obligatoires pour le stock, la fusion de synchronisation, les imports/exports (CDC §9). Base drift en mémoire pour les tests.
- **Interface** : utilisable d'une main dans le noir — boutons ≥ 56 dp (`AppTheme.minButtonHeight`), contraste élevé, couleurs prises dans `Theme.of(context).colorScheme`, jamais en dur.
- **Base** : toute modification de schéma = nouvelle version + migration drift + test de migration. Jamais de suppression physique d'une ligne synchronisée : `deleted_at`. Seule exception : la purge manuelle de l'historique, protégée par la date synchronisée `history_purged_before` (voir `history_purge.dart`).
- **Données personnelles** : le code partagé doit rester **vierge** — l'appli est livrée sans aucune donnée de cave (seulement la classification et les valeurs par défaut du CDC). `docs/cellar.csv` (export Vivino du porteur) reste local : on peut le lire pour concevoir l'import, mais jamais le commiter ni recopier son contenu (noms de vins, etc.) dans le code, les tests ou la documentation. Idem pour les bases `.sqlite`/`.db`, sauvegardes et exports CSV (voir `.gitignore`). Les tests utilisent des données inventées dans `test/fixtures/` (dont un faux `cellar.csv` au format Vivino). Rappel : un fichier commité reste dans l'historique Git même après suppression.
- **Git** : commits en français, petits et thématiques ; un lot terminé = CLAUDE.md à jour + tests verts.

## Journal

- 2026-10-05 — Lot 0 : projet créé, traductions et thèmes en place, 4 tests verts, architecture validée par le porteur ; dépôt GitHub privé `MaCave`.
- 2026-10-05 — Lot 0 terminé : APK release (44 Mo) compilé en ~2 min et installé sur le téléphone, écran d'accueil vérifié. Si `adb devices` est vide : le téléphone est repassé en mode « Transfert de photos » ou le débogage USB s'est désactivé (OxygenOS) → « Transfert de fichiers » + réactiver le débogage USB.
- 2026-10-05 — Lot 1 terminé : schéma v1 (drift), classification initiale, dépôt de la cave, 46 tests verts ; l'accueil affiche le nombre de bouteilles lu dans la base. APK 53 Mo.
- 2026-10-05 — Lot 2 : recherche FTS5 (migration v1 → v2 testée), liste filtrée/triée, fiche, formulaire, −1 avec annulation ; 69 tests verts. Le formulaire est accepté sans appellation/région (fiche marquée « à compléter »).
- 2026-10-05 — Retour du porteur : la recherche « vin », « rouge » ne trouvait rien (type et caractéristiques non indexés). Corrigé en schéma v3 (migration étape par étape), pluriels acceptés ; 76 tests verts.
- 2026-10-05 — Retour du porteur : pas de recherche par année. Millésimes des lots indexés (schéma v4, vue `drink_search_rows`) ; 81 tests verts.
- 2026-10-05 — **Incident : les données saisies par le porteur (2 vins) ont été effacées.** Cause : `flutter install` désinstalle l'appli avant chaque installation. Toutes les installations précédentes repartaient donc d'une base vide : **les migrations n'ont jamais été testées sur le téléphone avec des données** (contrairement à ce qu'indiquaient les entrées ci-dessus), seulement par les tests automatiques. Correctif : `tool/installer.sh` (`adb install -r` + contrôle de `firstInstallTime`). Données non récupérables (sauvegarde Android désactivée).
- 2026-10-05 — Installation sans perte vérifiée sur le téléphone : le porteur a ressaisi 2 références, `tool/installer.sh` (compilation + `adb install -r`) les a conservées.
- 2026-10-05 — Lot 3 : export/import CSV, import Vivino (essai à blanc sur le vrai fichier : 31 références, 32 lots, 95 bouteilles, 0 erreur, 16 « à compléter »), historique sur la fiche, inventaire guidé, statistiques ; 114 tests verts.
- 2026-10-05 — Import Vivino fait par le porteur sur le téléphone, OK ; fiches complétées à la main. Appellation rendue facultative (CDC v0.5) ; 118 tests verts.
- 2026-10-05 — Lot 4a : sauvegardes locales (base + CSV, 3 conservées, réglable), sauvegarde automatique, restauration ; 134 tests verts. Vérifié sur le téléphone : sauvegarde automatique à l'ouverture, fichiers lisibles dans Documents/Cave/Sauvegardes, restauration puis retour arrière par la sauvegarde de sécurité. APK 63 Mo (moteur SQLite pour lire les sauvegardes).
- 2026-10-06 — Lot 4b : moteur de fusion (`lib/sync/merge.dart`), 17 tests (deux appareils simulés, fusion dans les deux sens, convergence vérifiée) ; 151 tests verts. Pas encore branché : il le sera par le cycle de synchro (4c).
- 2026-10-06 — Lot 4c : client WebDAV (`http`) et cycle de synchro (fichier endommagé mis de côté, version plus récente, autre cave, conflit 412 → nouvel essai, dossier créé au premier envoi), « Utiliser / Remplacer la cave du serveur » ; empreinte de la base rendue insensible aux décalages d'horloge. 17 tests contre un faux serveur WebDAV ; 168 tests verts. Rien de visible dans l'appli avant le 4d.
- 2026-10-06 — Lot 4d : écran Synchronisation (Nextcloud ou WebDAV, mot de passe dans le coffre, choix « autre cave »), indicateur d'état, synchro automatique appli ouverte, nouvelles tentatives, journal, sauvegardes copiées sur le serveur ; autorisation INTERNET ajoutée (manquait en release). 193 tests verts ; APK release 64,5 Mo. **Pas encore essayé avec le vrai Nextcloud du porteur.**
- 2026-10-06 — Lot 4d vérifié sur le téléphone avec le vrai Nextcloud du porteur : activation, `cave.sqlite` et `Sauvegardes` sur le serveur, envoi automatique après « −1 », mode avion (« en attente » puis reprise), réouverture.
- 2026-10-06 — Lot 4e : purge manuelle de l'historique (report de stock, propagée par la synchro, jamais annulée par un autre appareil ni par un import) et purge automatique des lots épuisés ; écran « Espace disque ». 209 tests verts. **Lot 4 terminé** (purges à vérifier sur le téléphone).
- 2026-10-06 — Lot 4e vérifié sur le téléphone (écran Espace disque, chiffres justes). **Lot 4 terminé.** À reporter dans le CDC v0.6 : pas de tâches de fond, sauvegardes téléphone + serveur, purge manuelle limitée aux mouvements de plus de 30 jours.
- 2026-10-06 — Lot 5a : scan de code-barres / QR (ML Kit embarqué, hors ligne), lampe torche, saisie manuelle ; code connu → « −1 » / « Ajouter » / nouveau lot ; code inconnu → nouvelle référence ou association à un lot. 224 tests verts ; APK 82 Mo (+16 Mo de lecteur, toutes architectures).
- 2026-10-06 — Lot 5a vérifié sur le téléphone par le porteur (scan, lampe, association, « −1 »).
- 2026-10-06 — Lot 5b : Open Food Facts pour les codes inconnus (fiche pré-remplie : nom, producteur, degré, volume, type et caractéristiques), envoi du code signalé, jamais de QR code envoyé, hors ligne sans requête. 238 tests verts.
- 2026-10-06 — Lot 5e (avancé avant 5c) : détection des doublons à la création d'une référence (ajout des bouteilles à la référence proche, ou création quand même) et « Déjà dans votre cave ? » dans la fiche « Code inconnu » quand Open Food Facts trouve le produit. 255 tests verts.
- 2026-10-06 — Lots 5b et 5e vérifiés sur le téléphone par le porteur (Open Food Facts, hors ligne, doublons à la saisie et au scan).
- 2026-10-06 — Lot 5c : photo d'étiquette + ML Kit (millésime, degré, volume, appellation INAO, type, nom et producteur suggérés, lignes à attribuer d'un toucher, doublons), depuis le formulaire, la fiche « Code inconnu » et l'écran de scan ; liste INAO embarquée (1 659 noms, script de construction). 270 tests verts ; APK 114 Mo.
- 2026-10-06 — Lot 5c testé par le porteur : lecture fonctionnelle mais approximative (beaucoup d'erreurs sur les mots), correction par les lignes OK, scan → photo OK ; **« Déjà dans votre cave ? » n'a pas reconnu une bouteille existante** (texte lu trop éloigné du nom). Réglage d'une ressemblance tolérante aux erreurs de reconnaissance, sur exemples inventés ; le porteur remontera au prochain essai des paires « référence lue / référence réelle ».
- 2026-10-06 — Ressemblance tolérante aux erreurs de reconnaissance pour « Déjà dans votre cave ? » après une photo (texte entier, confusions de caractères, mots collés/coupés) ; 8 cas d'erreurs inventés + pièges (« Leffe Brune » ≠ « Leffe Blonde »). 280 tests verts. À valider sur les paires réelles remontées par le porteur.
