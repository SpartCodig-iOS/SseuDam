import ProjectDescription
import ModularAppPlugin

let project = Project.makeFramework(
    name: "Data",
    dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .project(target: "NetworkService", path: "../NetworkService")
    ]
)