plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lista_do_mercadinho"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.alefbs.mercadofacil"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 1. PRIMEIRO ELE CRIA A ASSINATURA AQUI
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "Blacksabbath21@"
            storePassword = "Blacksabbath21@"
            storeFile = file("upload-keystore.jks") 
        }
    }

    // 2. DEPOIS ELE APLICA A ASSINATURA NA VERSÃO FINAL
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}