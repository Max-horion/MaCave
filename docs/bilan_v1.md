# Ma Cave — bilan de la V1

Bilan établi le 2026-10-08 à la fin du lot 6, **mis à jour le 2026-10-10 à la clôture de la V1**, par rapport au cahier des charges v0.8 (CDC). Version installée : 0.1.0.

## En bref

- **V1 terminée le 2026-10-10** (décision du porteur).
- **Toutes les fonctions V1 du CDC §11 sont faites**, vérifiées sur le téléphone de référence (OnePlus 13, Android 16) et reportées dans le CDC v0.8.
- **Les deux conditions de fin de la V1 sont remplies** (décision du porteur du 2026-10-08) :
  - Android 10 vérifié sur un Xiaomi Mi 9T Pro : autorisation d'écrire dans Documents, sauvegarde, refus et refus définitif (un bug trouvé et corrigé à cette occasion) ;
  - codes-barres lus par **ZXing** (libre), essayé et approuvé par le porteur (lot 7).
- **Moteur de texte choisi** : **Tesseract** (libre). **ML Kit est retiré** : l'appli est **entièrement libre** (GPL v3 ou ultérieure, sans exception).
- Réalisé en 6 jours (5 au 10 octobre 2026), 7 lots + 1 lot de démarrage, 66 commits, 339 tests automatiques, budget nul.

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
| Scan code-barres + Open Food Facts | 5a, 5b, 7 | fait (ZXing, libre ; code-barres associable dans les deux sens) |
| Reconnaissance de texte | 5c, 5d, 7 | fait — Tesseract retenu après une bêta face à ML Kit ; lignes regroupées et remises en forme (2026-10-10) |
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
| Textes regroupés pour la traduction | tous | fait (481 textes dans `app_fr.arb`, tous utilisés) |
| Note personnelle, favori, commentaire | 1, 2 | fait |

## 3. Exigences non fonctionnelles (CDC §9)

| Exigence | État |
|---|---|
| Hors ligne | Respectée : seules la synchro et Open Food Facts utilisent le réseau ; la lecture des codes et du texte est embarquée. |
| Langue, formats | Respectée (français, dates et nombres selon la langue de l'appareil). |
| Rapidité de saisie (< 30 s, < 3 manipulations) | **Non mesurée.** Le scan et le pré-remplissage vont dans ce sens ; à chronométrer pendant la saisie de la cave. |
| Performances (ouverture < 2 s, recherche instantanée avec des milliers de lots) | **Respectées sur le PC** (mesuré le 2026-10-10, `tool/perf/cave_perf_test.dart`, 5 000 références et 21 000 mouvements) : ouverture 0,2 s, recherche < 0,1 s, « −1 » 0,16 s, photo → « Déjà dans votre cave ? » 0,3 s (46 s avant optimisation), sauvegarde 0,6 s, fusion de synchro 1 s. Un vieux téléphone serait 3 à 5 fois plus lent : à mesurer avant une diffusion. |
| Ergonomie (une main, peu de lumière) | Respectée : boutons ≥ 56 dp, thèmes clair/sombre, lampe torche, taille du texte réglable. |
| Compatibilité (Android 8 minimum) | Android 10, 14 et 16 vérifiés (Android 10 : autorisation de stockage, refus définitif guidé vers les réglages). Android 8 et 9 non essayés (même code qu'Android 10). |
| Fiabilité (aucune perte de données) | Respectée par conception (transactions, ETag, sauvegardes, fusion testée). Un incident au lot 0 (`flutter install`) a effacé 2 fiches de test : cause supprimée (`tool/installer.sh`). Cas rares connus, non traités : voir §5. |
| Sécurité | Respectée : mot de passe du serveur dans le coffre d'Android. |
| Confidentialité | Respectée : seul un code-barres de 8 à 14 chiffres part vers Open Food Facts, signalé et désactivable. |
| Maintenabilité | Respectée : 339 tests automatiques, banc d'essai de performances, code entièrement relu le 2026-10-10 (doublons supprimés), commentaires en français, CLAUDE.md et `docs/architecture.md` à jour. |

## 4. Écarts au CDC décidés en cours de route

Tous reportés dans le CDC (v0.6 et v0.7) :

- pas de tâches de fond : sauvegarde et synchro appli ouverte, erreur > 24 h affichée dans l'appli au lieu d'une notification ;
- sauvegardes sur le téléphone **et** sur le serveur en mode synchronisé, 3 conservées par défaut (réglable), fréquence et dossier au choix ;
- purge manuelle limitée aux mouvements de plus de 30 jours ;
- appellation facultative pour le vin ; fiche incomplète enregistrée avec le marqueur « à compléter » ;
- doublons cherchés aussi à partir d'Open Food Facts et de la photo d'étiquette ;
- synchronisation automatique activée par défaut, désactivable ;
- volumes proposés de 10 cl à 6 l (fûts) ;
- Tesseract et ZXing à la place de ML Kit : appli entièrement libre, licence sans exception ;
- V1 conditionnée à l'essai sur Android 8 à 10 et à un lecteur de codes-barres libre approuvé.

## 5. Limites connues

- **Reconnaissance de texte** : approximative sur les étiquettes courbes ; un nom en **arc de cercle prononcé** reste illisible (il faudrait redresser l'image). Les mots écrits côte à côte et « Château », « Domaine »… sont regroupés, et les lignes se corrigent ou s'ajoutent d'un toucher. Optimisation possible plus tard.
- **Synchronisation, cas très rares** (plusieurs appareils restés hors ligne longtemps) : un mouvement ajouté sur un lot entre-temps fusionné avec son doublon, ou sur un lot purgé automatiquement ailleurs, ne serait pas compté. À revoir s'il se présente.
- **Réinstallation** : Android empêche l'appli de revoir ses anciennes sauvegardes dans Documents ; il faut passer par « Restaurer depuis un fichier ».
- **Taille** : APK arm64 de 36 Mo (55 Mo avant le retrait de ML Kit), surtout le code natif de Tesseract.

## 6. Décisions prises à la fin de la V1

### Moteurs de reconnaissance (CDC §10, §12)

Après la bêta, le porteur a jugé ML Kit et Tesseract tous deux médiocres sur les étiquettes, ML Kit un peu meilleur. **Tesseract est retenu** pour que l'appli soit 100 % libre, et **ZXing** remplace ML Kit pour les codes-barres (lot 7). ML Kit est retiré (2026-10-10) : plus d'exception dans `COPYING.md`, plus aucune classe Google dans l'APK (vérifié), F-Droid devient possible, APK allégé de 19 Mo.

## 7. Décisions à venir

### Diffusion (CDC §10, §12)

Canal à choisir : dépôt public avec APK, F-Droid ou Play Store (payant). Avant toute diffusion publique : mesurer les performances sur un vieux téléphone, puis passer le dépôt GitHub en public (décision du porteur). Le dépôt est privé en attendant.

### Suite du projet

1. Usage réel : finir la saisie de la cave, inventaire complet, synchro avec un deuxième appareil.
2. Diffusion (canal à choisir).
3. V2 (CDC §11), dans un ordre à décider : emplacements, période de consommation, accords mets et vins, statistiques dans le temps, photos d'étiquette, export PDF, application PC.
4. Plus tard : lecture des noms en arc de cercle (redressement de l'image).
