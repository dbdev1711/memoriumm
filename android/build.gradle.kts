allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = layout.buildDirectory.asFile.get()

subprojects {
    project.buildDir = layout.buildDirectory.asFile.get().resolve(project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
