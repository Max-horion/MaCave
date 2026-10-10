import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Fenêtre de confirmation : [message] (et [title]), « Annuler » et le
/// bouton [action]. Vrai si l'utilisateur confirme.
Future<bool> confirm(
  BuildContext context, {
  String? title,
  required String message,
  required String action,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Message bref en bas de l'écran. `persist: false` : sinon, avec une
/// action, il ne disparaîtrait jamais (Flutter 3.3x).
void showMessage(BuildContext context, String text, {SnackBarAction? action}) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text), action: action, persist: false));
}

/// Réglage d'une quantité avec deux gros boutons − et + (utilisable d'une
/// main, CDC §9).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canDecrease = value > min;
    final canIncrease = max == null || value < max!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          iconSize: 32,
          tooltip: l10n.actionDecrease,
          onPressed: canDecrease ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 80,
          child: Text(
            '$value',
            key: const Key('quantity-value'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        IconButton.filledTonal(
          iconSize: 32,
          tooltip: l10n.actionIncrease,
          onPressed: canIncrease ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Note personnelle sur 5 étoiles. Toucher l'étoile déjà choisie efface la note.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, this.onChanged});

  final int? value;

  /// Null : affichage seul.
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.primary;
    final current = value ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          onChanged == null
              ? Icon(
                  i <= current ? Icons.star : Icons.star_border,
                  color: color,
                )
              : IconButton(
                  tooltip: l10n.ratingStars(i),
                  onPressed: () => onChanged!(i == current ? null : i),
                  icon: Icon(
                    i <= current ? Icons.star : Icons.star_border,
                    color: color,
                  ),
                ),
      ],
    );
  }
}

/// Message centré (liste vide, aucun résultat…).
class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
