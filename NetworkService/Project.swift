import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "NetworkService",
    dependencies: [
        .SPM.Moya,
        .SPM.LogMacro
    ]
)
