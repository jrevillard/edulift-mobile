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

// Function to check if Firebase is enabled for a flavor
fun isFirebaseEnabled(flavor: String): Boolean {
    val configFile = rootProject.file("../config/$flavor.json")
    if (!configFile.exists()) {
        return true // Default to enabled if config doesn't exist
    }
    val jsonSlurper = JsonSlurper()
    @Suppress("UNCHECKED_CAST")
    val json = jsonSlurper.parse(configFile) as Map<String, Any>
    return json["FIREBASE_ENABLED"] as? Boolean ?: true
}

// Firebase plugins will be applied conditionally per flavor
// We'll disable them for flavors where FIREBASE_ENABLED is false

// Apply Firebase plugins globally, but we'll disable their processing for flavors where needed
// This is a workaround since Gradle plugins can't be easily applied conditionally per variant
if (isFirebaseEnabled("staging") || isFirebaseEnabled("production")) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
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

// Function to parse deep link URL and extract scheme, host, and port separately
data class DeepLinkConfig(val scheme: String, val host: String?, val port: String?)

fun parseDeepLinkUrl(url: String): DeepLinkConfig {
    return when {
        // HTTPS URL (e.g., "https://transport.tanjama.fr:50443/")
        url.startsWith("https://") -> {
            val urlWithoutScheme = url.removePrefix("https://")
            val hostAndPort = urlWithoutScheme.trimEnd('/').split("/").first()

            if (hostAndPort.isBlank()) {
                throw IllegalArgumentException("HTTPS URLs must specify a host: $url")
            }

            // Check if port is specified
            val (host, port) = if (hostAndPort.contains(":")) {
                val parts = hostAndPort.split(":")
                Pair(parts[0], parts[1])
            } else {
                Pair(hostAndPort, null) // Use null instead of empty string to avoid XML parsing errors
            }

            DeepLinkConfig(scheme = "https", host = host, port = port)
        }
        // Custom scheme (e.g., "edulift://", "eduliftxxx://", "myapp://")
        // Custom schemes should NOT have a host - they work like "myapp://" not "myapp://host.com"
        url.contains("://") -> {
            val scheme = url.substringBefore("://")
            val afterScheme = url.substringAfter("://").trimEnd('/')

            // Custom schemes should have nothing or only "/" after the scheme
            if (afterScheme.isNotBlank()) {
                throw IllegalArgumentException(
                    "Custom scheme URLs should not specify a host. Use format like 'myapp://' not 'myapp://host.com'. " +
                    "For HTTPS URLs with hosts, use 'https://host.com'. Got: $url"
                )
            }

            DeepLinkConfig(scheme = scheme, host = null, port = null)
        }
        else -> throw IllegalArgumentException("Unsupported deep link URL format: $url")
    }
}

// Function to generate intent filters as XML (single section with conditional host and port)
fun generateAllIntentFilters(config: DeepLinkConfig): String {
    val autoVerify = config.scheme == "https"
    val hostAttribute = if (config.host.isNullOrEmpty()) "" else " android:host=\"${config.host}\""
    val portAttribute = if (config.port.isNullOrEmpty()) "" else " android:port=\"${config.port}\""

    return """
      <!-- Intent filters generated from config (host and port included if present) -->
      <intent-filter android:autoVerify="$autoVerify">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="${config.scheme}"$hostAttribute$portAttribute android:pathPrefix="/auth"/>
      </intent-filter>
      <intent-filter android:autoVerify="$autoVerify">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="${config.scheme}"$hostAttribute$portAttribute android:pathPrefix="/groups"/>
      </intent-filter>
      <intent-filter android:autoVerify="$autoVerify">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="${config.scheme}"$hostAttribute$portAttribute android:pathPrefix="/families"/>
      </intent-filter>
      <intent-filter android:autoVerify="$autoVerify">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="${config.scheme}"$hostAttribute$portAttribute android:pathPrefix="/dashboard"/>
      </intent-filter>
      <intent-filter android:autoVerify="$autoVerify">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="${config.scheme}"$hostAttribute$portAttribute android:pathPrefix="/invite"/>
      </intent-filter>
      <!-- Catch-all for root path -->
      <intent-filter android:autoVerify="$autoVerify">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="${config.scheme}"$hostAttribute$portAttribute/>
      </intent-filter>
    """.trimIndent()
}

android {
    namespace = "com.edulift.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Disable Google Services processing for flavors where Firebase is disabled
    gradle.taskGraph.whenReady {
        tasks.all {
            if (name.contains("GoogleServices") &&
                ((name.contains("E2e") && !isFirebaseEnabled("e2e")) ||
                 (name.contains("Development") && !isFirebaseEnabled("development")))) {
                enabled = false
            }
        }
    }

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
            // (manifests will be automatically generated)
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "EduLift Staging")
            resValue("string", "FLAVOR", "staging")

            // Deep link configuration from config/staging.json
            // (manifests will be automatically generated)
        }

        create("e2e") {
            dimension = "environment"
            applicationIdSuffix = ".e2e"
            versionNameSuffix = "-e2e"
            resValue("string", "app_name", "EduLift E2E")
            resValue("string", "FLAVOR", "e2e")

            // Deep link configuration from config/e2e.json
            // (manifests will be automatically generated)
        }

        create("production") {
            dimension = "environment"
            // No suffix for production - clean package name
            resValue("string", "app_name", "EduLift")
            resValue("string", "FLAVOR", "production")

            // Deep link configuration from config/production.json
            // (manifests will be automatically generated)
        }
    }
    
    // Set custom APK name with flavor
    applicationVariants.all { variant ->
        variant.outputs.all { output ->
            val outputImpl = output as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            outputImpl.outputFileName = "edulift-${variant.flavorName}-${variant.buildType.name}.apk"
            return@all true
        }
    }
}




/**
 * Generates the XML content for a partial manifest file.
 * @param intentFiltersXml The generated <intent-filter> block.
 * @param activityName The target activity name, e.g., ".MainActivity".
 * @return The complete content of the partial AndroidManifest.xml file.
 */
fun createPartialManifestContent(intentFiltersXml: String, activityName: String = ".MainActivity"): String {
    return """<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <application>
        <activity
            android:name="$activityName"
            android:exported="true"
            tools:node="merge">
${intentFiltersXml.lines().joinToString("\n            ")}
            </activity>
        </application>
    </manifest>""".trimIndent()
}

// Logic to create and link manifest generation tasks
android.applicationVariants.all {
    val variant = this
    val flavorName = variant.flavorName

    // Create a task to generate the manifest for this specific flavor.
    // Use the full variant name to avoid conflicts
    val generateManifestTaskName = "generateDeepLinkManifestFor${variant.name}"
    val generateManifestTaskProvider = tasks.register(generateManifestTaskName) {
        group = "Manifest Generation"
        description = "Generates the partial AndroidManifest.xml for the $flavorName flavor."

        doLast {
            // 1. Define input and output paths
            val configJsonFile = project.file("../../config/$flavorName.json")
            val outputDir = project.file("src/$flavorName")
            val manifestOutputFile = project.file("$outputDir/AndroidManifest.xml")

            if (!configJsonFile.exists()) {
                throw GradleException("Configuration file not found: ${configJsonFile.path}")
            }

            // 2. Read configuration and generate <intent-filter> block
            val deepLinkUrl = getDeepLinkBaseUrl(flavorName)
            val config = parseDeepLinkUrl(deepLinkUrl)
            val intentFilters = generateAllIntentFilters(config)

            if (intentFilters.isBlank()) {
                println("No intent filters generated for flavor '$flavorName'. Skipping manifest creation.")
                return@doLast
            }

            // 3. Generate complete partial manifest content
            val manifestContent = createPartialManifestContent(intentFilters)

            // 4. Write file
            outputDir.mkdirs()
            manifestOutputFile.writeText(manifestContent)

            println("Generated partial manifest for '$flavorName' at ${manifestOutputFile.path}")
        }
    }

    // 5. Link our task to the build cycle.
    // The main manifest processing task depends on our generation
    tasks.named("process${variant.name.replaceFirstChar { it.uppercase() }}MainManifest") {
        dependsOn(generateManifestTaskProvider)
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