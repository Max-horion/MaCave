/// Énumérations du modèle de données.
///
/// ATTENTION : le *nom* de chaque valeur est enregistré tel quel dans la base
/// (et donc synchronisé entre appareils). Renommer une valeur casse les bases
/// existantes : ajouter une valeur est possible, renommer ou supprimer non.
library;

/// Profil de champs d'un type de boisson : indique quels champs de la fiche
/// sont affichés et obligatoires (CDC §4.1). Un type créé par l'utilisateur
/// choisit l'un de ces profils.
enum FieldProfile { wine, beer, spirit, soft }

/// Nature d'un mouvement de stock (CDC §4.2).
enum MovementKind {
  /// Entrée : `quantity` bouteilles ajoutées.
  entry,

  /// Sortie : `quantity` bouteilles retirées.
  exit,

  /// Ajustement d'inventaire : `quantity` est le nombre de bouteilles
  /// **constaté**, pas une différence (voir docs/architecture.md §3).
  inventory,
}

/// Motif d'une sortie (CDC §6.3) ; « consommée » par défaut.
enum ExitReason { consumed, gifted, broken }
