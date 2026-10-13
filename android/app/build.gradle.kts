import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Clé de diffusion (lot 10) : android/key.properties, hors dépôt (.gitignore),
// pointe vers le fichier de clé, lui aussi hors dépôt. Sans ce fichier, ou
// avec CAVE_SIGNING=debug, l'APK de production est signé avec la clé de
// débogage (appareils de développement seulement : jamais diffusé).
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) FileInputStream(file).use { load(it) }
}
val releaseSigning = !keyProperties.isEmpty && System.getenv("CAVE_SIGNING") != "debug"

android {
    namespace = "fr.bouthon.cave"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {

        applicationId = "fr.bouthon.cave"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 8.0 minimum (cahier des charges, section 9).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigning) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("Ma Cave : APK signé avec la clé de DÉBOGAGE (ne pas diffuser).")
                signingConfigs.getByName("debug")
            }
            // Règles d'optimisation propres à l'appli (Tesseract).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Tesseract 5 (lot 5d), appelé par MainActivity.kt. Variante OpenMP :
    // plusieurs cœurs, une seule instance à la fois.
    implementation("cz.adaptech.tesseract4android:tesseract4android-openmp:4.9.0")
    // ZXing (lot 7) : lecteur de codes-barres libre (Apache 2.0), en Java,
    // sans code natif ; appelé par MainActivity.kt.
    implementation("com.google.zxing:core:3.5.4")
}
