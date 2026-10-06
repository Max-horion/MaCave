# Règles pour R8 (optimisation de l'APK de production).

# ML Kit, reconnaissance de texte (lot 5c) : seul le modèle des lettres
# latines est embarqué. Le module Flutter fait aussi référence aux modèles
# chinois, devanagari, japonais et coréen, absents : R8 ne doit pas s'en
# inquiéter (ils ne sont jamais utilisés).
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
