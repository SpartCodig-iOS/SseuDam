import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "Data",
    dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .project(target: "NetworkService", path: "../NetworkService")
    ]
)