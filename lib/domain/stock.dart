import 'enums.dart';

/// Un mouvement réduit à ce qui compte pour le calcul du stock.
class StockEvent {
  const StockEvent({
    required this.id,
    required this.occurredAt,
    required this.kind,
    required this.quantity,
  });

  /// UUID v7 : sert à départager deux mouvements de même date.
  final String id;

  /// Date du mouvement (UTC, millisecondes).
  final int occurredAt;
  final MovementKind kind;
  final int quantity;
}

/// Calcule le stock d'un lot à partir de ses mouvements (CDC §4.2).
///
/// Les mouvements sont rejoués dans l'ordre chronologique :
/// - une entrée ajoute sa quantité, une sortie la retire ;
/// - un inventaire **remplace** le stock par le nombre constaté.
///
/// Ainsi, après une synchronisation, une sortie faite sur un appareil pendant
/// qu'un autre faisait l'inventaire donne le bon résultat : si elle a eu lieu
/// avant le comptage, elle y est déjà incluse ; après, elle est retirée.
///
/// Le résultat ne descend jamais sous zéro : un stock négatif ne peut venir que
/// d'une incohérence entre appareils (deux sorties de la même bouteille).
int computeStock(Iterable<StockEvent> events) {
  final sorted = events.toList()..sort(compareStockEvents);
  var stock = 0;
  for (final e in sorted) {
    stock = switch (e.kind) {
      MovementKind.entry => stock + e.quantity,
      MovementKind.exit => stock - e.quantity,
      MovementKind.inventory => e.quantity,
    };
  }
  return stock < 0 ? 0 : stock;
}

/// Ordre chronologique des mouvements, puis par identifiant en cas d'égalité,
/// pour que tous les appareils obtiennent le même résultat.
int compareStockEvents(StockEvent a, StockEvent b) {
  final byDate = a.occurredAt.compareTo(b.occurredAt);
  return byDate != 0 ? byDate : a.id.compareTo(b.id);
}
