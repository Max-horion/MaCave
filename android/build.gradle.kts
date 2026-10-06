allprojects {
    repositories {
        google()
        mavenCentral()
        // Tesseract4Android (lot 5d), publié sur JitPack seulement, et
        // seulement pour ce groupe (aucune autre bibliothèque n'en vient).
        maven {
            url = uri("https://jitpack.io")
            content { includeGroup("cz.adaptech.tesseract4android") }
        }
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
