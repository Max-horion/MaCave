import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/providers.dart';

// Choix du lecteur de codes-barres (lot 7) : ZXing (libre, Apache 2.0, par
// défaut depuis le 2026-10-09, approuvé par le porteur) ou ML Kit (Google,
// non libre, gardé pour comparaison pendant l'essai). Propre à l'appareil
// (préférences locales).

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
        BarcodeEngine.zxing;
  }

  Future<void> setEngine(BarcodeEngine engine) async {
    await ref.read(localStoreProvider).setString(_key, engine.name);
    ref.invalidateSelf();
    await future;
  }
}
