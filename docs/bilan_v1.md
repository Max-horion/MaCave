# Ma Cave — bilan de la V1

Bilan établi le 2026-10-08, à la fin du lot 6, par rapport au cahier des charges v0.6 (CDC). Version installée : 0.1.0 (`main` = commit du 2026-10-08).

## En bref

- **Toutes les fonctions V1 du CDC §11 sont faites**, vérifiées sur le téléphone de référence (OnePlus 13, Android 16) et reportées dans le CDC v0.6.
- **Une seule vérification reste ouverte** : l'autorisation d'écriture dans Documents sur Android 8 à 10 (codée, jamais essayée faute d'appareil). Le lot 6, et donc la V1, seront déclarés terminés après cet essai.
- **Une décision reste à prendre** : le moteur de reconnaissance de texte (CDC §12), après une bêta plus longue.
- Réalisé en 4 jours (5 au 8 octobre 2026), 6 lots + 1 lot de démarrage, 53 commits, budget nul.

## 1. Les critères de réussite (CDC §1.3)

| Critère | État |
|---|---|
| Toutes les références de la cave répertoriées et catégorisées | **Outil prêt, saisie en cours.** Import Vivino fait (31 références, 32 lots, 95 bouteilles), fiches complétées à la main ; le reste de la cave est à enregistrer par le porteur. Le marqueur « à compléter » sert de liste de travail. |
| Inventaire accessible sur plusieurs appareils (Nextcloud) | **Fait.** Synchronisation vérifiée avec le Nextcloud du porteur (envoi automatique, mode avion puis reprise) ; convergence de plusieurs appareils vérifiée par les tests (appareils simulés). Pas encore utilisée au quotidien avec un deuxième appareil réel. |
| Inventaire conforme au contenu réel de la cave | **Outil prêt.** Inventaire guidé et corrections de stock disponibles ; à faire par le porteur une fois la saisie terminée. |

## 2. Fonctions V1 (CDC §11)

| Fonction | Lot | État |
|---|---|---|
| Types, familles, caractéristiques (création, renommage, suppression) | 1, 6 | fait |
| Fiche référence et lots (champs V1 du §4.1) | 1, 2 | fait |
| Ajout manuel, plusieurs bouteilles en une fois | 2 | fait |
| Scan code-barres + Open Food Facts | 5a, 5b | fait (code-barres associable dans les deux sens) |
| Reconnaissance de texte, bêta à deux moteurs + mode comparaison | 5c, 5d | fait — choix du moteur en attente |
| Lampe torche, détection des doublons | 5a, 5e | fait |
| Retrait manuel, « −1 », retrait par scan, annulation | 2, 5a | fait |
| Historique des mouvements (motifs, commentaire) | 3 | fait |
| Lots épuisés conservés, correction de stock, inventaire guidé | 2, 3 | fait |
| Recherche plein texte, filtres, tris, liste | 2 | fait |
| Statistiques de base (sans valeur) | 3 | fait |
| Import Vivino, import et export CSV (+ modèle à remplir dans un tableur) | 3, 6 | fait |
| Fonctionnement hors ligne | tous | fait |
| Mode local ou synchronisé (WebDAV), traitement des erreurs | 4 | fait |
| Sauvegarde automatique, purge, paramètres | 4, 6 | fait |
| Premier lancement | 6 | fait (vérifié sur un appareil neuf, Android 14, le 2026-10-08) |
| Textes regroupés pour la traduction | tous | fait (487 textes dans `app_fr.arb`) |
| Note personnelle, favori, commentaire | 1, 2 | fait |

## 3. Exigences non fonctionnelles (CDC §9)

| Exigence | État |
|---|---|
| Hors ligne | Respectée : seules la synchro et Open Food Facts utilisent le réseau ; la lecture des codes et du texte est embarquée. |
| Langue, formats | Respectée (français, dates et nombres selon la langue de l'appareil). |
| Rapidité de saisie (< 30 s, < 3 manipulations) | **Non mesurée.** Le scan et le pré-remplissage vont dans ce sens ; à chronométrer pendant la saisie de la cave. |
| Performances (ouverture < 2 s, recherche instantanée avec des milliers de lots) | **Non mesurées.** Index plein texte FTS5 et stock en cache prévus pour, mais aucun test avec des milliers de lots : à faire (base de test générée) avant une diffusion. |
| Ergonomie (une main, peu de lumière) | Respectée : boutons ≥ 56 dp, thèmes clair/sombre, lampe torche, taille du texte réglable. |
| Compatibilité (Android 8 minimum) | Android 14 et 16 vérifiés. **Android 8 à 10 non essayé** (autorisation de stockage). |
| Fiabilité (aucune perte de données) | Respectée par conception (transactions, ETag, sauvegardes, fusion testée). Un incident au lot 0 (`flutter install`) a effacé 2 fiches de test : cause supprimée (`tool/installer.sh`). Cas rares connus, non traités : voir §5. |
| Sécurité | Respectée : mot de passe du serveur dans le coffre d'Android. |
| Confidentialité | Respectée : seul un code-barres de 8 à 14 chiffres part vers Open Food Facts, signalé et désactivable. |
| Maintenabilité | Respectée : 333 tests automatiques, commentaires en français, CLAUDE.md et `docs/architecture.md` à jour. |

## 4. Écarts au CDC décidés en cours de route

Tous reportés dans le CDC v0.6 :

- pas de tâches de fond : sauvegarde et synchro appli ouverte, erreur > 24 h affichée dans l'appli au lieu d'une notification ;
- sauvegardes sur le téléphone **et** sur le serveur en mode synchronisé, 3 conservées par défaut (réglable), fréquence et dossier au choix ;
- purge manuelle limitée aux mouvements de plus de 30 jours ;
- appellation facultative pour le vin ; fiche incomplète enregistrée avec le marqueur « à compléter » ;
- doublons cherchés aussi à partir d'Open Food Facts et de la photo d'étiquette ;
- synchronisation automatique activée par défaut, désactivable ;
- volume 6 l ajouté (fûts).

## 5. Limites connues

- **Reconnaissance de texte** : approximative sur les étiquettes courbes et les noms en arc de cercle, pour les deux moteurs. Les lignes lues se corrigent d'un toucher. Optimisation reportée.
- **Synchronisation, cas très rares** (plusieurs appareils restés hors ligne longtemps) : un mouvement ajouté sur un lot entre-temps fusionné avec son doublon, ou sur un lot purgé automatiquement ailleurs, ne serait pas compté. À revoir s'il se présente.
- **Réinstallation** : Android empêche l'appli de revoir ses anciennes sauvegardes dans Documents ; il faut passer par « Restaurer depuis un fichier ».
- **Taille** : APK arm64 de 55 Mo, dont environ 46 Mo de code natif pour ML Kit et Tesseract.

## 6. Décisions à venir

### Moteur de reconnaissance de texte (CDC §12)

La bêta continue pendant la saisie de la cave (compteur du mode « Comparer »). Premiers résultats : ML Kit légèrement meilleur, Tesseract un peu plus lent, résultats proches.

**Orientation du porteur (2026-10-08)** : accepter les performances un peu moindres de Tesseract si cela permet une appli **100 % open source**.

⚠️ **Choisir Tesseract ne suffira pas pour être 100 % open source** : ML Kit sert aussi à **lire les codes-barres** (`mobile_scanner`). Il faudrait donc aussi remplacer le lecteur de codes-barres par une bibliothèque libre, par exemple fondée sur ZXing (à évaluer : vitesse, lecture dans le noir, codes abîmés). Gains si tout ML Kit disparaît :
- l'exception de liaison de `COPYING.md` peut être retirée (GPL v3 pure, CDC §10) ;
- F-Droid devient possible comme canal de diffusion ;
- l'APK s'allège.

### Diffusion (CDC §10, §12)

Canal à choisir après la bêta des moteurs : dépôt public avec APK, F-Droid (seulement sans ML Kit) ou Play Store (payant). Avant toute diffusion publique : essai sur Android 8 à 10, test de performances avec une grosse cave, et passage du dépôt GitHub en public (décision du porteur).

### Suite du projet

1. Terminer la V1 : essai sur Android 8, 9 ou 10.
2. Usage réel : saisir la cave, inventaire complet, synchro avec un deuxième appareil.
3. Choix du moteur, puis éventuel remplacement du lecteur de codes-barres.
4. V2 (CDC §11), dans un ordre à décider : emplacements, période de consommation, accords mets et vins, statistiques dans le temps, photos d'étiquette, export PDF, application PC.
