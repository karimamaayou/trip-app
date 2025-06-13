plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.frontend"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Pour configurer une vraie clé :
            // keyAlias = "myKeyAlias"
            // keyPassword = "myKeyPassword"
            // storeFile = file("path/to/keystore.jks")
            // storePassword = "myStorePassword"
        }
    }

    buildTypes {
        getByName("release") {
            // ⚠️ Important : les deux doivent être cohérents
            isMinifyEnabled = false
            isShrinkResources = false // ✅ désactive shrinkResources
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
