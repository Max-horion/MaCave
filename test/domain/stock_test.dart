import 'package:cave/domain/enums.dart';
import 'package:cave/domain/stock.dart';
import 'package:flutter_test/flutter_test.dart';

StockEvent entry(String id, int at, int q) =>
    StockEvent(id: id, occurredAt: at, kind: MovementKind.entry, quantity: q);
StockEvent exit(String id, int at, int q) =>
    StockEvent(id: id, occurredAt: at, kind: MovementKind.exit, quantity: q);
StockEvent inventory(String id, int at, int counted) => StockEvent(
  id: id,
  occurredAt: at,
  kind: MovementKind.inventory,
  quantity: counted,
);

void main() {
  test('sans mouvement, le stock est nul', () {
    expect(computeStock([]), 0);
  });

  test('les entrées s\'ajoutent et les sorties se retirent', () {
    expect(
      computeStock([entry('a', 1, 6), exit('b', 2, 1), exit('c', 3, 2)]),
      3,
    );
  });

  test('l\'ordre de la liste n\'a pas d\'importance, seule la date compte', () {
    final events = [exit('c', 3, 2), entry('a', 1, 6), inventory('b', 2, 4)];
    expect(computeStock(events), 2);
    expect(computeStock(events.reversed), 2);
  });

  test('un inventaire remplace le stock par le nombre constaté', () {
    expect(computeStock([entry('a', 1, 6), inventory('b', 2, 4)]), 4);
  });

  test('les mouvements postérieurs à l\'inventaire s\'appliquent', () {
    expect(
      computeStock([
        entry('a', 1, 6),
        inventory('b', 2, 4),
        exit('c', 3, 1),
        entry('d', 4, 2),
      ]),
      5,
    );
  });

  group('fusion de deux appareils (docs/architecture.md §3)', () {
    // 5 bouteilles. Le téléphone enregistre une sortie ; le PC fait
    // l'inventaire et compte les bouteilles présentes.
    final base = entry('a', 1, 5);

    test('sortie avant le comptage : déjà incluse dans l\'inventaire', () {
      expect(computeStock([base, exit('tel', 2, 1), inventory('pc', 3, 4)]), 4);
    });

    test('sortie après le comptage : retirée de l\'inventaire', () {
      expect(computeStock([base, inventory('pc', 2, 5), exit('tel', 3, 1)]), 4);
    });
  });

  test('deux mouvements à la même date sont départagés par identifiant', () {
    // Même date : l'inventaire « z » passe après la sortie « a ».
    expect(
      computeStock([entry('0', 1, 5), inventory('z', 2, 3), exit('a', 2, 1)]),
      3,
    );
    // L'inventaire « a » passe avant la sortie « z ».
    expect(
      computeStock([entry('0', 1, 5), inventory('a', 2, 3), exit('z', 2, 1)]),
      2,
    );
  });

  test('le stock ne descend jamais sous zéro', () {
    expect(
      computeStock([entry('a', 1, 1), exit('b', 2, 1), exit('c', 3, 1)]),
      0,
    );
  });
}
