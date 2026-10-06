# Règles pour R8 (optimisation de l'APK de production).

# ML Kit, reconnaissance de texte (lot 5c) : seul le modèle des lettres
# latines est embarqué. Le module Flutter fait aussi référence aux modèles
# chinois, devanagari, japonais et coréen, absents : R8 ne doit pas s'en
# inquiéter (ils ne sont jamais utilisés).
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Tesseract (lot 5d) : la bibliothèque native appelle ces classes par leur
# nom (JNI) ; R8 ne doit ni les renommer ni les supprimer.
-keep class com.googlecode.tesseract.android.** { *; }
