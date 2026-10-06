import 'dart:io';

import 'backup.dart';
import 'webdav.dart';

// Sauvegardes sur le serveur, en mode synchronisé (CDC §8.4, décision du
// 06/10/2026) : en plus des sauvegardes du téléphone, la plus récente est
// copiée dans le dossier « Sauvegardes » du serveur, qui en garde le même
// nombre. Une copie reste ainsi si le téléphone est perdu, une autre si le
// serveur l'est.

/// Nom du sous-dossier des sauvegardes, à côté de la cave sur le serveur.
const serverBackupFolder = 'Sauvegardes';

/// Copie la sauvegarde locale la plus récente dans [folder] si elle n'y est
/// pas encore, puis n'y garde que les [BackupService.keepCount] plus
/// récentes. Plusieurs appareils peuvent partager le dossier : ils suivent la
/// même règle (les plus récentes, d'après la date du nom).
///
/// Retourne le nom de la sauvegarde copiée, ou null s'il n'y avait rien à
/// copier.
Future<String?> mirrorLatestBackup(
  BackupService backups,
  WebDavClient folder,
) async {
  final sets = await backups.list();
  if (sets.isEmpty) return null;
  final latest = sets.first;
  final latestName = latest.database.uri.pathSegments.last;

  var names = await folder.list();
  String? copied;
  if (!names.contains(latestName)) {
    if (names.isEmpty) await folder.createFolder();
    // La base en dernier : sa présence signifie « sauvegarde complète ».
    for (final file in latest.files.reversed) {
      final name = file.uri.pathSegments.last;
      if (names.contains(name)) continue;
      try {
        await folder.upload(name, File(file.path));
      } on WebDavException catch (e) {
        // Déjà envoyée par un autre essai : rien à faire.
        if (e.problem != WebDavProblem.preconditionFailed) rethrow;
      }
    }
    copied = latestName;
    names = [...names, ...latest.files.map((f) => f.uri.pathSegments.last)];
  }

  // Les plus anciennes au-delà du nombre conservé.
  final dated = [
    for (final name in names)
      if (BackupService.dateOfName(name) case final date?) (name, date),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  for (final (name, _) in dated.skip(await backups.keepCount())) {
    for (final file in BackupService.fileNamesOf(name)) {
      await folder.delete(file);
    }
  }
  return copied;
}
