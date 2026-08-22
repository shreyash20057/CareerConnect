import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ensure plugin library modules compile with a minimum compileSdk
subprojects {
    plugins.withId("com.android.library") {
        val libExt = project.extensions.findByName("android") as? com.android.build.api.dsl.LibraryExtension
        libExt?.compileSdk = 36
    }
}

// Ensure plugin library modules compile with a minimum compileSdk
subprojects {
    plugins.withId("com.android.library") {
        val libExt = project.extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
        libExt?.compileSdk = 36
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
