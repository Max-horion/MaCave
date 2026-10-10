// Banc d'essai de performance (CDC §9 : ouverture en moins de 2 s, recherche
// instantanée avec plusieurs milliers de lots). Pas lancé par `flutter test`
// (hors du dossier test/) : à lancer à la main, sur le PC :
//
//   flutter test tool/perf/cave_perf_test.dart
//
// Crée une cave factice (noms inventés) dans un vrai fichier SQLite, puis
// chronomètre les opérations courantes. Les durées sont celles du PC : un
// téléphone récent est du même ordre, un ancien (Android 8) 3 à 5 fois plus
// lent.

import 'dart:io';
import 'dart:math';

import 'package:cave/data/cave_queries.dart';
import 'package:cave/data/cave_repository.dart';
import 'package:cave/data/database.dart';
import 'package:cave/data/exchange/csv_export.dart';
import 'package:cave/data/local_store.dart';
import 'package:cave/data/write_context.dart';
import 'package:cave/domain/drink_filter.dart';
import 'package:cave/sync/backup.dart';
import 'package:cave/sync/cave_file.dart';
import 'package:cave/sync/merge.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Nombre de références (une par lot, plus quelques lots supplémentaires).
const drinkCount = 5000;

/// Mouvements de sortie ajoutés par lot, en plus de l'entrée.
const exitsPerLot = 3;

const _first = [
  'Château',
  'Domaine',
  'Clos',
  'Mas',
  'Brasserie',
  'Maison',
  'Cuvée',
  'Abbaye',
  'Distillerie',
  'Cave',
];
const _words = [
  'des Lunes',
  'du Vent',
  'Imaginaire',
  'de la Colline',
  'Saint-Truc',
  'des Trois Chênes',
  'Bellevue',
  'du Moulin',
  'les Graves',
  'Fictif',
  'de l\'Étoile',
  'du Lac',
  'Haut-Rocher',
  'des Sources',
  'la Forge',
];
const _regions = [
  'Bordeaux',
  'Bourgogne',
  'Alsace',
  'Loire',
  'Rhône',
  'Champagne',
  'Languedoc',
  'Provence',
  'Jura',
  'Savoie',
];

Future<Duration> time(Future<void> Function() action) async {
  final watch = Stopwatch()..start();
  await action();
  return watch.elapsed;
}

String ms(Duration d) => '${d.inMilliseconds} ms'.padLeft(9);

void main() {
  test('performances avec une grosse cave', () async {
    final root = Directory.systemTemp.createTempSync('cave_perf');
    final file = File('${root.path}/cave.sqlite');
    var db = CaveDatabase(NativeDatabase(file));
    final ctx = WriteContext(deviceId: 'banc-essai');
    var repo = CaveRepository(db, ctx);
    final random = Random(42);
    final results = <String, Duration>{};

    // --- Création de la cave ------------------------------------------------
    final types = await repo.drinkTypes();
    final characteristics = await db.select(db.characteristics).get();
    results['création ($drinkCount références)'] = await time(() async {
      await db.transaction(() async {
        for (var i = 0; i < drinkCount; i++) {
          final name =
              '${_first[random.nextInt(_first.length)]} '
              '${_words[random.nextInt(_words.length)]} $i';
          final created = await repo.addNewDrink(
            drink: DrinkInput(
              name: name,
              typeId: types[random.nextInt(types.length)].id,
              producer: 'Producteur ${random.nextInt(800)}',
              region: _regions[random.nextInt(_regions.length)],
              country: 'France',
            ),
            characteristicIds: {
              characteristics[random.nextInt(characteristics.length)].id,
            },
            volumeMl: 750,
            vintage: 1990 + random.nextInt(35),
            quantity: 6 + random.nextInt(12),
          );
          for (var e = 0; e < exitsPerLot; e++) {
            await repo.addExit(created.lotId, 1);
          }
          // Un lot sur cinq a un second millésime.
          if (i % 5 == 0) {
            final lot = await repo.findOrCreateLot(
              drinkId: created.drinkId,
              volumeMl: 750,
              vintage: 2020,
            );
            await repo.addEntry(lot, 3);
          }
        }
      });
    });
    final lots = await db.select(db.lots).get();
    final movements = await db.select(db.movements).get();

    // --- Ouverture : fichier rouvert, premier affichage de la liste ---------
    await db.close();
    results['ouverture (base + liste + totaux)'] = await time(() async {
      db = CaveDatabase(NativeDatabase(file));
      repo = CaveRepository(db, ctx);
      final queries = CaveQueries(db);
      await Future.wait([
        queries.watchDrinkList(const DrinkFilter()).first,
        repo.watchTotals().first,
        queries.watchClassification().first,
        queries.watchRegions().first,
      ]);
    });
    final queries = CaveQueries(db);

    // --- Recherche et filtres ----------------------------------------------
    for (final query in ['chateau', 'lunes', '2015', 'vin rouge', 'b']) {
      results['recherche « $query »'] = await time(
        () => queries.watchDrinkList(DrinkFilter(query: query)).first,
      );
    }
    results['liste triée par millésime'] = await time(
      () => queries
          .watchDrinkList(const DrinkFilter(sort: DrinkSort.vintage))
          .first,
    );
    results['liste avec épuisés'] = await time(
      () =>
          queries.watchDrinkList(const DrinkFilter(showExhausted: true)).first,
    );

    // --- Sortie rapide « −1 » et mise à jour de la liste --------------------
    final stream = queries.watchDrinkList(const DrinkFilter());
    var updates = 0;
    final listened = stream.listen((_) => updates++);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final before = updates;
    results['« −1 » puis liste à jour'] = await time(() async {
      await repo.addExit(lots.first.id, 1);
      while (updates == before) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    });
    await listened.cancel();

    // --- Fiche, statistiques, inventaire ----------------------------------
    results['fiche (référence, lots, historique)'] = await time(() async {
      final id = lots.first.drinkId;
      await Future.wait([
        queries.watchDrink(id).first,
        queries.watchLotsOf(id).first,
        queries.watchMovementsOfDrink(id).first,
      ]);
    });
    results['statistiques'] = await time(() => queries.watchStats().first);
    results['inventaire guidé (liste)'] = await time(queries.inventoryLots);
    results['doublons (nom proche)'] = await time(
      () => queries.similarDrinks(name: 'Chateau des Lunnes', profile: null),
    );

    // Photo d'étiquette : une trentaine de lignes lues, références de la
    // cave cherchées dans tout le texte (« Déjà dans votre cave ? »).
    final label = [
      'GRAND VIN DE BORDEAUX',
      'CHATEAU DES LUNE5',
      '2019',
      'APPELLATION SAINT-EMILION GRAND CRU CONTROLEE',
      for (var i = 0; i < 25; i++) 'MIS EN BOUTEILLE AU CHATEAU LIGNE $i',
      '13,5 % vol 75 cl',
    ].join('\n');
    results['référence sur une photo (texte entier)'] = await time(
      () => queries.drinksOnLabel(labelText: label, name: 'Château des Lunes'),
    );

    // --- Sauvegarde, export, synchronisation ------------------------------
    results['empreinte de la base'] = await time(() => contentFingerprint(db));
    results['export CSV (stock + historique)'] = await time(
      () => exportCsv(db),
    );
    final backups = BackupService(
      db: db,
      store: MemoryLocalStore(),
      folder: () async => Directory('${root.path}/Sauvegardes'),
      tempFolder: () async => root,
    );
    results['sauvegarde complète'] = await time(backups.backupNow);
    final copy = '${root.path}/copie.sqlite';
    await snapshotDatabase(db, copy);
    results['fusion de synchro (même cave)'] = await time(
      () => mergeCaveFile(db, ctx, copy),
    );

    await db.close();
    final size = file.lengthSync();
    root.deleteSync(recursive: true);

    // ignore: avoid_print
    print(
      '\nCave : $drinkCount références, ${lots.length} lots, '
      '${movements.length} mouvements, fichier de '
      '${(size / 1024 / 1024).toStringAsFixed(1)} Mo\n'
      '${results.entries.map((e) => '${ms(e.value)}  ${e.key}').join('\n')}',
    );
  }, timeout: const Timeout(Duration(minutes: 10)));
}
