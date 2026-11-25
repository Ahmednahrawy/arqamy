import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val requiredSigningProperties = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
)
val hasCompleteSigningProperties = requiredSigningProperties.all { property ->
    !keystoreProperties.getProperty(property).isNullOrBlank()
}
val configuredStorePath = keystoreProperties.getProperty("storeFile")?.trim().orEmpty()
val releaseKeystoreFile = if (configuredStorePath.isEmpty()) {
    null
} else {
    val configuredFile = File(configuredStorePath)
    if (configuredFile.isAbsolute) configuredFile else rootProject.file(configuredStorePath)
}

android {
    namespace = "com.nahro.arqamy"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nahro.arqamy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasCompleteSigningProperties && releaseKeystoreFile != null) {
                keyAlias = keystoreProperties.getProperty("keyAlias").trim()
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseKeystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to debug signing. The task check below validates
            // the complete configuration before producing a release artifact.
            signingConfig = if (hasCompleteSigningProperties && releaseKeystoreFile != null) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

// Release artifacts must use a complete, existing keystore or not be produced.
tasks.matching { it.name == "assembleRelease" || it.name == "bundleRelease" }
    .configureEach {
        doFirst {
            if (!keystorePropertiesFile.isFile) {
                throw GradleException(
                    "Release signing is not configured. Create android/key.properties " +
                        "using android/key.properties.example."
                )
            }

            val missingProperties = requiredSigningProperties.filter { property ->
                keystoreProperties.getProperty(property).isNullOrBlank()
            }
            if (missingProperties.isNotEmpty()) {
                throw GradleException(
                    "Release signing configuration is incomplete. Set: " +
                        missingProperties.joinToString(", ") +
                        " in android/key.properties."
                )
            }

            val keystore = releaseKeystoreFile
                ?: throw GradleException(
                    "Release signing storeFile is empty. Set it in android/key.properties."
                )
            if (!keystore.isFile) {
                throw GradleException(
                    "Release signing keystore was not found at the configured storeFile path."
                )
            }
        }
    }

// Modern syntax replacing the old inside-android kotlinOptions block
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17

    }
}

flutter {
    source = "../.."
}
