import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "Domain",
    dependencies: [
        .SPM.LogMacro
    ],
    hasTests: true
)
