# Ma Cave — licence

Copyright © 2026 Maxence Pithon

Ma Cave est un logiciel libre : vous pouvez le redistribuer et le modifier
selon les termes de la **GNU General Public License** publiée par la Free
Software Foundation, **version 3 ou (à votre choix) toute version
ultérieure** (texte complet : fichier [`LICENSE`](LICENSE)).

Ce programme est distribué dans l'espoir qu'il sera utile, mais **sans aucune
garantie**, sans même la garantie implicite de qualité marchande ou
d'adéquation à un usage particulier. Voir la GNU GPL pour plus de détails.

## Exception : liaison avec Google ML Kit

L'application utilise Google ML Kit (lecture des codes-barres et du texte des
étiquettes), une bibliothèque gratuite mais non libre. Pour que la
distribution de l'application reste permise, une autorisation supplémentaire
est accordée au titre de l'article 7 de la GPL v3. Seule la version anglaise
ci-dessous fait foi :

> Additional permission under GNU GPL version 3 section 7
>
> If you modify this Program, or any covered work, by linking or combining it
> with Google ML Kit (or a modified version of that library), containing parts
> covered by the terms of the ML Kit Terms of Service
> (https://developers.google.com/ml-kit/terms), the licensors of this Program
> grant you additional permission to convey the resulting work.

## Éléments de tiers

| Élément | Auteur / source | Licence |
|---|---|---|
| Icône (bouteille, `tool/icon/bottle.svg`) | Tabler Icons, © Paweł Kuna | MIT (`tool/icon/LICENSE`) |
| Appellations (`assets/appellations.txt`) | INAO, data.gouv.fr | Licence Ouverte / Etalab 2.0 |
| Dictionnaire français de Tesseract (`assets/tessdata/`) | tesseract-ocr/tessdata_best | Apache 2.0 |
| Tesseract, Tesseract4Android | tesseract-ocr ; Adaptech | Apache 2.0 |
| Leptonica (avec Tesseract) | Leptonica, Dan Bloomberg | BSD 2 clauses (`assets/licenses/leptonica.txt`) |
| libpng (avec Tesseract) | The PNG Reference Library Authors | PNG Reference Library License v2 (`assets/licenses/libpng.txt`) |
| libjpeg (avec Tesseract) | Independent JPEG Group | Licence IJG (`assets/licenses/libjpeg.txt`) : ce logiciel est basé en partie sur les travaux de l'Independent JPEG Group |
| Google ML Kit | Google | Conditions d'utilisation de ML Kit |
| Fiches pré-remplies | Open Food Facts (données consultées en ligne) | ODbL |

Les licences des bibliothèques Dart/Flutter sont affichées dans l'application
(Paramètres → À propos → Licences des logiciels).
