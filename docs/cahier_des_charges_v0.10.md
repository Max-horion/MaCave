# Cahier des charges — Application de gestion de cave personnelle

*Version consolidée après arbitrage des questions ouvertes.*

> Converti depuis `cahier_des_charges_gestion_cave_v0.10.docx` (le .docx reste la source de référence).

| **Élément** | **Valeur** |
|---|---|
| Porteur du projet | Maxence Pithon |
| Version | 0.10 |
| Date | 13 octobre 2026 |
| Statut | Portage PC terminé ; diffusion 1.0.0 en préparation |

### Historique des versions

| **Version** | **Date** | **Contenu** |
|---|---|---|
| 0.1 | — | Première version : intention, types et sous-types, ajout et retrait, filtres, stockage Nextcloud. |
| 0.2 | 1er octobre 2026 | Structuration au format cahier des charges, questions Q1 à Q24, réponses du porteur. |
| 0.3 | 1er octobre 2026 | Arbitrage de toutes les questions ouvertes et des points « à compléter » ; ajout du modèle de données, des paramètres, des choix techniques et du journal des décisions. |
| 0.4 | 2 octobre 2026 | Relecture : diffusion future à d’autres utilisateurs, retrait par scan, synchronisation facultative (mode local seul) ; traitement des erreurs de synchronisation, changement de mode, tout serveur WebDAV, premier lancement, préparation des traductions. |
| 0.5 | 5 octobre 2026 | Retours de la V1 en cours : appellation facultative pour le vin (4.1, 6.7) ; une fiche incomplète est enregistrée avec le marqueur « à compléter », jamais refusée. |
| 0.6 | 7 octobre 2026 | Décisions des lots 4 à 6 de la V1 : synchronisation et sauvegarde application ouverte, sans tâche de fond (8.3, 8.4) ; sauvegardes sur l’appareil et sur le serveur ; purge manuelle limitée ; code-barres associable à un lot existant et doublons signalés aussi au scan et à la photo (6.2) ; cave du serveur reprise sur un appareil neuf (6.8) ; classification modifiable (6.1) ; import préparé dans un tableur avec consignes et fichier modèle (6.7) ; paramètres précisés (7) ; Open Food Facts désactivable (9) ; licence GPL v3 ou ultérieure (10). |
| 0.7 | 10 octobre 2026 | Fin de la bêta des moteurs de reconnaissance : ML Kit retiré, Tesseract pour le texte et ZXing pour les codes-barres, application entièrement libre et licence sans exception (7, 10, 11, 12) ; conditions de fin de la V1 (11, 12) ; lecture d’étiquette : lignes regroupées et ajout à la suite d’un champ (6.2) ; volumes proposés de 10 cl à 6 l (7) ; Android 8 à 10 vérifié (9). |
| 0.8 | 10 octobre 2026 | Clôture de la V1 : statut « V1 terminée » ; conditions de fin remplies (Android 10 vérifié, lecteur de codes-barres libre approuvé) ; points à rediscuter mis à jour (12). |
| 0.9 | 11 octobre 2026 | Début de la V2 par le portage PC, après l’usage réel de la V1 : Linux, puis Windows, avant les autres fonctions ; ni scan ni lecture d’étiquette sur PC (2.2, 10, 11) ; identifiants dans le trousseau du système sur PC (9) ; points à rediscuter mis à jour (12). |
| 0.10 | 13 octobre 2026 | Portage PC terminé, Linux et Windows (2.2, 11) ; diffusion privée de la version 1.0.0 sur Android, Windows et Linux : code source public, fichiers publiés sur GitHub, clé de signature Android, retours des utilisateurs (2.2, 9, 10, 11, 12) ; premier lancement : accueil terminé quand la cave est reprise du serveur (6.8) ; pas de partage de fichiers sur PC (10). |

## 1. Contexte et objectifs
### 1.1 Présentation du projet
Je suis un particulier qui cherche à gérer sa cave personnelle. Ce document cadre le cahier des charges d’une application permettant de tenir l’inventaire de la cave. L’application pourra être diffusée à d’autres utilisateurs dans un second temps, pour une utilisation dans un cadre privé.
### 1.2 Situation actuelle
Le nombre de références actuel n’est pas connu. La cave est suivie de manière non exhaustive sur l’application Vivino : le suivi a été arrêté lorsque la limite de références d’un compte gratuit a été atteinte. Cet existant sera importé (voir 6.7), puis complété par un inventaire initial.
### 1.3 Objectifs et critères de réussite
L’application sera réussie si :
- la totalité des références de la cave est répertoriée et catégorisée ;
- l’inventaire est accessible sur plusieurs appareils grâce à une synchronisation sur le cloud personnel (Nextcloud) ;
- l’inventaire répertorié dans l’application correspond au contenu réel de la cave.
## 2. Périmètre
### 2.1 Utilisateurs
Un seul utilisateur. L’ajout d’un second utilisateur pourra être envisagé dans une version ultérieure, sans être prévu à ce stade.
### 2.2 Supports
- **V1 :** application Android.
- **V2 :** application PC (Linux, puis Windows) utilisant la même base de données, à partir du même code, réalisée avant les autres fonctions de la V2 (voir 10) ; terminée le 13/10/2026.
- **Versions diffusées :** numérotées 1.0.0, 1.1.0, etc. La 1.0.0, première version diffusée, réunit la V1 et l’application PC ; V1 et V2 désignent les étapes du projet, pas des numéros de version.
### 2.3 Hors périmètre
L’application ne fera pas :
- de vente, ni d’achat en ligne (aucun lien vers des cavistes ou sites marchands) ;
- de partage public, ni de fonction de réseau social (notes communautaires, recommandations) ;
- de gestion, par un même utilisateur, de caves appartenant à d’autres personnes : chaque utilisateur gère sa propre cave avec sa propre installation ;
- de suivi de cave professionnelle (déclarations, douane, facturation) ;
- de cote ou d’estimation de la valeur de marché des bouteilles ; les statistiques ne comportent aucune notion de valeur ;
- de gestion de plusieurs caves : une seule cave, l’emplacement servant à distinguer casiers et lieux ;
- de conseil de garde automatique : les dates idéales de consommation sont saisies par l’utilisateur.
## 3. Glossaire

| **Terme** | **Définition** |
|---|---|
| **Référence (= boisson)** | Fiche décrivant un produit : nom, producteur, appellation, région, type, caractéristiques… Ex. : Château Figeac, Saint-Émilion. Deux producteurs différents donnent deux références différentes. |
| **Lot** | Une référence déclinée par millésime (facultatif) et volume. Ex. : Château Figeac 2018, 75 cl ; « Bière X, sans millésime, 75 cl ». Le lot porte le stock et est toujours rattaché à sa référence. |
| **Bouteille** | Unité physique comptée dans le stock d’un lot. |
| **Volume** | Volume d’une bouteille (75 cl, magnum, 33 cl…). Remplace le terme « contenance ». |
| **Stock** | Nombre de bouteilles d’un lot. Ajouter des bouteilles à un lot existant augmente son stock, quelle que soit la date. Le stock d’une référence est la somme de ses lots. |
| **Mouvement** | Toute variation de stock enregistrée dans l’historique : entrée, sortie ou ajustement d’inventaire. |
| **Date d’ajout** | Information seulement : date de création du lot, complétée par la date de dernière entrée. N’intervient pas dans la définition du lot. |
| **Type** | Grande catégorie : vin, bière, spiritueux, soft. Une seule par référence. |
| **Famille de caractéristiques** | Une dimension de classement propre à un type : robe, style, sucre, parfum… (remplace la notion de « sous-type »). |
| **Caractéristique** | Une valeur dans une famille : rouge, IPA, cassis… |
| **Emplacement** | Lieu de rangement facultatif d’un lot (casier, rangée, autre pièce). |

## 4. Modèle de données
Trois objets principaux : la référence, le lot et le mouvement. Les champs affichés dépendent du type de la référence.
### 4.1 Champs par type
*O = obligatoire, F = facultatif, – = champ masqué pour ce type, auto = rempli par l’application.*

| **Champ** | **Version** | **Vin** | **Bière** | **Spiritueux** | **Soft** |
|---|---|---|---|---|---|
| **Référence** |  |  |  |  |  |
| Nom | V1 | O | O | O | O |
| Type | V1 | O | O | O | O |
| Caractéristiques | V1 | F | F | F | F |
| Producteur ou domaine | V1 | F | F | F | F |
| Appellation | V1 | F | – | F | – |
| Région, pays | V1 | O | F | F | – |
| Cépages | V1 | F | – | – | – |
| Degré d’alcool | V1 | F | F | F | – |
| Note personnelle (sur 5 étoiles) | V1 | F | F | F | F |
| Favori (case à cocher) | V1 | F | F | F | F |
| Commentaire libre | V1 | F | F | F | F |
| Marqueur « à compléter » | V1 | auto | auto | auto | auto |
| Accords mets et vins | V2 | F | F | F | – |
| **Lot** |  |  |  |  |  |
| Millésime | V1 | F | – | F | – |
| Volume (pré-rempli) | V1 | O · 75 cl | O · 75 cl | O · 70 cl | O · 1 l |
| Stock | V1 | O | O | O | O |
| Code-barres | V1 | auto / F | auto / F | auto / F | auto / F |
| Date d’ajout, date de dernière entrée | V1 | auto | auto | auto | auto |
| Emplacement | V2 | F | F | F | F |
| À boire à partir de / avant | V2 | F | F | F | – |
| Photo de l’étiquette | V2 | F | F | F | F |

**À noter :** Le volume est obligatoire puisqu’il définit le lot, mais il est pré-rempli selon le type (valeurs modifiables dans les paramètres) : il ne coûte donc aucune manipulation dans le cas courant.
**Champs non retenus :** prix d’achat, date et lieu d’achat, notes de dégustation détaillées (remplacées par la note personnelle).
### 4.2 Mouvements
Chaque variation de stock crée un mouvement dans l’historique :
- **Données automatiques :** date, lot concerné, quantité.
- **Nature :** entrée, sortie ou ajustement d’inventaire.
- **Motif de sortie :** consommée par défaut ; en option offerte ou cassée.
- **Commentaire :** facultatif (occasion, impression…).
Le stock d’un lot peut toujours être recalculé à partir de ses mouvements : c’est ce qui permet une synchronisation sans perte (voir 8.3).
### 4.3 Prévisions pour les versions suivantes
- Le champ photo existe dans la base dès la V1, laissé vide. Les photos seront stockées à part, en fichiers compressés dans un dossier Nextcloud, et non dans la base, qui reste légère à synchroniser.
- Un second utilisateur éventuel ne doit pas imposer de refonte de la base.
## 5. Scénarios d’usage

| **Situation** | **Déroulé attendu** | **Fréquence** |
|---|---|---|
| **Je reviens de chez le caviste avec 6 bouteilles** | Je scanne ou recherche chaque référence. Si le lot existe, l’application propose « + n bouteilles » avec un réglage rapide de la quantité ; sinon je crée la référence (saisie assistée par le scan). | À chaque achat |
| **Je cherche un rouge à boire ce soir** | 1/ Je sais quoi chercher : recherche ou filtres pour vérifier la disponibilité.<br>2/ Je ne sais pas quoi chercher : filtre « vin, robe rouge », liste des références disponibles avec leur stock, triée par date optimale de consommation (V2). | Avant un repas ou une réception |
| **Je prends une bouteille à la cave** | Je recherche la référence et j’appuie sur « −1 » directement dans la liste (sortie « consommée »), ou je scanne le code-barres puis j’appuie sur « −1 ». Un bandeau permet d’annuler pendant quelques secondes. | À chaque sortie |
| **Je fais l’inventaire** | Mode inventaire guidé : l’application fait défiler les lots et je confirme ou corrige chaque quantité d’un geste (ajustement d’inventaire). | Au lancement, puis une fois par an au plus |

## 6. Exigences fonctionnelles
### 6.1 Classification
Chaque référence a un type et, pour chaque famille de caractéristiques de ce type, une ou plusieurs valeurs. Ex. : une « IPA blanche » prend Robe = blanche et Style = IPA. Deux niveaux suffisent ; la région et l’appellation sont des champs de la fiche, pas des caractéristiques.
Classification initiale (types, familles et valeurs modifiables dans l’application) :

| **Type** | **Famille** | **Valeurs initiales** |
|---|---|---|
| **Vin** | Robe | Rouge, blanc, rosé |
|  | Style | Tranquille, effervescent |
|  | Sucre | Sec, demi-sec, moelleux, liquoreux |
| **Bière** | Robe | Blonde, ambrée, brune, blanche |
|  | Style | IPA, stout, lager |
|  | Arôme | Fumée, aromatisée |
| **Spiritueux** | Catégorie | Rhum, whisky, gin, calvados, liqueur |
|  | Style | Single malt, blend |
|  | Parfum | Cassis, mûre, violette, plantes, café |
| **Soft** | Catégorie | Limonade, jus, sirop, soda |

- Les crèmes (cassis, mûre, violette) sont des spiritueux de catégorie « liqueur », avec la famille Parfum. La chartreuse : liqueur, parfum « plantes ».
- Aucun niveau de classification supplémentaire (labels bio, nature…) n’est prévu.
- Si un type ou une caractéristique est renommé ou supprimé, les références rattachées restent enregistrées, figurent dans la liste non filtrée et apparaissent « sans catégorie ».
- Un nouveau type choisit à sa création le modèle de fiche d’un des quatre types de base (champs du 4.1 : vin, bière, spiritueux ou soft) ; ce choix ne peut plus changer ensuite. Un nom vide ou déjà présent au même endroit (sans tenir compte des majuscules ni des accents) est refusé. Le dernier type restant ne peut pas être supprimé.
### 6.2 Ajout de bouteilles
Ajout manuel ou assisté par scan. Il est possible d’ajouter des bouteilles au stock d’un lot existant, ou un nouveau lot (autre millésime ou volume) à une référence existante. La quantité ajoutée se règle facilement pour ajouter plusieurs bouteilles en une fois.
**Scan — reconnaissance assistée (V1) :**
- **Code-barres ou QR code, lu en premier :** si le code est connu dans la base, le lot est retrouvé et l’application propose « + n bouteilles » ; sinon, avec du réseau, recherche dans Open Food Facts pour pré-remplir la fiche ; hors réseau, saisie assistée et code mémorisé pour la prochaine fois. Le code peut aussi être scanné depuis le formulaire de création, ou associé après coup à un lot existant.
- **Photo de l’étiquette :** reconnaissance du texte sur le téléphone. Extraction automatique du millésime, du degré et du volume ; appellation comparée à la liste officielle des appellations (INAO), embarquée dans l’application ; pour le nom et le producteur, l’application affiche les lignes de texte trouvées et l’utilisateur touche une ligne pour l’attribuer au bon champ, ou pour l’ajouter à la suite d’un champ déjà rempli (nom écrit sur plusieurs lignes). Les mots écrits côte à côte sont regroupés en une ligne, et un mot qui annonce toujours un nom (« Château », « Domaine », « Cuvée »…) est collé à la ligne qui le suit.
- **Validation :** les champs sont pré-remplis puis validés ou modifiés à la main.
- **Photo :** supprimée après extraction en V1 ; conservation envisagée en V2 (aide pour retrouver la bonne bouteille dans une cave sombre).
- **Lampe torche :** activable depuis l’écran de scan.
- **Code-barres correspondant à plusieurs lots :** fréquent (même code d’un millésime ou d’un brassin à l’autre) : l’application propose de choisir le lot, ou de créer un nouveau lot sur la même référence.
- **Détection des doublons :** à la création d’une référence, l’application signale une référence proche déjà existante (« Château Figeac » / « Ch. Figeac ») et propose d’y ajouter un lot. La même vérification est faite après une recherche Open Food Facts et après la photo d’une étiquette (« Déjà dans votre cave ? ») ; elle ne fait que proposer.
### 6.3 Retrait de bouteilles et historique
- Retrait manuel, après recherche dans la base.
- Retrait par scan possible pour les références disposant d’un code-barres ou d’un QR code. Le scan ne retire jamais rien seul : il affiche le lot avec le bouton « −1 » et un réglage de la quantité (2 gestes : scanner, puis « −1 »).
- Si le code correspond à plusieurs lots en stock : liste à choisir (millésime, volume, stock), du millésime le plus ancien au plus récent, lots sans millésime en dernier, lots épuisés masqués.
- Code inconnu : bascule sur la recherche manuelle, et proposition d’associer le code au lot choisi pour la prochaine fois.
- Sortie rapide : bouton « −1 » sur chaque ligne de résultat, sans ouvrir la fiche.
- Toute sortie est enregistrée par défaut comme « consommée » ; motifs « offerte » et « cassée » et commentaire en option.
- Annulation de la dernière action : bandeau « Bouteille retirée — Annuler » pendant quelques secondes.
- L’historique des mouvements est conservé dès la V1. Il peut être purgé manuellement ou automatiquement (voir 7).
### 6.4 Stock épuisé, correction et inventaire
- Un lot épuisé est conservé avec un stock à zéro et masqué par défaut ; un filtre « afficher les épuisés » permet de le retrouver (rachat).
- Suppression manuelle possible d’un lot ou d’une référence entière.
- Correction directe du stock d’un lot (saisie du nombre réel), enregistrée comme ajustement d’inventaire, distinct des sorties et exclu des statistiques de consommation.
- Mode inventaire guidé (V1) : défilement des lots, confirmation ou correction de chaque quantité d’un geste ; parcours par emplacement lorsque celui-ci est renseigné (V2).
### 6.5 Affichage, recherche et navigation
- Recherche par texte libre, avec résultats pendant la frappe.
- Filtres et tris sur les champs de la fiche : type, caractéristiques, région, millésime, nom, date d’ajout, favori, « à compléter »… ; tri par période idéale de consommation en V2.
- Affichage en liste en V1, avec la référence et le stock.
### 6.6 Statistiques
- **V1 :** nombre total de bouteilles et de références ; répartition par type, par caractéristique et par région.
- **V2 :** consommation dans le temps (bouteilles sorties par mois ou par an, par type, références les plus consommées).
Aucune notion de valeur.
### 6.7 Import et export
- **Import Vivino (V1, utilisé une fois) :** fichier cellar.csv de l’export Vivino (vin, producteur, millésime, région, pays, type, quantité). Les volumes absents prennent la valeur par défaut du type ; les fiches incomplètes (région manquante…) sont importées avec le marqueur « à compléter ».
- **Export CSV (V1) :** deux fichiers, stock (références et lots) et historique, lisibles dans Excel ou LibreOffice ; sert aussi de sauvegarde de secours.
- **Import CSV (V1) :** au format de l’export, pour restaurer une sauvegarde ou importer une saisie préparée dans un tableur. Pour un fichier préparé à la main, l’application affiche les consignes (colonnes, valeurs acceptées, types et caractéristiques de la cave) et fournit un fichier modèle à remplir ; le volume peut y être écrit en millilitres ou avec son unité (75 cl, 1,5 l).
- **Export PDF imprimable :** V2 éventuelle.
### 6.8 Premier lancement
Écran d’accueil en trois étapes, chacune pouvant être passée :
- Mode de stockage : « Sur cet appareil uniquement » ou « Synchroniser avec un serveur (Nextcloud / WebDAV) » ; si une cave existe déjà sur le serveur, elle est récupérée (nouvel appareil, PC) : sur un appareil dont la cave est encore vide, sans poser la question du 8.2. La cave récupérée, l’accueil est terminé : les deux étapes suivantes ne concernent qu’une cave neuve ; si le serveur est vide, l’accueil passe à l’import.
- Import facultatif d’une cave existante : fichier Vivino ou CSV.
- Récapitulatif des valeurs par défaut (volumes pré-remplis par type), modifiables immédiatement ou plus tard.
Les valeurs par défaut et la classification initiale livrées sont celles de ce cahier des charges ; chacun peut les modifier dans les paramètres.
## 7. Paramètres de l’application
Liste initiale, à compléter après les tests de la V1 si des réglages manquent.

| **Rubrique** | **Réglages** |
|---|---|
| **Paramètres utilisateur** |  |
| Apparence | Thème : système (par défaut), clair ou sombre · taille du texte |
| Valeurs par défaut | Volume pré-rempli par type : vin 75 cl, bière 75 cl, spiritueux 70 cl, soft 1 l · volumes proposés de 10 cl à 6 l (fût) |
| Classification | Créer, renommer ou supprimer les types, les familles de caractéristiques et leurs valeurs |
| Emplacements (V2) | Liste des emplacements (casiers, pièces), pour les choisir au lieu de les taper |
| Affichage | Tri par défaut · afficher ou masquer les lots épuisés · durée du bandeau « Annuler » |
| **Paramètres système** |  |
| Stockage et synchronisation | Mode : sur cet appareil uniquement, ou synchronisé · serveur : Nextcloud ou autre serveur WebDAV (adresse complète) · identifiant, mot de passe d’application, dossier de la base · synchronisation automatique activée ou non (activée par défaut) · « Synchroniser maintenant » · état de la dernière synchronisation · journal technique des erreurs |
| Sauvegarde | Fréquence de la sauvegarde automatique : chaque jour (par défaut), chaque semaine ou chaque mois · nombre N de sauvegardes conservées (3 par défaut) · dossier de sauvegarde sur l’appareil (Documents/Cave/Sauvegardes par défaut ; sur Android 11 et suivants, dans Documents ou Download) · « Sauvegarder maintenant » · « Restaurer » |
| Espace disque | Taille de la base · purge manuelle de l’historique (avant une date antérieure d’au moins 30 jours, pour ne pas écarter un mouvement d’un autre appareil pas encore synchronisé) · purge automatique activée ou non, avec délai réglable |
| Reconnaissance | Recherche Open Food Facts activée ou non (moteurs fixés depuis la fin de la bêta : Tesseract pour le texte, ZXing pour les codes-barres) |
| Import / export | Import Vivino · import CSV · export CSV |

**Purge automatique :** La purge automatique supprime les lots épuisés sans aucun mouvement depuis le délai choisi, avec leur historique, ainsi que la référence si elle n’a plus aucun lot. Les lots encore en stock ne sont jamais purgés.
**Réglages de l’appareil :** Les réglages sont propres à chaque appareil (thème, affichage, sauvegarde, synchronisation…), sauf les volumes par défaut, la classification et la purge automatique, qui font partie de la cave et sont synchronisés.
## 8. Données, synchronisation et sauvegarde
### 8.1 Principe
Besoin : garder les données chez soi et y accéder depuis plusieurs appareils (téléphone, PC). Les données sont d’abord stockées sur l’appareil, ce qui rend l’application entièrement utilisable sans réseau (indispensable dans la cave), puis synchronisées comme un fichier de base de données sur le serveur Nextcloud personnel.
La synchronisation est facultative : lors de la diffusion de l’application à d’autres utilisateurs, l’utilisation en local exclusif doit être possible.
Le serveur Nextcloud est accessible hors du domicile. Aucun service supplémentaire n’est installé sur le serveur, pour en faciliter la maintenance.
### 8.2 Modes de stockage
- **Sur cet appareil uniquement :** aucune synchronisation ; toutes les fonctions restent disponibles.
- **Synchronisé :** avec tout serveur WebDAV : Nextcloud (configuration simplifiée : adresse du serveur, l’application complète le chemin), ownCloud, NAS ou hébergeur (adresse complète). Google Drive, Dropbox et OneDrive ne sont pas prévus (développement spécifique pour chacun).
- **Activer la synchronisation sur une cave existante :** s’il n’y a pas de base sur le serveur, celle de l’appareil y est envoyée ; s’il y en a une, l’application demande « Utiliser la cave du serveur » (celle de l’appareil est remplacée, après sauvegarde automatique) ou « Remplacer la cave du serveur par celle-ci » (après sauvegarde de celle du serveur). Pas de fusion automatique de deux caves indépendantes.
- **Désactiver la synchronisation :** l’appareil garde sa copie complète et continue en mode local ; la base du serveur n’est pas supprimée ; les sauvegardes basculent vers le dossier local.
### 8.3 Synchronisation
- L’application se synchronise elle-même par WebDAV, avec l’adresse du serveur, l’identifiant et un mot de passe d’application.
- Moments : à l’ouverture, au retour de l’application au premier plan, quelques secondes après une modification (les saisies sont regroupées), au retour du réseau, sur demande (bouton) ; hors ligne, les modifications attendent le retour du réseau. Uniquement application ouverte : pas de tâche de fond en V1. Synchronisation automatique désactivée : seulement sur demande.
- Modifications sur deux appareils entre deux synchronisations : les mouvements de stock s’additionnent sans perte ; pour les fiches, la modification la plus récente l’emporte, fiche par fiche.
- Un indicateur discret affiche l’état : synchronisé, en attente ou erreur.
**Traitement des erreurs :**
- L’absence de réseau n’est pas une erreur : l’état est « en attente », sans message.
- Les données de l’appareil ne sont jamais modifiées par une erreur : les modifications restent en attente, rien n’est perdu.
- Nouvelles tentatives automatiques, à intervalles croissants, puis à chaque ouverture.
- L’indicateur passe en orange ou en rouge ; le toucher affiche un message clair et l’action qui corrige :
  - serveur injoignable : « Réessayer » ;
  - identifiants refusés : ouverture des paramètres de synchronisation ;
  - espace insuffisant sur le serveur : message ;
  - fichier du serveur illisible ou endommagé : jamais utilisé à la place des données de l’appareil ; mis de côté (renommé) puis remplacé par la version de l’appareil, avec un message ;
  - base créée par une version plus récente de l’application : synchronisation suspendue sur cet appareil, invitation à mettre l’application à jour, aucun écrasement.
- Pas de notification en V1 (pas de tâche de fond) : si l’erreur dure plus de 24 heures, l’indicateur passe au rouge dans l’application.
- Journal technique des dernières erreurs consultable dans les paramètres.
- Un seul utilisateur en V1, donc un risque d’écritures simultanées très faible.
### 8.4 Sauvegarde
- Historique des versions de fichiers de Nextcloud.
- Copie locale sur chaque appareil.
- Sauvegarde automatique périodique : copie datée de la base et export CSV, faite application ouverte (à l’ouverture et à la mise en arrière-plan), seulement si la cave a changé ; seules les N dernières sont conservées. Toujours dans un dossier de l’appareil choisi par l’utilisateur (par défaut Documents/Cave/Sauvegardes), qu’il peut synchroniser lui-même avec un autre outil ; en mode synchronisé, une copie en plus dans un dossier « Sauvegardes » du serveur, avec le même nombre conservé. Sur Android 8 à 10, l’écriture dans Documents demande une autorisation.
- En mode local, une alerte au premier lancement rappelle que les données ne sont stockées que sur l’appareil.
- Export CSV et « Sauvegarder maintenant » avec possibilité de partager le fichier (courriel, autre application).
- Boutons « Sauvegarder maintenant » et « Restaurer ».
**Contexte serveur :** le stockage du serveur est sur SSD ; les fichiers Nextcloud sont synchronisés sur plusieurs PC ; le serveur fait des sauvegardes automatiques (les deux plus récentes sont conservées), dont une copie locale est prévue avec les fichiers de configuration du serveur web.
### 8.5 Photos
En V1, la photo sert uniquement à extraire les informations, puis elle est supprimée. Volume de données faible : uniquement du texte.
## 9. Exigences non fonctionnelles

| **Exigence** | **Attendu** |
|---|---|
| **Fonctionnement hors ligne** | Indispensable : toutes les fonctions sauf la synchronisation et la recherche Open Food Facts. |
| **Langue** | Français en V1. Tous les textes de l’interface sont regroupés dans un fichier de traduction dès la V1, pour permettre d’autres langues plus tard ; dates et nombres au format de la langue de l’appareil. |
| **Rapidité de saisie** | Ajouter une bouteille en moins de 30 secondes et en moins de 3 manipulations. |
| **Performances** | Ouverture en moins de 2 secondes ; recherche instantanée, même avec plusieurs milliers de lots. |
| **Ergonomie** | Utilisable d’une main, dans une cave peu éclairée : contraste élevé, gros boutons, lampe torche au scan ; thème clair ou sombre, qui suit le système par défaut. |
| **Compatibilité** | Android récent (téléphone de référence sous OxygenOS 16, soit Android 16) ; minimum Android 8 (vérifié sur Android 10 : l’autorisation d’écrire les sauvegardes dans Documents est demandée sur Android 8 à 10, et l’application guide l’utilisateur vers les réglages si elle a été refusée définitivement). PC : Windows 10 ou 11 (64 bits) ; Linux 64 bits récent (Ubuntu 24.04, Debian 13, Fedora 39 ou plus récents). |
| **Fiabilité** | Aucune perte de données : l’enregistrement et la synchronisation ne doivent jamais corrompre la base, même en cas de coupure de réseau ou de batterie. |
| **Sécurité** | Pas d’enjeu sur ces données : pas de verrouillage de l’application. Identifiants du serveur (mot de passe d’application) stockés dans le coffre sécurisé du système (Android ; sur PC, trousseau de la session, par exemple KWallet ou GNOME Keyring), jamais en clair. |
| **Confidentialité** | Aucune donnée ne sort des appareils et du serveur de synchronisation choisi, sauf le code-barres envoyé à Open Food Facts lors d’une recherche, ce que l’application signale. Seuls les codes-barres de 8 à 14 chiffres sont envoyés, jamais le contenu d’un QR code ; la recherche Open Food Facts peut être désactivée dans les paramètres. Sur Android, l’application ne demande que l’appareil photo, l’accès à Internet et, sur Android 8 à 10 seulement, l’écriture dans le stockage. |
| **Maintenabilité** | Code commenté, tests automatiques sur les fonctions de base (stock, synchronisation), documentation à jour : le projet doit pouvoir être repris facilement après une longue pause, et par d’autres en cas de diffusion libre. |

## 10. Choix techniques et réalisation

| **Sujet** | **Choix** |
|---|---|
| **Développement** | Par le porteur du projet (débutant en Python), avec Claude Code. |
| **Technologie** | Flutter (langage Dart) : un seul code pour Android et pour le PC (Linux, puis Windows) ; chaque écran s’adapte à la largeur de la fenêtre. Sur PC, ni scan de code-barres ni lecture d’étiquette : le code est saisi au clavier, ou avec une douchette USB, qui se comporte comme un clavier. Sur PC, pas de partage de fichiers : les exports, le fichier modèle et les sauvegardes sont enregistrés dans un dossier choisi. |
| **Base de données** | Fichier SQLite local, synchronisé facultativement par WebDAV (Nextcloud ou autre serveur). |
| **Reconnaissance de texte** | Moteur interchangeable dans le code. Tesseract (libre), retenu après une bêta qui le comparait à ML Kit (Google, non libre) : un peu moins précis, mais il rend l’application entièrement libre. |
| **Codes-barres** | Lecture sur le téléphone avec ZXing (libre), qui remplace ML Kit ; base Open Food Facts en complément si réseau. |
| **Budget** | Nul : uniquement des composants et services gratuits. |
| **Licence** | GNU GPL v3 ou toute version ultérieure, sans exception : l’exception de liaison prévue pour ML Kit a été retirée avec lui. |
| **Diffusion** | Diffusion privée à partir de la version 1.0.0 : code source public sur GitHub ; fichiers publiés sur la page « Releases » du dépôt : APK Android signé avec la clé de diffusion du projet (à conserver sans limite de durée : sans elle, plus aucune mise à jour possible), installateur Windows pour l’utilisateur seul (non signé), AppImage Linux ; installation manuelle, avec un guide d’installation et un guide d’utilisation ; retours par courriel ou par tickets GitHub, liens dans l’écran « À propos » ; l’application ne vérifie pas elle-même les mises à jour. F-Droid et Google Play Store restent possibles plus tard. |

## 11. Priorisation
### V1 — indispensable
- Gestion des types, familles et caractéristiques
- Fiche référence et lots (champs V1 du 4.1)
- Ajout manuel, ajout de plusieurs bouteilles en une fois
- Scan : code-barres et reconnaissance de texte assistée, avec des composants libres (ZXing, Tesseract)
- Lampe torche, détection des doublons
- Retrait manuel, sortie rapide « −1 », retrait par scan, annulation
- Historique des mouvements (motifs, commentaire)
- Lots épuisés conservés, correction de stock, mode inventaire guidé
- Recherche, filtres, tris, affichage en liste
- Statistiques de base (sans valeur)
- Import Vivino, import et export CSV
- Fonctionnement hors ligne
- Mode local seul ou synchronisé (tout serveur WebDAV), traitement des erreurs
- Sauvegarde automatique, purge, paramètres
- Écran de premier lancement
- Textes de l’interface regroupés pour la traduction
- Note personnelle, favori, commentaire
### V2
- Emplacement des lots (et inventaire par emplacement)
- Période idéale de consommation et tri associé
- Accords mets et vins
- Statistiques de consommation dans le temps
- Conservation des photos d’étiquette
- Export PDF
- Application PC, en premier (Linux, puis Windows) — faite le 13/10/2026
### Plus tard, éventuellement
- Second utilisateur
- Diffusion plus large (F-Droid, Google Play Store)
- Traductions de l’interface
- Synchronisation avec Google Drive, Dropbox ou OneDrive
- Interprétation automatique plus poussée des étiquettes
## 12. Points à rediscuter
- Suite du projet après la V1 (terminée le 10/10/2026) : usage réel terminé le 11/10/2026 (cave saisie, inventaire vérifié) ; portage PC terminé le 13/10/2026 ; diffusion privée de la version 1.0.0 en préparation ; ensuite, les autres fonctions de la V2.
- Diffusion plus large (F-Droid, Google Play Store), selon les retours de la diffusion privée.
- Paramètres manquants éventuels, après les tests de la V1.
- Hors cahier des charges : optimisation de la procédure de sauvegarde du serveur (Raspberry Pi).
## 13. Journal des décisions

| **Date** | **Question** | **Décision** |
|---|---|---|
| 01/10/2026 | Q1 | Un seul utilisateur ; un second éventuel plus tard. |
| 01/10/2026 | Q2 | Android en V1, puis PC avec la même base. |
| 01/10/2026 | 2.3 | Hors périmètre complété ; pas de notion de valeur dans les statistiques. |
| 01/10/2026 | Q3 | Import de l’export Vivino, puis inventaire initial. |
| 01/10/2026 | Q4 | Fonctionnement hors ligne indispensable. |
| 01/10/2026 | Q5, Q7 | Champs selon le type, peu de champs obligatoires, volume pré-rempli (bière 75 cl). Emplacement facultatif, en V2. |
| 01/10/2026 | Q6, glossaire | Référence = boisson ; le lot (référence × millésime facultatif × volume) porte le stock ; « contenance » remplacé par « volume ». |
| 01/10/2026 | Q8 à Q11 | Classification par familles de caractéristiques, deux niveaux ; crèmes = liqueurs ; pas de label bio ; références orphelines « sans catégorie ». |
| 01/10/2026 | Q12, Q13 | Scan assisté : code-barres puis reconnaissance de texte ; pré-remplissage puis validation. |
| 01/10/2026 | Q14 | Pas de retrait par scan (révisé le 02/10/2026). |
| 01/10/2026 | Q15 | Historique des sorties conservé dès la V1 (révise la réponse initiale) ; consommée par défaut, offerte ou cassée en option. |
| 01/10/2026 | Q16 | Lots épuisés conservés et masqués ; suppression manuelle ; purge paramétrable. |
| 01/10/2026 | Q17 | Correction directe du stock, enregistrée comme ajustement d’inventaire. |
| 01/10/2026 | Q18 | Recherche libre, filtres et tris par champs, affichage en liste. |
| 01/10/2026 | Q19 | Statistiques de base en V1, de consommation en V2 ; export CSV en V1 ; fonctions ajoutées : sortie rapide, annulation, doublons, inventaire guidé ; export PDF en V2. |
| 01/10/2026 | 4.1 | Ajout du code-barres, de la note personnelle (remplace les notes de dégustation), du favori, du commentaire et de la date de dernière entrée. |
| 01/10/2026 | Q20, Q21 | Base de données sous forme de fichier sur Nextcloud, synchronisée par l’application en WebDAV ; aucun service supplémentaire sur le serveur. |
| 01/10/2026 | Q22 | Photos non conservées en V1 (prévu en V2) ; sauvegardes automatiques, restauration. |
| 01/10/2026 | Q23 | Flutter, développé avec Claude Code. |
| 01/10/2026 | Q24 | Budget nul ; GPL v3 avec exception de liaison ; APK installé manuellement, code privé en V1 ; bêta avec deux moteurs de reconnaissance. |
| 01/10/2026 | Section 7 | Thème suivant le système, lampe torche, performances, compatibilité, fiabilité, confidentialité, maintenabilité. |
| 01/10/2026 | Paramètres | Liste des paramètres utilisateur et système validée ; définition de la purge automatique. |
| 02/10/2026 | 1.1, 2.3 | Diffusion future à d’autres utilisateurs, usage privé ; hors périmètre reformulé (chacun gère sa propre cave). |
| 02/10/2026 | Q14, 6.3 | Retrait par scan possible ; jamais automatique (scan puis « −1 ») ; choix du lot si plusieurs, du plus ancien au plus récent ; code inconnu associé au lot choisi. |
| 02/10/2026 | 8.1, 8.2 | Synchronisation facultative, mode local seul ; tout serveur WebDAV ; règles d’activation et de désactivation de la synchronisation. |
| 02/10/2026 | 8.3 | Traitement des erreurs de synchronisation. |
| 02/10/2026 | 8.4 | Sauvegardes en mode local dans un dossier de l’appareil, avec alerte. |
| 02/10/2026 | Premier lancement | Écran d’accueil en 3 étapes : mode de stockage, import, valeurs par défaut. |
| 02/10/2026 | Section 9 | Textes préparés pour la traduction ; identifiants dans le coffre sécurisé d’Android. |
| 02/10/2026 | Section 10 | Canal de diffusion à choisir après la bêta. |
| 05/10/2026 | 4.1, 6.2 | Une fiche incomplète (champ obligatoire manquant) est enregistrée avec le marqueur « à compléter », jamais refusée. |
| 05/10/2026 | 4.1, 6.7 | Appellation facultative pour le vin (« Vin de France », vins étrangers sans équivalent) ; la région ou le pays restent obligatoires. À l’import Vivino, le marqueur « à compléter » signale une région manquante. |
| 05/10/2026 | 8.3, 8.4 | Pas de tâche de fond en V1 : synchronisation et sauvegarde se font application ouverte ; pas de notification d’erreur, l’indicateur passe au rouge après 24 heures. |
| 05/10/2026 | 8.4, 7 | Trois sauvegardes conservées par défaut, nombre réglable. |
| 06/10/2026 | 8.4 | En mode synchronisé, sauvegardes sur l’appareil et dans le dossier « Sauvegardes » du serveur. |
| 06/10/2026 | 7 | Purge manuelle de l’historique limitée aux mouvements de plus de 30 jours. |
| 06/10/2026 | 6.2 | Doublons signalés aussi quand Open Food Facts trouve le produit et après la photo d’une étiquette (« Déjà dans votre cave ? »). |
| 06/10/2026 | 6.2 | Code-barres scanné depuis le formulaire de création, ou associé à un lot existant. |
| 07/10/2026 | 6.8 | Appareil neuf (cave vide) : la cave du serveur est reprise sans poser de question. |
| 07/10/2026 | 6.1 | Classification modifiable : modèle de fiche choisi à la création d’un type, non modifiable ; noms en double refusés ; dernier type non supprimable. |
| 07/10/2026 | 7 | Volume de 6 l (fût) ajouté aux volumes proposés. |
| 07/10/2026 | 7, 8.3 | Synchronisation automatique activée par défaut, désactivable ; fréquence de la sauvegarde (jour, semaine, mois) et dossier de sauvegarde au choix. |
| 07/10/2026 | 6.7 | Import préparé dans un tableur : consignes affichées par l’application et fichier modèle à remplir. |
| 07/10/2026 | 9 | Open Food Facts : seuls les codes de 8 à 14 chiffres sont envoyés ; recherche désactivable. |
| 07/10/2026 | 10 | Licence : GPL v3 ou toute version ultérieure, avec l’exception ML Kit. |
| 08/10/2026 | 11 | La V1 n’est terminée qu’après un essai sur Android 8 à 10 et l’approbation, par le porteur, d’un lecteur de codes-barres libre remplaçant ML Kit. |
| 09/10/2026 | 7 | Volumes de 10 cl, 1,75 l, 2 l et 5 l ajoutés aux volumes proposés. |
| 10/10/2026 | 10, 12 | Fin de la bêta : Tesseract retenu pour le texte (un peu moins précis que ML Kit, mais libre), ZXing pour les codes-barres ; ML Kit retiré ; licence GPL v3 ou ultérieure, sans exception. |
| 10/10/2026 | 6.2 | Lecture d’étiquette : lignes voisines regroupées, mots qui annoncent un nom (« Château », « Domaine »…) collés à la ligne suivante, ligne ajoutable à la suite d’un champ déjà rempli. |
| 10/10/2026 | 11, 12 | V1 terminée : toutes les fonctions V1 faites et vérifiées, conditions de fin remplies, application entièrement libre. Suite à décider : usage réel, diffusion, V2. |
| 11/10/2026 | 2.2, 10, 11 | Usage réel de la V1 terminé (cave saisie, inventaire vérifié). La V2 commence par le portage PC, avant toute nouvelle fonction : Linux d’abord, puis Windows. Pas de caméra sur PC : ni scan de code-barres ni lecture d’étiquette, code saisi au clavier ou avec une douchette USB. |
| 11/10/2026 | 6.8 | Synchronisation choisie à l’accueil : si la cave est reprise du serveur, l’accueil est terminé ; si le serveur est vide, il passe à l’import. |
| 11/10/2026 | 10 | Pas de partage de fichiers sur PC (Linux et Windows) : enregistrement dans un dossier seulement. |
| 11/10/2026 | 10, 12 | Diffusion privée : version 1.0.0 publiée en même temps pour Android, Windows et Linux ; code source public ; retours par courriel et par tickets GitHub. |
| 13/10/2026 | 2.2, 11 | Portage PC terminé : Linux et Windows vérifiés en usage réel. La 1.0.0 réunit la V1 et l’application PC ; V1 et V2 restent les étapes du projet. |
| 13/10/2026 | 9, 10 | Fichiers de diffusion : APK signé avec une clé de diffusion propre au projet, installateur Windows (Inno Setup) et AppImage Linux (Ubuntu 24.04 et plus récents) ; autorisations Android réduites au nécessaire ; dépôt rendu public après vérification de tout son historique. |
