import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/layout.dart';
import '../drink/drink_detail_screen.dart';

/// Référence affichée à côté de la liste quand la fenêtre est large (PC) ;
/// null : aucune.
class SelectedDrinkNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? drinkId) => state = drinkId;
}

final selectedDrinkProvider = NotifierProvider<SelectedDrinkNotifier, String?>(
  SelectedDrinkNotifier.new,
);

/// Ouvre la fiche [drinkId]. Fenêtre étroite (téléphone) : écran par-dessus
/// l'écran courant, ou à sa place si [replace] (formulaire enregistré).
/// Fenêtre large : retour à la liste, fiche affichée à droite.
Future<void> openDrink(
  BuildContext context,
  WidgetRef ref,
  String drinkId, {
  bool replace = false,
}) async {
  if (isWideLayout(context)) {
    ref.read(selectedDrinkProvider.notifier).select(drinkId);
    Navigator.popUntil(context, (route) => route.isFirst);
    return;
  }
  final route = MaterialPageRoute<void>(
    builder: (_) => DrinkDetailScreen(drinkId: drinkId),
  );
  if (replace) {
    await Navigator.pushReplacement(context, route);
  } else {
    await Navigator.push(context, route);
  }
}
