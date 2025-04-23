plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
 
android {
    namespace = "com.example.virtual_glasses_tryon"
    compileSdk = 35 //flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" //flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.virtual_glasses_tryon"
        minSdk = 24 //flutter.minSdkVersion
        targetSdk = 35 //flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            ndk {
                debugSymbolLevel = "none"
            }
        }
    }

    splits {
        abi {
            isEnable = true
            isUniversalApk = false            
            include("arm64-v8a", "armeabi-v7a")
        }
    }
    }
    
    aaptOptions {
        noCompress("tflite")
    }
}

dependencies {
}

flutter {
    source = "../.."
}

