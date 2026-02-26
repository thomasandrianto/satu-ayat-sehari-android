plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")

    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")

    // 🔥 Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.thomas.satu_ayat_sehari_android"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.thomas.satu_ayat_sehari_android"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {

    // 🔹 Kotlin
    implementation(kotlin("stdlib"))

    // 🔹 Java 8+ desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // 🔹 AndroidX
    implementation("androidx.core:core-ktx:1.13.1")

    // 🔥 FIREBASE (BoM)
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    // 🔥 Firebase Products (pilih sesuai kebutuhan)
    implementation("com.google.firebase:firebase-messaging")
    // implementation("com.google.firebase:firebase-analytics")
}
