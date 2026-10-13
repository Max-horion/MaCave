# Ma Cave — guide d'utilisation

Ma Cave est un gestionnaire de cave personnelle pour Android, Windows et Linux.

- **Elle fonctionne sans réseau** : tout est enregistré sur votre appareil.
- **Téléphone et ordinateur** : l'application existe sur Android, Windows et Linux. Avec la synchronisation (facultative), vos appareils partagent la même cave.
- **Vos données restent chez vous** : aucun compte, aucune publicité, aucune donnée envoyée ailleurs (voir [Confidentialité](#16-confidentialité)).
- **Logiciel libre** (licence GNU GPL v3 ou ultérieure), gratuit.

Pour l'installation, voir le [guide d'installation](guide_installation.md).

## Sommaire

1. [Les notions de base](#1-les-notions-de-base)
2. [Premier lancement](#2-premier-lancement)
3. [La liste de la cave](#3-la-liste-de-la-cave)
4. [Ajouter des bouteilles](#4-ajouter-des-bouteilles)
5. [Retirer des bouteilles](#5-retirer-des-bouteilles)
6. [La fiche d'une boisson](#6-la-fiche-dune-boisson)
7. [Inventaire](#7-inventaire)
8. [Statistiques](#8-statistiques)
9. [Importer et exporter](#9-importer-et-exporter)
10. [Synchronisation entre appareils](#10-synchronisation-entre-appareils)
11. [Sauvegardes et restauration](#11-sauvegardes-et-restauration)
12. [Espace disque et purge](#12-espace-disque-et-purge)
13. [Paramètres](#13-paramètres)
14. [Téléphone ou ordinateur : les différences](#14-téléphone-ou-ordinateur--les-différences)
15. [Questions fréquentes](#15-questions-fréquentes)
16. [Confidentialité](#16-confidentialité)
17. [Envoyer un retour](#17-envoyer-un-retour)

---

## 1. Les notions de base

Quatre mots suffisent pour tout comprendre :

| Mot | Ce que c'est | Exemple |
|---|---|---|
| **Référence** (ou boisson) | La fiche d'un produit : nom, producteur, appellation, région, type… | « Château Exemple », Bordeaux |
| **Lot** | Une référence pour un millésime et un volume donnés. **C'est le lot qui porte le stock.** | Château Exemple **2019**, **75 cl** |
| **Bouteille** | L'unité comptée dans le stock d'un lot. | 6 bouteilles du lot 2019 |
| **Mouvement** | Toute variation du stock, gardée dans l'historique : entrée, sortie, inventaire. | « −1 bouteille, consommée, le 12 mars » |

Une même référence peut donc avoir plusieurs lots : le 2019 et le 2020, ou une bouteille de 75 cl et un magnum. Le stock de la référence est la somme de ses lots.

**Types et caractéristiques.** Chaque référence a un **type** (Vin, Bière, Spiritueux, Soft) et des **caractéristiques** rangées par familles : pour un vin, la *robe* (rouge, blanc, rosé), le *style* (tranquille, effervescent), le *sucre* (sec, moelleux…). Pour une bière, la *robe* (blonde, brune…), le *style* (IPA, stout…). Vous pouvez tout modifier pour personnaliser selon votre usage (voir [Paramètres](#13-paramètres)).

**Les champs dépendent du type** : un vin a un millésime, une appellation, des cépages ; une bière n'a pas de millésime ; un soft se limite au nom, au producteur et au volume.

**Le marqueur « À compléter »** (icône de note ✎) : une fiche à laquelle manque une information obligatoire (par exemple un vin sans région ni pays) est **quand même enregistrée**, avec ce marqueur. Vous la complétez quand vous voulez ; le filtre « Fiches à compléter » les retrouve toutes.

---

## 2. Premier lancement

Au tout premier démarrage, l'appli vous guide en trois étapes. Chacune peut être passée.

**Étape 1 — « Où ranger votre cave ? »**
- **Sur cet appareil uniquement** : rien à configurer. Un message vous rappelle que la cave n'est que sur cet appareil : s'il est perdu ou cassé, elle est perdue aussi. Des sauvegardes automatiques sont faites dans `Documents/Cave/Sauvegardes` ; pensez à les copier ailleurs de temps en temps.
- **Synchroniser avec un serveur** : votre cave est aussi copiée sur votre serveur Nextcloud ou un autre serveur WebDAV et partagée avec vos autres appareils. Voir [Synchronisation](#10-synchronisation-entre-appareils).
  - Si une cave est **déjà** sur le serveur (vous installez l'appli sur un deuxième appareil), elle est récupérée et l'accueil se termine aussitôt : « Cave récupérée du serveur : tout est prêt. »

**Étape 2 — « Vous avez déjà une cave ? »** : importez un export Vivino ou un fichier préparé dans un tableur (voir [Importer](#9-importer-et-exporter)). Un aperçu s'affiche avant tout ajout.

**Étape 3 — « Volumes par défaut »** : le volume proposé pour une nouvelle bouteille selon son type (vin 75 cl, bière 75 cl, spiritueux 70 cl, soft 1 l). Choisissez une ligne pour le changer.

Vous pourrez changer tous ces choix plus tard dans les Paramètres.

---

## 3. La liste de la cave

C'est l'écran principal. En haut :
- le titre et, si la synchronisation est active, un **petit nuage** qui indique son état ;
- **⇅ Trier** : par nom, derniers ajouts, millésime ou stock ;
- **Filtres** (avec un chiffre quand des filtres sont actifs) ;
- **⋮ Plus d'actions** : Inventaire, Statistiques, Importer un fichier, Exporter (CSV), Paramètres ;
- la **barre de recherche** et le résumé : nombre de bouteilles et de références.

Chaque ligne montre le nom, le producteur, l'appellation et les lots en stock (« 2019 · 75 cl »), le nombre de bouteilles, et le bouton **−1**. Un cœur ♥ signale un favori, l'icône ✎ une fiche à compléter.

### Rechercher

Tout ce qui est vu à l'écran peut être utilisé dans la barre de recherche : nom, producteur, appellation, région, type, caractéristique, millésime. Les résultats s'affichent pendant la frappe, sans tenir compte des accents ni des majuscules. Exemples : « chateau », « rouge », « 2015 », « ipa », « vin rouge ».

### Filtrer

**Filtres** ouvre un volet :
- **Type** (Tous, Vin, Bière…), puis les caractéristiques de ce type (robe, style…) ;
- **Région ou pays** ;
- **Favoris uniquement**, **Fiches à compléter** ;
- **Afficher les épuisés** : les lots à zéro bouteille sont masqués par défaut, mais jamais supprimés (pratique pour racheter un vin qu'on a aimé).

« Voir les résultats » applique ; « Effacer les filtres » revient à la liste complète.

### Ouvrir une fiche

Touchez (ou cliquez) une ligne pour ouvrir la fiche de la boisson (voir [La fiche](#6-la-fiche-dune-boisson)). Sur un ordinateur dont la fenêtre est assez large, la fiche s'affiche **à droite de la liste**.

### En bas de l'écran

- **Scanner** (téléphone) ou **Code-barres** (ordinateur) : retrouver une bouteille par son code-barres (voir [4.3](#43-avec-le-code-barres)) ;
- **Ajouter** : nouvelle boisson (voir [4.1](#41-une-nouvelle-boisson)).

---

## 4. Ajouter des bouteilles

### 4.1 Une nouvelle boisson

**Ajouter** ouvre le formulaire « Nouvelle boisson ».

1. Choisissez le **type** (Vin, Bière…) : les champs s'adaptent.
2. Remplissez ce que vous voulez : **Nom** (obligatoire), producteur ou domaine, appellation, région, pays, cépages, degré d'alcool, caractéristiques, note personnelle (étoiles), favori, commentaire.
3. Partie **Bouteilles** : millésime (laissez vide pour « sans millésime »), **volume** (déjà rempli selon le type), **nombre de bouteilles** (boutons + et −).
4. **Enregistrer**.

Sur un téléphone, deux boutons en haut du formulaire vous font gagner du temps :
- **Lire l'étiquette** : photo de l'étiquette, les champs **vides** sont remplis (voir [4.4](#44-avec-la-photo-de-létiquette-téléphone)) ;
- **Scanner le code-barres** : le code est mémorisé avec la bouteille ; si la base libre Open Food Facts connaît le produit, les champs vides sont complétés.

Sur un ordinateur, le second bouton s'appelle **Saisir le code-barres**.

**Doublons.** Si une référence au nom proche existe déjà (« Château Exemple » / « Ch. Exemple »), l'appli vous le signale : « Référence proche déjà dans la cave ». Vous pouvez ajouter les bouteilles à la référence existante, créer quand même une nouvelle référence, ou revenir au formulaire.

### 4.2 Des bouteilles d'une boisson déjà en cave

Ouvrez sa fiche :
- même millésime et même volume qu'un lot existant : dans le menu **⋮** du lot, **Ajouter des bouteilles** ;
- autre millésime ou autre volume : **Ajouter un lot**.

### 4.3 Avec le code-barres

**Sur le téléphone**, **Scanner** ouvre l'appareil photo : visez le code-barres (ou le QR code) de la bouteille. **Allumer la lampe** aide dans une cave sombre. **Saisir le code** permet de le taper.

**Sur l'ordinateur**, **Code-barres** ouvre une fenêtre de saisie : tapez le code, ou lisez-le avec une **douchette USB** (elle se comporte comme un clavier).

Ensuite :
- **Code connu** : les lots correspondants s'affichent, avec **−1**, **Ajouter**, **Nouveau lot sur cette référence** et **Voir la fiche**. Le scan **ne retire jamais rien tout seul** : il faut toucher « −1 ».
- **Code inconnu** :
  - avec du réseau, l'appli cherche le produit dans Open Food Facts (seul le code-barres est envoyé ; recherche désactivable dans les Paramètres) ; si elle le trouve, elle propose une fiche pré-remplie, et vérifie s'il n'est pas « Déjà dans votre cave ? » ;
  - **Nouvelle référence avec ce code** : formulaire, code mémorisé ;
  - **Associer à une référence existante** : la bouteille est déjà dans votre cave mais sans code (par exemple après un import) : choisissez la référence puis le lot ; la prochaine fois, le code sera reconnu.

Un même code-barres peut servir à plusieurs lots (même étiquette d'une année à l'autre) : l'appli vous laisse alors choisir le lot.

Depuis une fiche, le menu **⋮** d'un lot propose aussi **Associer un code-barres** (ou **Changer le code-barres**).

### 4.4 Avec la photo de l'étiquette (téléphone)

Pour une bouteille sans code-barres, ou pour remplir la fiche plus vite : **Lire l'étiquette** (dans le formulaire), **Photographier l'étiquette** (code inconnu) ou **Pas de code-barres ? Photo de l'étiquette** (écran de scan).

1. Cadrez l'étiquette entière, bien à plat, sans reflet, puis **Photographier**.
2. L'appli lit le texte **sur le téléphone** (rien n'est envoyé) et propose : type, millésime, degré, volume, appellation (comparée à la liste officielle de l'INAO), nom et producteur.
3. Vérifiez. En bas, la liste **Texte lu** montre les lignes trouvées : touchez une ligne pour l'utiliser comme nom, producteur ou appellation, ou pour l'**ajouter à la suite** d'un nom écrit sur deux lignes.
4. Si la boisson ressemble à une référence de votre cave, l'appli le signale (« Déjà dans votre cave ? ») : touchez-la pour lui ajouter des bouteilles.
5. **Continuer avec ces informations** ouvre le formulaire pré-rempli, à compléter si nécessaire puis valider.

La photo est supprimée juste après la lecture. La lecture peut présenter des erreurs (étiquettes courbes, écritures fantaisie, noms en arc de cercle) : elle aide, vous corrigez.

---

## 5. Retirer des bouteilles

- **Le plus rapide** : le bouton **−1** sur la ligne de la liste. Si la boisson a plusieurs lots en stock, l'appli demande « Quelle bouteille ? ».
- **Par le code-barres** : scanner, puis **−1**.
- **Avec plus de détails** : sur la fiche, menu **⋮** du lot → **Retirer des bouteilles** : nombre, **motif** (Consommée, Offerte, Cassée) et commentaire facultatif (une occasion, une impression…).

Un retrait rapide est enregistré comme « Consommée ».

**Annuler.** Après chaque ajout ou retrait, un bandeau propose **Annuler** pendant quelques secondes (durée réglable). Une erreur se rattrape donc d'un geste.

On ne peut jamais retirer plus de bouteilles qu'il n'y en a (« Stock insuffisant »).

---

## 6. La fiche d'une boisson

En haut : le nom, le **cœur** (favori), le **crayon** (Modifier la fiche) et **⋮** (Supprimer la référence).

Puis les informations de la fiche, et un bandeau si elle est « à compléter ».

**Lots** : chaque lot avec son millésime, son volume, son nombre de bouteilles (ou « Épuisé »), sa date d'ajout et son code-barres s'il en a un. Son bouton **−1** et son menu **⋮** :
- **Ajouter des bouteilles**, **Retirer des bouteilles** ;
- **Corriger le stock** : saisissez le nombre de bouteilles réellement présentes. C'est un ajustement d'inventaire : il ne compte pas comme une consommation ;
- **Associer un code-barres** / **Changer le code-barres** ;
- **Supprimer le lot**.

**Ajouter un lot** : un autre millésime ou un autre volume de la même boisson.

**Historique** : tous les mouvements, du plus récent au plus ancien (+2 bouteilles, −1 bouteille avec son motif, « Inventaire : 5 »…).

Supprimer une référence supprime aussi ses lots. Pour une bouteille simplement bue jusqu'à la dernière, inutile de supprimer : le lot passe « épuisé », masqué, et reste retrouvable.

---

## 7. Inventaire

**⋮ → Inventaire** : pour vérifier que la cave réelle correspond à l'appli (au début, puis de temps en temps).

1. Choisissez éventuellement **Inclure les lots épuisés**, puis **Commencer**.
2. Les lots défilent un par un : **C'est juste**, ou **Corriger** (saisissez le bon nombre, puis **Valider**). **Précédent** revient en arrière.
3. À la fin, un bilan : lots confirmés, lots corrigés.

Vous pouvez arrêter en cours de route : ce qui est validé est enregistré.

---

## 8. Statistiques

**⋮ → Statistiques** : nombre de bouteilles et de références, répartition par type, par caractéristique, par région ou pays. Aucune notion de prix ou de valeur.

---

## 9. Importer et exporter

### Exporter

**⋮ → Exporter (CSV)** crée deux fichiers lisibles dans Excel ou LibreOffice : le **stock** (références et lots) et l'**historique**. Sur le téléphone : **Partager** (courriel, messagerie…) ou **Enregistrer sur l'appareil** ; sur l'ordinateur : **Enregistrer sur l'appareil**.

### Importer

**⋮ → Importer un fichier** accepte :
- une **sauvegarde ou un export** de Ma Cave ;
- l'**export de Vivino** (`cellar.csv`) ;
- un **fichier préparé dans un tableur**.

Avant tout ajout, un **aperçu** indique ce qui sera créé (références, lots, bouteilles), les fiches qui seront « à compléter » et les lignes ignorées. Rien n'est modifié tant que vous n'avez pas touché **Importer**.

**Réimporter le même fichier ne double pas le stock.** Les fiches déjà présentes ne sont pas modifiées.

### Préparer un fichier dans un tableur

Pour une cave tenue jusqu'ici dans Excel ou LibreOffice : **Importer un fichier → Préparer un fichier dans un tableur**. L'appli affiche les consignes (une ligne par lot, colonnes acceptées, types et caractéristiques de votre cave) et fournit un **fichier modèle** avec deux lignes d'exemple : remplacez-les par vos bouteilles, enregistrez au format CSV, importez. Le volume s'écrit en millilitres (750) ou avec son unité (75 cl, 1,5 l).

### Depuis Vivino

Dans Vivino, demandez l'export de vos données ; vous recevez un fichier `cellar.csv`. Importez-le tel quel. Les vins sans région sont marqués « à compléter ». La note communautaire et le lien Vivino ne sont pas importés.

---

## 10. Synchronisation entre appareils

La synchronisation est **facultative**. Elle sert à :
- utiliser la même cave sur votre téléphone et votre ordinateur (ou deux téléphones) ;
- garder une copie de votre cave hors de l'appareil.

Elle fonctionne avec **votre propre serveur** : Nextcloud, ou tout serveur WebDAV (NAS, hébergeur). Google Drive, Dropbox et OneDrive ne sont pas pris en charge.

### Activer

**⋮ → Paramètres → Synchronisation** (ou étape 1 du premier lancement) :
- **Nextcloud** : adresse du serveur (par exemple `cloud.exemple.fr`), identifiant, **mot de passe d'application** et dossier sur le serveur (`Cave` par défaut, créé s'il n'existe pas et modifiable si nécessaire).
  - Le mot de passe d'application se crée dans Nextcloud : *Paramètres personnels › Sécurité › Créer un nouveau mot de passe d'application*. Il est rangé dans le coffre sécurisé de l'appareil, jamais en clair.
- **Autre serveur WebDAV** : l'adresse complète du dossier.

Puis **Activer la synchronisation**.

**Tous vos appareils doivent utiliser le même serveur et le même dossier.** Si vous personnalisez ce dossier, pensez à le faire sur tous les appareils synchornisés. Ne modifiez jamais à la main le fichier `cave.sqlite` de ce dossier.

Si le serveur contient déjà une **autre** cave et que celle de l'appareil n'est pas vide, l'appli demande laquelle garder : **Utiliser la cave du serveur** (celle de l'appareil est sauvegardée puis remplacée) ou **Remplacer la cave du serveur par celle-ci** (l'ancienne est mise de côté sur le serveur, pas supprimée). Deux caves différentes ne sont jamais mélangées.

### Quand se fait la synchronisation ?

Automatiquement, appli ouverte : à l'ouverture, quand l'appli revient au premier plan, une dizaine de secondes après une modification, au retour du réseau. Et sur demande : **Synchroniser maintenant**.

Une modification faite sur le téléphone n'apparaît donc sur l'ordinateur qu'après **deux** synchronisations : celle du téléphone (qui envoie), puis celle de l'ordinateur (qui reçoit). En cas de doute : **Synchroniser maintenant** sur les deux.

Il n'y a pas de synchronisation en arrière-plan quand l'appli est fermée.

### Sans réseau, ou à deux endroits à la fois

- Sans réseau, tout fonctionne : les modifications attendent le retour du réseau (« En attente du réseau »). Ce n'est pas une erreur.
- Des bouteilles retirées sur deux appareils entre deux synchronisations **s'additionnent** : rien n'est perdu.
- Une même fiche modifiée sur deux appareils : la modification la plus récente l'emporte.

### L'indicateur (petit nuage)

Discret quand tout va bien. En cas de problème, il change d'icône et de couleur, et passe au rouge si l'erreur dure plus de 24 heures. Touchez-le : un message clair explique la cause et propose la solution (**Réessayer**, **Paramètres de synchronisation**…). Vos données ne sont jamais abîmées par une erreur de synchronisation : les modifications restent sur l'appareil.

L'écran Synchronisation propose aussi : la **synchronisation automatique** (désactivable : elle ne se fait alors que sur demande), **Modifier les paramètres**, le **Journal des erreurs** et **Désactiver la synchronisation** (l'appareil garde sa cave et continue seul ; la cave du serveur n'est pas supprimée).

---

## 11. Sauvegardes et restauration

**⋮ → Paramètres → Sauvegardes.**

L'appli sauvegarde **automatiquement** votre cave, à l'ouverture (et à la fermeture sur ordinateur), seulement si elle a changé, à la fréquence choisie (**chaque jour**, chaque semaine ou chaque mois). Chaque sauvegarde comprend une copie de la base et les deux fichiers CSV. Seules les plus récentes sont gardées (**3** par défaut, réglable).

- **Dossier** : `Documents/Cave/Sauvegardes` par défaut, ou un autre dossier de votre choix (**Choisir le dossier** ; sur Android, dans Documents ou Download). Copiez-le de temps en temps ailleurs (clé USB, autre ordinateur, service de stockage) : c'est votre filet de sécurité si l'appareil est perdu.
- En mode synchronisé, la dernière sauvegarde est aussi copiée dans le dossier « Sauvegardes » du serveur.
- **Sauvegarder maintenant**, à tout moment.
- **Restaurer** : touchez une sauvegarde de la liste, ou **Restaurer depuis un fichier…** (par exemple une sauvegarde copiée depuis un autre appareil). La cave actuelle est **d'abord sauvegardée** : vous pouvez toujours revenir en arrière.

Sur Android 8 à 10, l'appli demande l'autorisation d'écrire dans Documents. Si vous l'avez refusée définitivement, **Ouvrir les réglages** vous mène à la page de réglage de ce paramètre.

---

## 12. Espace disque et purge

**⋮ → Paramètres → Espace disque.** Utile seulement après des années d'usage : la base reste petite.

- **Purger l'historique…** : supprime les mouvements antérieurs à une date (au moins un mois en arrière). Les stocks ne changent pas. Une sauvegarde est faite avant.
- **Purge automatique** (désactivée par défaut) : supprime les lots épuisés sans mouvement depuis le délai choisi, et la référence si elle n'a plus aucun lot. Les lots en stock ne sont jamais purgés.

---

## 13. Paramètres

**⋮ → Paramètres** :

- **Apparence** : thème (comme le système, clair ou sombre), taille du texte (normale, grande, très grande).
- **Volumes par défaut** : volume proposé pour une nouvelle bouteille, par type.
- **Types et caractéristiques** : créer, renommer ou supprimer des types (par exemple « Cidre »), des familles (« Région », « Fût ») et des valeurs. Un nouveau type choisit à sa création les champs de sa fiche (« comme un vin », « comme une bière »…), sans retour possible. Supprimer un type ne supprime pas les boissons : elles deviennent « Sans catégorie ».
- **Affichage** : tri à l'ouverture, afficher les références épuisées à l'ouverture, durée du bandeau « Annuler ».
- **Reconnaissance** : activer ou non la recherche sur Open Food Facts.
- **Données** : Synchronisation, Sauvegardes, Espace disque, import et export.
- **À propos** : version, licence, contact (**Écrire un courriel**, **Signaler un problème**, **Code source**), sources des données, licences des logiciels utilisés.

**Ce qui est partagé entre vos appareils** (avec la synchronisation) : la cave elle-même, les volumes par défaut, les types et caractéristiques, la purge automatique. Tous les autres réglages (thème, affichage, sauvegardes…) sont propres à chaque appareil.

---

## 14. Téléphone ou ordinateur : les différences

| | Téléphone (Android) | Ordinateur (Windows, Linux) |
|---|---|---|
| Code-barres | Scan avec l'appareil photo, lampe | Saisie au clavier ou avec une douchette USB |
| Photo de l'étiquette | Oui | Non |
| Partager un fichier (export, sauvegarde) | Oui | Non : « Enregistrer » seulement |
| Liste et fiche | La fiche s'ouvre par-dessus la liste | Côte à côte si la fenêtre est assez large |
| Clavier | — | **Ctrl+F** : recherche · **Échap** : quitter le champ, fermer une fenêtre, revenir en arrière |
| Sauvegarde automatique | À l'ouverture et quand l'appli passe en arrière-plan | À l'ouverture, quand la fenêtre est réduite et à sa fermeture |
| Mot de passe du serveur | Coffre sécurisé d'Android | Gestionnaire d'identification (Windows), trousseau KWallet ou GNOME (Linux) |

Tout le reste est identique.

---

## 15. Questions fréquentes

**J'ai retiré une bouteille par erreur.** Touchez **Annuler** dans le bandeau. Trop tard ? Fiche → menu ⋮ du lot → **Ajouter des bouteilles** (ou **Corriger le stock**).

**Je ne retrouve plus une boisson finie.** Ses lots sont épuisés, donc masqués : **Filtres → Afficher les épuisés**.

**Une modification faite sur le téléphone n'apparaît pas sur l'ordinateur.** Elle n'y arrive qu'après la synchronisation du téléphone, puis celle de l'ordinateur : **Synchroniser maintenant** sur les deux.

**Le petit nuage signale une erreur.** Touchez-le : le message indique la cause et la solution. Rien n'est perdu.

**Je change de téléphone.** Avec la synchronisation : installez l'appli sur le nouveau, choisissez « Synchroniser avec un serveur » avec les mêmes paramètres : votre cave est récupérée. Sans synchronisation : copiez une sauvegarde (`Documents/Cave/Sauvegardes`, fichier `.sqlite`) sur le nouveau téléphone, puis **Paramètres → Sauvegardes → Restaurer depuis un fichier…**.

**L'appli a lu n'importe quoi sur l'étiquette.** Reprenez la photo de plus près, bien à plat, avec la lampe ; ou touchez les bonnes lignes dans « Texte lu » ; ou tapez simplement les champs.

**Je veux repartir de zéro dans un tableur.** **Exporter (CSV)**, retravaillez le fichier « stock », puis importez-le.

---

## 16. Confidentialité

- Votre cave est enregistrée **sur votre appareil**, et, si vous l'activez, sur **votre** serveur : nulle part ailleurs.
- Pas de compte, pas de publicité, pas de statistiques d'usage envoyées.
- **Seule exception** : quand un code-barres inconnu est recherché dans Open Food Facts, **ce code** (et rien d'autre) est envoyé à ce service ; uniquement pour les codes-barres de produits (8 à 14 chiffres), jamais le contenu d'un QR code. Désactivable dans **Paramètres → Reconnaissance**.
- La photo d'une étiquette est lue sur le téléphone, puis supprimée.

---

## 17. Envoyer un retour

Une idée, un défaut, une question ? Vos retours sont précieux, surtout sur une cave et des habitudes différentes des miennes :

- par courriel : **maxence@bouthon.fr** ;
- sur GitHub : **https://github.com/Max-horion/MaCave/issues** (le code source de l'appli y est publié).

Ces liens sont aussi dans **Paramètres → À propos**, rubrique « Contact ». Si l'appareil n'a pas d'appli pour les ouvrir, l'adresse est copiée : collez-la dans votre messagerie ou votre navigateur.

Pour un défaut, précisez si possible : l'appareil (téléphone ou ordinateur, système), la version de l'appli (**Paramètres → À propos**), ce que vous avez fait, ce que vous attendiez et ce qui s'est passé. Une capture d'écran aide beaucoup. N'envoyez jamais votre mot de passe.
