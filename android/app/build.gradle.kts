import java.util.Properties
import groovy.json.JsonSlurper

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

// Function to parse config JSON and extract DEEP_LINK_BASE_URL
fun getDeepLinkBaseUrl(flavor: String): String {
    val configFile = rootProject.file("../config/$flavor.json")
    if (!configFile.exists()) {
        throw IllegalStateException("Config file not found: ${configFile.absolutePath}")
    }
    val jsonSlurper = JsonSlurper()
    @Suppress("UNCHECKED_CAST")
    val json = jsonSlurper.parse(configFile) as Map<String, Any>
    return json["DEEP_LINK_BASE_URL"] as String
}

// Function to parse deep link URL and extract scheme and host
data class DeepLinkConfig(val scheme: String, val host: String?)

fun parseDeepLinkUrl(url: String): DeepLinkConfig {
    return when {
        // Custom scheme (e.g., "edulift://")
        url.startsWith("edulift://") -> {
            DeepLinkConfig(scheme = "edulift", host = null)
        }
        // HTTPS URL (e.g., "https://transport.tanjama.fr:50443/")
        url.startsWith("https://") -> {
            val urlWithoutScheme = url.removePrefix("https://")
            val host = urlWithoutScheme.trimEnd('/').let {
                // Extract host (with port if present), removing any path
                it.split("/").first()
            }
            DeepLinkConfig(scheme = "https", host = host)
        }
        else -> throw IllegalArgumentException("Unsupported deep link URL format: $url")
    }
}

android {
    namespace = "com.edulift.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.edulift.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }

    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "EduLift Dev")
            resValue("string", "FLAVOR", "development")

            // Deep link configuration from config/development.json
            val deepLinkUrl = getDeepLinkBaseUrl("development")
            val config = parseDeepLinkUrl(deepLinkUrl)
            manifestPlaceholders.apply {
                put("deepLinkScheme", config.scheme)
                put("deepLinkHost", config.host ?: "")
            }
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "EduLift Staging")
            resValue("string", "FLAVOR", "staging")

            // Deep link configuration from config/staging.json
            val deepLinkUrl = getDeepLinkBaseUrl("staging")
            val config = parseDeepLinkUrl(deepLinkUrl)
            manifestPlaceholders.apply {
                put("deepLinkScheme", config.scheme)
                put("deepLinkHost", config.host ?: "")
            }
        }

        create("e2e") {
            dimension = "environment"
            applicationIdSuffix = ".e2e"
            versionNameSuffix = "-e2e"
            resValue("string", "app_name", "EduLift E2E")
            resValue("string", "FLAVOR", "e2e")

            // Deep link configuration from config/e2e.json
            val deepLinkUrl = getDeepLinkBaseUrl("e2e")
            val config = parseDeepLinkUrl(deepLinkUrl)
            manifestPlaceholders.apply {
                put("deepLinkScheme", config.scheme)
                put("deepLinkHost", config.host ?: "")
            }
        }

        create("production") {
            dimension = "environment"
            // No suffix for production - clean package name
            resValue("string", "app_name", "EduLift")
            resValue("string", "FLAVOR", "production")

            // Deep link configuration from config/production.json
            val deepLinkUrl = getDeepLinkBaseUrl("production")
            val config = parseDeepLinkUrl(deepLinkUrl)
            manifestPlaceholders.apply {
                put("deepLinkScheme", config.scheme)
                put("deepLinkHost", config.host ?: "")
            }
        }
    }
    
    // Set custom APK name with flavor
    applicationVariants.all { variant ->
        variant.outputs.all { output ->
            val outputImpl = output as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            outputImpl.outputFileName = "edulift-${variant.flavorName}-${variant.buildType.name}.apk"
            return@all true
        }
        return@all true
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for modern Java features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Firebase dependencies - available for all flavors (controlled by FeatureFlags)
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-crashlytics-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.android.gms:play-services-base:18.5.0")
    
    // AndroidTest dependencies - Required for test orchestrator
    androidTestImplementation("androidx.test:core:1.5.0")
    androidTestImplementation("androidx.test:runner:1.5.1")
    androidTestImplementation("androidx.test:rules:1.2.0")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.services:test-services:1.4.2")
    
    // Patrol Android Test dependencies
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}