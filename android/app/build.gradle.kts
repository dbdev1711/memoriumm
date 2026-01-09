import java.util.Properties

// 1. Llegir el fitxer key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "db.memorium.memorium"
    // Forcem a 35 per compatibilitat amb el Gradle Plugin 8.9.1
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    // 2. Configurar la signatura
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "db.memorium.memorium"
        // Mínim 21 per suportar les llibreries actuals sense errors de verificació
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Indispensable per a projectes amb moltes dependències (Firebase, AdMob, Upgrader)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // Optimització per a la botiga
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Afegim la dependència de MultiDex per a suport en versions antigues d'Android
    implementation("androidx.multidex:multidex:2.0.1")
}
