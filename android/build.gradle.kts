allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val safeBuildDir = file("C:/flutter_builds/e_tarabay_v2")

rootProject.layout.buildDirectory.set(safeBuildDir)

subprojects {
    val subprojectBuildDir = safeBuildDir.resolve(project.name)
    project.layout.buildDirectory.set(subprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
