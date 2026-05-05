plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.example.nebuleuse_app"
    compileSdk = flutter.compileSdkVersion

    // ✅ Configuration de la signature
    signingConfigs {
        create("release") {
            keyAlias = "nebuleuse"
            keyPassword = "Ndepete@nni2001"       // ← ton mot de passe
            storeFile = file("C:\\Users\\dimit\\nebuleuse_key.jks")
            storePassword = "Ndepete@nni2001"     // ← ton mot de passe
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.nebuleuse_app"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") // ✅
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}