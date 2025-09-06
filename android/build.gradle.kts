buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath('com.android.tools.build:gradle:8.1.4')
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // Add the Google services Gradle plugin
        classpath('com.google.gms:google-services:4.4.3')
    }
}

plugins {
    id("com.android.application") version "8.1.4" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file('../build')
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
