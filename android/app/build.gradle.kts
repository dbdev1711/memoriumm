plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "db.memorium.memorium"
    // ACTUALITZAT: Les teves llibreries demanen l'SDK 36
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ACTIVAT: Necessari per a flutter_local_notifications (Java 8 support)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "db.memorium.memorium"
        minSdk = flutter.minSdkVersion
        // Mantenim targetSdk a 34 o 35 segons prefereixis, però compileSdk ha de ser 36
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // AFEGIT: Llibreria per al suport de dates en versions antigues d'Android
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
