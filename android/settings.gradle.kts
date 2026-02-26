pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // 🔹 ANDROID
    id("com.android.application") version "8.11.1" apply false

    // 🔹 KOTLIN
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false

    // 🔹 GOOGLE SERVICES (WAJIB UNTUK FIREBASE)
    id("com.google.gms.google-services") version "4.4.4" apply false
}

include(":app")
