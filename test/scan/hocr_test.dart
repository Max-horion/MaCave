import 'dart:io';

import 'package:cave/scan/label_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

// Extrait hOCR inventé, au format de Tesseract 4.
const _hocr = '''
<div class='ocr_page' id='page_1' title='image ""; bbox 0 0 1080 1920; ppageno 0'>
 <div class='ocr_carea' id='block_1_1' title="bbox 100 200 980 400">
  <p class='ocr_par' id='par_1_1' lang='fra' title="bbox 100 200 980 400">
   <span class='ocr_header' id='line_1_1' title="bbox 120 210 960 300; baseline 0 -10; x_size 82; x_descenders 10; x_ascenders 20">
    <span class='ocrx_word' id='word_1_1' title='bbox 120 210 500 300; x_wconf 91'>CHÂTEAU</span>
    <span class='ocrx_word' id='word_1_2' title='bbox 520 210 960 300; x_wconf 88'><strong>DES&amp;LUNES</strong></span>
   </span>
   <span class='ocr_line' id='line_1_2' title="bbox 400 320 680 360; baseline 0 -5; x_size 30">
    <span class='ocrx_word' id='word_1_3' title='bbox 400 320 680 360; x_wconf 95'>2019</span>
    <span class='ocrx_word' id='word_1_4' title='bbox 690 320 700 360; x_wconf 12'>~</span>
   </span>
   <span class='ocr_line' id='line_1_3' title="bbox 10 380 50 400">
    <span class='ocrx_word' id='word_1_5' title='bbox 10 380 50 400; x_wconf 20'>%#</span>
   </span>
   <span class='ocr_line' id='line_1_4' title="bbox 100 900 400 930; baseline 0 -3">
    <span class='ocrx_word' id='word_1_6' title='bbox 100 900 200 930; x_wconf 77'>14%</span>
    <span class='ocrx_word' id='word_1_7' title='bbox 210 900 400 930; x_wconf 70'>vol.</span>
   </span>
  </p>
 </div>
</div>
''';

void main() {
  test('lignes, taille des lettres, mots peu sûrs écartés', () {
    final lines = parseHocr(_hocr);
    expect(lines.map((l) => l.text), ['CHÂTEAU DES&LUNES', '2019', '14% vol.']);
    // x_size quand il est donné, sinon la hauteur du cadre.
    expect(lines.map((l) => l.height), [82, 30, 30]);
  });

  test('diagnostic : mots gardés et écartés', () {
    final r = readHocr(_hocr);
    expect((r.kept, r.dropped), (5, 2));
  });

  test('tous les mots peu sûrs : gardés quand même', () {
    const doubtful = '''
<span class='ocr_line' id='line_1_1' title="bbox 0 0 100 40; x_size 30">
 <span class='ocrx_word' id='word_1_1' title='bbox 0 0 50 40; x_wconf 22'>CHATEAV</span>
 <span class='ocrx_word' id='word_1_2' title='bbox 55 0 100 40; x_wconf 18'>LUNE5</span>
</span>''';
    final r = readHocr(doubtful);
    expect(r.lines.single.text, 'CHATEAV LUNE5');
    expect(r.kept, 2);
  });

  test('vrai résultat de Tesseract 5 (étiquette inventée, photo droite)', () {
    // test/fixtures/etiquette_tesseract5.hocr : produit par Tesseract 5.5 et
    // le dictionnaire de l'appli, sur une étiquette fabriquée pour le test.
    final hocr = File('test/fixtures/etiquette_tesseract5.hocr')
        .readAsStringSync();
    final lines = parseHocr(hocr);
    expect(lines.map((l) => l.text), contains('CHÂTEAU DES LUNES'));
    expect(lines.map((l) => l.text), contains('14% vol.'));
    // Le nom, écrit le plus gros, a la plus grande hauteur.
    final tallest = lines.reduce((a, b) => a.height >= b.height ? a : b);
    expect(tallest.text, 'CHÂTEAU DES LUNES');
  });

  test('texte courbe : mots en lignes séparées, côte à côte, regroupés', () {
    // Nom en arc : Tesseract rend chaque mot sur sa propre ligne, chacun un
    // peu plus bas que le précédent, et dans le désordre.
    const curved = '''
<span class='ocr_line' id='line_1_1' title="bbox 420 230 600 310; x_size 70">
 <span class='ocrx_word' id='word_1_1' title='bbox 420 230 600 310; x_wconf 90'>LES</span>
</span>
<span class='ocr_line' id='line_1_2' title="bbox 100 200 400 290; x_size 72">
 <span class='ocrx_word' id='word_1_2' title='bbox 100 200 400 290; x_wconf 92'>CHÂTEAU</span>
</span>
<span class='ocr_line' id='line_1_3' title="bbox 630 260 900 345; x_size 68">
 <span class='ocrx_word' id='word_1_3' title='bbox 630 260 900 345; x_wconf 88'>LUNES</span>
</span>
<span class='ocr_line' id='line_1_4' title="bbox 380 420 560 460; x_size 30">
 <span class='ocrx_word' id='word_1_4' title='bbox 380 420 560 460; x_wconf 95'>2019</span>
</span>
<span class='ocr_line' id='line_1_5' title="bbox 100 900 260 930; x_size 22">
 <span class='ocrx_word' id='word_1_5' title='bbox 100 900 260 930; x_wconf 90'>13%</span>
</span>
<span class='ocr_line' id='line_1_6' title="bbox 800 900 900 930; x_size 22">
 <span class='ocrx_word' id='word_1_6' title='bbox 800 900 900 930; x_wconf 90'>75cl</span>
</span>''';
    final lines = parseHocr(curved);
    expect(lines.map((l) => l.text), [
      'CHÂTEAU LES LUNES',
      '2019',
      // Trop loin l'un de l'autre : deux mentions distinctes.
      '13%',
      '75cl',
    ]);
    expect(lines.first.height, 72);
  });

  test('vrai résultat de Tesseract 5 : nom en escalier recomposé', () {
    // test/fixtures/etiquette_courbe_tesseract5.hocr : Tesseract 5.5 et le
    // dictionnaire de l'appli, sur une étiquette inventée dont les mots du
    // nom descendent en escalier (comme sur une bouteille vue de biais) ;
    // Tesseract rend « CHÂTEAU », « DES », « QUATRE VENTS » séparément.
    final hocr = File('test/fixtures/etiquette_courbe_tesseract5.hocr')
        .readAsStringSync();
    expect(parseHocr(hocr).map((l) => l.text), [
      'CHÂTEAU DES QUATRE VENTS',
      '2016',
    ]);
  });

  test('lignes l\'une au-dessus de l\'autre : jamais regroupées', () {
    const stacked = '''
<span class='ocr_line' id='line_1_1' title="bbox 100 100 500 160; x_size 50">
 <span class='ocrx_word' id='word_1_1' title='bbox 100 100 500 160; x_wconf 90'>DOMAINE</span>
</span>
<span class='ocr_line' id='line_1_2' title="bbox 100 170 500 230; x_size 50">
 <span class='ocrx_word' id='word_1_2' title='bbox 100 170 500 230; x_wconf 90'>IMAGINAIRE</span>
</span>
<span class='ocr_line' id='line_1_3' title="bbox 520 110 700 150; x_size 20">
 <span class='ocrx_word' id='word_1_3' title='bbox 520 110 700 150; x_wconf 90'>petit</span>
</span>''';
    expect(parseHocr(stacked).map((l) => l.text), [
      'DOMAINE',
      'IMAGINAIRE',
      // À côté, mais lettres bien plus petites : autre mention.
      'petit',
    ]);
  });

  test('résultat vide', () {
    expect(parseHocr(''), isEmpty);
  });
}
