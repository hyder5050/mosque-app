allprojects {
    repositories {
        google()
        mavenCentral()
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
    // Avoid forcing evaluation of the :app project during root configuration because
    // the :app project may require the Android NDK to be installed; use a safer hook.
    // If you need to coordinate tasks across projects, use gradle.projectsEvaluated { ... }
    // or set explicit task dependencies instead of evaluationDependsOn.
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
