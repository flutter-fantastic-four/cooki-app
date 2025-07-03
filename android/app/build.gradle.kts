import java.util.Properties
import java.io.FileInputStream
import java.io.FileNotFoundException
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val properties = Properties().apply {
    try {
    load(FileInputStream(rootProject.file("key.properties")))
    } catch (e: FileNotFoundException) {
        // Fallback for development when key.properties doesn't exist
        put("KAKAO_API_KEY", "placeholder_key")
    }
}

android {
    namespace = "com.fantasticfour.cooki"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.2.12479018"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.fantasticfour.cooki"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
         debug {
            isMinifyEnabled = false
            manifestPlaceholders["KAKAO_API_KEY"] = properties["KAKAO_API_KEY"] as String
        }
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            manifestPlaceholders["KAKAO_API_KEY"] = properties["KAKAO_API_KEY"] as String
            // Use debug signing for now - replace with your own signing config for production
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
