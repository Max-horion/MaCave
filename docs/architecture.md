# Architecture technique — Ma Cave

> **Statut : validée le 5 octobre 2026.**
> Référence fonctionnelle : [cahier_des_charges_v0.5.md](cahier_des_charges_v0.5.md) (CDC).

## 1. Bibliothèques retenues

Versions vérifiées sur pub.dev le 5 octobre 2026. Toutes gratuites et open source (CDC §10).

| Besoin | Bibliothèque | Pourquoi | Lot |
|---|---|---|---|
| Base SQLite | **drift** + **drift_flutter** | Requêtes vérifiées à la compilation, migrations de schéma encadrées, requêtes « vivantes » (l'écran se met à jour quand la base change), tests sur une base en mémoire. Fonctionne aussi sous Windows/Linux (future appli PC). SQLite embarqué avec FTS5 (recherche plein texte). | 1 |
| Gestion d'état | **flutter_riverpod** (sans génération de code) | Relie la base aux écrans proprement, facile à tester (on remplace la vraie base par une base de test). Plus structuré que `provider`, qui n'évolue plus. | 1 |
| Identifiants uniques | **uuid** (v7) | Identifiant de chaque fiche et mouvement, créé hors ligne sans risque de doublon ; la v7 est triable par date. | 1 |
| WebDAV | **client maison sur `http`** | WebDAV ne demande que 5 verbes (PROPFIND, GET, PUT, MOVE, MKCOL). Le paquet `webdav_client` n'est plus maintenu (2024) ; écrire ~200 lignes nous donne la main sur les en-têtes `If-Match` / `If-None-Match` indispensables au contrôle de version, et c'est testable avec un faux serveur. | 4 |
| Mot de passe serveur | **flutter_secure_storage** | Coffre sécurisé Android (Keystore), jamais en clair (CDC §9). | 4 |
| ~~Tâches de fond~~ | ~~workmanager + flutter_local_notifications~~ | **Abandonné en V1** (décision du 05/10/2026) : tout se fait appli ouverte ; une erreur de plus de 24 h est signalée dans l'appli (indicateur rouge). | — |
| Réseau disponible ? | **connectivity_plus** | Distinguer « en attente » (pas de réseau, pas une erreur) d'une vraie erreur. | 4 |
| Scan codes-barres / QR | **mobile_scanner** | Lecture en direct avec ML Kit (version embarquée : pas de réseau nécessaire, +3 à 10 Mo par architecture), lampe torche intégrée, bien maintenu. | 5 |
| Photo d'étiquette | **camera** | Prise de vue dans l'appli avec contrôle de la lampe torche. | 5 |
| Reconnaissance de texte | **google_mlkit_text_recognition** et **flutter_tesseract_ocr** derrière une interface commune `TextRecognizer` | Moteur interchangeable + mode comparaison (CDC §10). Tesseract nécessite d'embarquer le dictionnaire français (quelques Mo dans l'APK). | 5 |
| Open Food Facts | **http** (appel direct à l'API) | Un seul appel « produit par code-barres » : le paquet officiel serait surdimensionné. | 5 |
| Requêtes HTTP | **http** | Base du client WebDAV maison. | 4 |
| Fichiers | **path_provider**, **file_picker**, **share_plus**, **csv** | Emplacement de la base, choix du fichier à importer / dossier de sauvegarde, partage d'un export. | 3–4 |
| Traductions | **flutter_localizations** + **intl** (`gen-l10n`) | Déjà en place (lot 0). | 0 |

Les bibliothèques sont ajoutées au moment du lot qui en a besoin, pas avant.

## 2. Organisation du code

```
lib/
  main.dart, app.dart        démarrage, thèmes, langues, navigation
  l10n/                      app_fr.arb (tous les textes) + code généré
  theme/                     thèmes clair et sombre
  data/                      base drift : tables, migrations, requêtes (DAO)
  domain/                    logique pure, sans Flutter : calcul du stock,
                             règles de fusion, import Vivino/CSV, analyse d'étiquette
  sync/                      client WebDAV, moteur de synchronisation, sauvegardes
  scan/                      codes-barres, moteurs de reconnaissance de texte
  features/<écran>/          écrans et leurs providers Riverpod
test/                        miroir de lib/ ; priorité à domain/, data/ et sync/
assets/                      liste des appellations INAO, etc.
```

Règle : les écrans n'accèdent jamais directement à SQL ; ils passent par les providers, qui passent par les DAO. Toute la logique délicate (stock, fusion) est dans `domain/` et testée sans téléphone.

## 3. Schéma de la base

Principes communs à toutes les tables synchronisées :

- `id` : UUID texte, créé sur l'appareil ;
- `updated_at` : date de dernière modification (UTC, millisecondes) et `updated_by` : identifiant de l'appareil (départage deux modifications à la même milliseconde) ;
- `deleted_at` : **suppression logique** (« pierre tombale »). Une suppression doit se propager aux autres appareils ; si on effaçait la ligne, la synchro suivante la ferait revenir. Les pierres tombales sont effacées pour de bon après un délai (par ex. 1 an).

```
meta                     cave_id (UUID de la cave), version de schéma (PRAGMA user_version)

drink_types              id, name, field_profile, default_volume_ml, sort_order, …
  └ characteristic_families   id, type_id, name, sort_order, …
       └ characteristics      id, family_id, name, sort_order, …

drinks (= références)    id, type_id (vide = « sans catégorie »), name, producer,
                         appellation, region, country, grapes, abv, rating (0–5),
                         favorite, comment, needs_completion, food_pairing (V2),
                         created_at, …
drink_characteristics    drink_id, characteristic_id, …     (lien plusieurs-à-plusieurs)

lots                     id, drink_id, vintage (vide = sans millésime), volume_ml,
                         barcode, stock (cache), location (V2), drink_from (V2),
                         drink_before (V2), photo_path (V2), created_at, …
movements                id, lot_id, occurred_at, kind (in | out | inventory),
                         quantity, reason (consumed | gifted | broken), comment,
                         device_id, deleted_at

settings                 key, value (JSON), updated_at   réglages communs à tous les appareils
drinks_fts               index plein texte (nom, producteur, appellation, région),
                         insensible aux accents : « saint emilion » trouve « Saint-Émilion »
```

Points clés :

- **`field_profile`** (vin, bière, spiritueux, soft) indique quels champs du CDC §4.1 afficher. Un type créé par l'utilisateur choisit un profil.
- **Stock et inventaire.** Une entrée ou une sortie enregistre une quantité. Un **ajustement d'inventaire enregistre le nombre de bouteilles constaté**, pas une différence. Stock d'un lot = dernier inventaire + entrées − sorties postérieures. Ainsi, si le téléphone enregistre une sortie pendant que le PC fait l'inventaire, la fusion donne le bon résultat. La colonne `stock` n'est qu'un cache recalculé (après chaque mouvement et après chaque synchro) pour que la liste reste instantanée avec des milliers de lots.
- **Date de dernière entrée** : calculée à partir des mouvements, pas stockée.
- **Un code-barres, plusieurs lots** : `barcode` est indexé mais pas unique (CDC §6.2).
- **Photos (V2)** : seulement un chemin de fichier, jamais l'image dans la base.
- **Second utilisateur** : `updated_by` / `device_id` suffisent à le préparer sans refonte.
- **Données propres à l'appareil** (ETag connu, identifiant d'appareil, thème, journal des erreurs) : hors de la base synchronisée (préférences locales), pour que le fichier partagé soit identique d'un appareil à l'autre. Le mot de passe va dans le coffre sécurisé.
- **Appellations INAO** : fichier embarqué dans `assets/`, en lecture seule, pas dans la base.

## 4. Principe de synchronisation (lot 4)

Le serveur contient un seul fichier, `cave.sqlite`, dans le dossier choisi. Aucun service à installer côté serveur (CDC §8.1).

### Un cycle de synchronisation

1. **Télécharger si nécessaire** : `GET cave.sqlite` avec `If-None-Match: <dernier ETag connu>`. Réponse « 304 inchangé » → passer directement à l'étape 4.
2. **Vérifier le fichier reçu** (copie temporaire) : intégrité SQLite (`PRAGMA integrity_check`), même `cave_id`, version de schéma ≤ celle de l'appli.
   - fichier endommagé → renommé côté serveur (`MOVE` vers `cave.sqlite.endommage-<date>`), puis remplacé par la version de l'appareil, avec un message ;
   - version plus récente → synchro suspendue, invitation à mettre l'appli à jour ;
   - `cave_id` différent → ce n'est pas la même cave : on ne fusionne jamais, l'utilisateur choisit (CDC §8.2).
3. **Fusionner dans la base locale, en une seule transaction** (tout ou rien, même en cas de coupure de batterie) :
   - **mouvements** : ajoutés s'ils sont inconnus (identifiés par leur UUID). Ils s'additionnent donc sans perte et sans doublon ; une annulation est une pierre tombale qui se propage et l'emporte toujours, quelles que soient les horloges (un mouvement n'est jamais modifié autrement) ;
   - **fiches** (types, caractéristiques, références, lots, réglages) : ligne par ligne, **la plus récente l'emporte** (`updated_at`, puis `updated_by` en cas d'égalité) ; une suppression est une modification comme une autre ;
   - **lots en double** (même référence, millésime et volume créés hors ligne sur deux appareils) : regroupés, leurs mouvements rattachés au lot conservé — le plus ancien (`created_at`, puis `id`), pour que tous les appareils fassent le même choix ;
   - recalcul des stocks en cache et de l'index de recherche.
   - Fait au lot 4b : `lib/sync/merge.dart` (`mergeCaveFile`), qui indique aussi si la base locale a des modifications à envoyer (`localAhead`).
4. **Envoyer** s'il y a des modifications locales : copie cohérente de la base (`VACUUM INTO` un fichier temporaire — on n'envoie jamais le fichier en cours d'utilisation), puis
   - `PUT` avec `If-Match: <ETag lu à l'étape 1>` : le serveur refuse (« 412 ») si quelqu'un a écrit entre-temps → **on n'écrase jamais**, on recommence au début du cycle (3 essais maximum, puis nouvelle tentative plus tard) ;
   - premier envoi : `If-None-Match: *` (refusé si un fichier est apparu entre-temps).
5. **Mémoriser le nouvel ETag** (relu par `PROPFIND` si le serveur ne le renvoie pas après le `PUT`).

Fait au lot 4c (`lib/sync/webdav.dart`, `lib/sync/sync_service.dart`). Après un « 304 inchangé », l'appli sait s'il faut envoyer en comparant l'empreinte de la base à celle mémorisée lors de la dernière synchro réussie. L'ETag est mémorisé dès la fusion faite : si l'envoi échoue, le cycle suivant n'a pas à retélécharger. Si le dossier n'existe pas au premier envoi, il est créé (`MKCOL`).

### Quand et comment

- À l'ouverture et au retour au premier plan, 10 secondes après une modification (regroupées), à la mise en arrière-plan si une modification attend, au retour du réseau, sur le bouton « Synchroniser maintenant » (`lib/sync/sync_controller.dart`). Appli ouverte seulement (pas de tâche de fond en V1).
- Pas de réseau → état « en attente », sans message. Erreurs → nouvelles tentatives espacées (1 min, 5 min, 30 min), puis à chaque ouverture ; pas de nouvel essai automatique si seul l'utilisateur peut corriger (identifiants, dossier, version, autre cave). Après 24 h d'erreur, l'indicateur passe au rouge (pas de notification en V1).
- Paramètres (adresse, identifiant, dossier) dans les préférences de l'appareil, mot de passe dans le coffre sécurisé ; ils ne sont enregistrés qu'après une première synchronisation réussie.
- La base locale n'est modifiée qu'à l'étape 3, en transaction : une erreur réseau ne peut jamais l'abîmer.
- Les horloges des appareils servent à départager les fiches : un téléphone synchronisé à l'heure réseau suffit pour un usage personnel.

### Hors fusion (CDC §8.2)

L'activation de la synchro sur une cave existante quand le serveur en a déjà une, différente, ne fusionne pas : « Utiliser la cave du serveur » ou « Remplacer la cave du serveur », toujours après sauvegarde automatique.

### Purge de l'historique

Une purge doit aussi se propager, sinon la fusion ferait revenir les mouvements effacés. La purge manuelle « avant une date » enregistre cette date dans `settings` (synchronisée) ; la fusion ignore les mouvements antérieurs. La purge automatique des lots épuisés passe par la suppression logique du lot.

Fait au lot 4e (`lib/data/history_purge.dart`) :
- avant d'effacer, chaque lot reçoit un **report de stock** : un inventaire, à la date de purge, du stock à cette date. Comme un inventaire remplace le stock, les mouvements antérieurs n'ont plus d'effet et peuvent disparaître sans changer aucun stock. Son identifiant est dérivé du lot et de la date : deux appareils qui purgent à la même date produisent le même report ;
- la date ne recule jamais : la fusion prend la plus récente des deux bases et la réécrit si besoin ;
- la purge manuelle est limitée aux mouvements de plus de 30 jours, pour laisser aux autres appareils le temps d'envoyer leurs mouvements ;
- purge automatique : lot, mouvements et référence sans autre lot supprimés logiquement ; réglage commun (`settings`), désactivé par défaut.
- Pas encore fait : l'effacement définitif des pierres tombales anciennes (gain de place faible, risque de résurrection par un appareil resté longtemps hors ligne).

## 5. Sauvegardes (lot 4)

Copie datée de la base (`VACUUM INTO`) + export CSV, N dernières conservées (3 par défaut, réglable). Toujours dans `Documents/Cave/Sauvegardes` sur l'appareil ; en mode synchronisé, la plus récente est **aussi** copiée dans le dossier `Sauvegardes` du serveur, qui en garde le même nombre (décision du 06/10/2026, `lib/sync/server_backups.dart`).

- **Fait au lot 4a** (`lib/sync/backup.dart`) : sauvegarde automatique appli ouverte (à l'ouverture et à la mise en arrière-plan, au plus une fois par jour, seulement si la base a changé), « Sauvegarder maintenant », partage, restauration avec vérification du fichier et sauvegarde de sécurité préalable.
- **Pas de tâche de fond** (workmanager) en V1, décision du 5 octobre 2026.
- **Android** : depuis Android 11, une appli peut écrire ses propres fichiers dans `Documents` sans autorisation, mais ne voit pas ceux des autres applis (ni les siens après une réinstallation) : la restauration passe alors par le sélecteur de fichiers. Android 8 à 10 demanderait l'autorisation de stockage (non gérée pour l'instant). Le choix d'un autre dossier par l'utilisateur (CDC §8.4) reste à faire.

## 6. Points d'attention

- **Mémoire du PC (8 Go)** : drift utilise la génération de code (`build_runner`), à lancer ponctuellement, Android Studio fermé.
- **Taille de l'APK** : ML Kit + Tesseract (dictionnaire français) ajoutent plusieurs Mo, acceptable pour la bêta.
- **Licence** : GPL v3 + exception de liaison ML Kit (CDC §10) ; fichier `LICENSE` à ajouter avant toute diffusion.
