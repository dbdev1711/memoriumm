import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "db.memorium.memorium"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "db.memorium.memorium"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // AndroidX i Core Libraries
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-common-java8:2.8.7")
    implementation("androidx.annotation:annotation:1.9.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.core:core-ktx:1.15.0")

    // Configuració de rutes del SDK de Flutter
    val properties = Properties()
    val propertiesFile = rootProject.file("local.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { properties.load(it) }
    }
    val flutterSdkPath = properties.getProperty("flutter.sdk") ?: ""
    
    // 1. Resolem errors de 'io.flutter' (MainActivity i Registrant)
    if (flutterSdkPath.isNotEmpty()) {
        compileOnly(files("$flutterSdkPath/bin/cache/artifacts/engine/android-arm64/flutter.jar"))
    }

    // 2. Resolem els 7 errors de plugins (Forcem l'enllaç manual)
    // Això permet que el compilador de Java trobi les classes dels plugins descarregats
    implementation(project(":google_mobile_ads"))
    implementation(project(":package_info_plus"))
    implementation(project(":path_provider_android"))
    implementation(project(":permission_handler_android"))
    implementation(project(":shared_preferences_android"))
    implementation(project(":url_launcher_android"))
    implementation(project(":webview_flutter_android"))
}
