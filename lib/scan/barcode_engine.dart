import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/providers.dart';

// Choix du lecteur de codes-barres (lot 7) : ML Kit (Google, non libre) ou
// ZXing (libre, Apache 2.0). Propre à l'appareil (préférences locales).
// Essai du porteur pendant la saisie de sa cave : si ZXing convient, ML Kit
// sera retiré (exception de COPYING.md levée, CDC §12).

enum BarcodeEngine { mlKit, zxing }

final barcodeEngineProvider =
    AsyncNotifierProvider<BarcodeEngineNotifier, BarcodeEngine>(
      BarcodeEngineNotifier.new,
    );

class BarcodeEngineNotifier extends AsyncNotifier<BarcodeEngine> {
  static const _key = 'barcode_engine';

  @override
  Future<BarcodeEngine> build() async {
    final store = ref.watch(localStoreProvider);
    return BarcodeEngine.values.asNameMap()[await store.getString(_key)] ??
        BarcodeEngine.mlKit;
  }

  Future<void> setEngine(BarcodeEngine engine) async {
    await ref.read(localStoreProvider).setString(_key, engine.name);
    ref.invalidateSelf();
    await future;
  }
}
