import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Ce qu'il faut pour estampiller une écriture : quel appareil, quelle heure,
/// quel nouvel identifiant. Regroupé ici pour que les tests puissent fournir
/// une horloge et des identifiants prévisibles.
class WriteContext {
  WriteContext({
    required this.deviceId,
    int Function()? clock,
    String Function()? idGenerator,
  }) : _clock = clock ?? _systemClock,
       _idGenerator = idGenerator ?? _uuidV7;

  /// Identifiant de cet appareil, créé au premier lancement.
  final String deviceId;
  final int Function() _clock;
  final String Function() _idGenerator;

  /// Heure actuelle, UTC, en millisecondes.
  int now() => _clock();

  /// Nouvel UUID v7 (triable par date de création).
  String newId() => _idGenerator();

  /// Champs d'une suppression logique, communs à toutes les tables
  /// synchronisées (colonnes de `SyncColumns`) : la ligne reste, datée et
  /// signée, pour que la suppression se propage aux autres appareils.
  RawValuesInsertable<T> deletionStamp<T>() {
    final time = now();
    return RawValuesInsertable<T>({
      'deleted_at': Variable<int>(time),
      'updated_at': Variable<int>(time),
      'updated_by': Variable<String>(deviceId),
    });
  }

  static int _systemClock() => DateTime.now().toUtc().millisecondsSinceEpoch;

  static String _uuidV7() => const Uuid().v7();
}
