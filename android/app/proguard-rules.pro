# Règles pour R8 (optimisation de l'APK de production).

# Tesseract (lot 5d) : la bibliothèque native appelle ces classes par leur
# nom (JNI) ; R8 ne doit ni les renommer ni les supprimer.
-keep class com.googlecode.tesseract.android.** { *; }
