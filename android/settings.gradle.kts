pluginManagement {
    val properties = java.util.Properties()
    val propertiesFile = File(settingsDir, "local.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { properties.load(it) }
    }
    val flutterSdkPath = properties.getProperty("flutter.sdk") ?: ""
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.0" apply false
}

include(":app")

// FORÇAR EL REGISTRE DELS PLUGINS D'ANDROID
val flutterProjectRoot = settingsDir.parentFile
val pluginsFile = File(flutterProjectRoot, ".flutter-plugins")

if (pluginsFile.exists()) {
    pluginsFile.readLines().forEach { line ->
        if (line.isNotBlank() && !line.startsWith("#")) {
            val parts = line.split("=")
            if (parts.size == 2) {
                val name = parts[0]
                val path = parts[1]
                // Registrem el mòdul d'Android del plugin
                include(":$name")
                project(":$name").projectDir = File(path, "android")
            }
        }
    }
}
