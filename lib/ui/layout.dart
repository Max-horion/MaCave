import 'package:flutter/material.dart';

// Mise en page selon la largeur de la fenêtre, et non selon le système : un
// grand écran de téléphone ou une fenêtre de PC étroite gardent l'affichage
// du téléphone.

/// Largeur à partir de laquelle la liste et la fiche s'affichent côte à côte
/// (seuil « étendu » de Material 3).
const wideLayoutMinWidth = 840.0;

/// Largeur maximale du contenu d'un formulaire ou d'une page de texte : au
/// delà, les lignes deviennent trop longues à lire.
const readableMaxWidth = 720.0;

/// La fenêtre est assez large pour afficher la liste et la fiche ensemble.
bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideLayoutMinWidth;

/// Centre [child] dans une colonne de largeur lisible ([readableMaxWidth]).
/// Sans effet sur un téléphone, plus étroit.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: readableMaxWidth),
      child: child,
    ),
  );
}
