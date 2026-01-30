import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "db.memorium.memorium"
    compileSdk = 36

    defaultConfig {
        applicationId = "db.memorium.memorium"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    signingConfigs {
        create("release") {
            // Verifico si el fitxer de propietats existeix i té la ruta del keystore
            val keyPath = keystoreProperties["storeFile"]?.toString()
            if (keystorePropertiesFile.exists() && !keyPath.isNullOrEmpty()) {
                keyAlias = keystoreProperties["keyAlias"]?.toString()
                keyPassword = keystoreProperties["keyPassword"]?.toString()
                storeFile = file(keyPath)
                storePassword = keystoreProperties["storePassword"]?.toString()
            } else {
                // Si no es troba, mostro un avís però no tallo la build
                println("AVÍS: No s'ha trobat key.properties o storeFile. La build no estarà signada.")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Només assigno la signatura si el fitxer storeFile s'ha pogut carregar
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile != null) {
                signingConfig = releaseConfig
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
