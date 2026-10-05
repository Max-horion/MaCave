# Ma Cave — notes pour reprendre le projet

Application Android (Flutter) de gestion d'une cave personnelle : références (boissons), lots (millésime × volume) qui portent le stock, mouvements (entrées, sorties, inventaires). Fonctionne entièrement hors ligne ; synchronisation facultative avec un serveur WebDAV (Nextcloud).

## Documents de référence

- `docs/cahier_des_charges_v0.4.md` — **cahier des charges** (CDC), converti du `.docx` (source officielle). En cas de doute fonctionnel, c'est lui qui fait foi ; citer la section (ex. « CDC §6.3 »).
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
| 3 | Inventaire guidé, statistiques, import Vivino, import/export CSV | à faire |
| 4 | Synchronisation WebDAV, traitement des erreurs, sauvegardes automatiques, purge | à faire |
| 5 | Scan code-barres (+ Open Food Facts), reconnaissance de texte (ML Kit / Tesseract), lampe torche, doublons | à faire |
| 6 | Premier lancement (3 étapes), écran des paramètres, finitions | à faire |

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

## Conventions

- **Textes de l'interface** : jamais en dur dans le code. Tout passe par `lib/l10n/app_fr.arb` (avec une `description` pour chaque clé), puis `AppLocalizations.of(context).cle`. Pluriels au format ICU (voir `bottleCount`). Dates et nombres formatés selon la langue de l'appareil (`intl`).
- **Langue du code** : noms (classes, variables, tables) en anglais, selon l'usage Dart ; **commentaires en français**. Vocabulaire : référence = `drink`, lot = `lot`, mouvement = `movement`, volume = `volume`, millésime = `vintage`.
- **Style** : `dart format` + `flutter analyze` sans avertissement avant chaque commit.
- **Tests** : obligatoires pour le stock, la fusion de synchronisation, les imports/exports (CDC §9). Base drift en mémoire pour les tests.
- **Interface** : utilisable d'une main dans le noir — boutons ≥ 56 dp (`AppTheme.minButtonHeight`), contraste élevé, couleurs prises dans `Theme.of(context).colorScheme`, jamais en dur.
- **Base** : toute modification de schéma = nouvelle version + migration drift + test de migration. Jamais de suppression physique d'une ligne synchronisée : `deleted_at`.
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
