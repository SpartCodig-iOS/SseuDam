import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "DesignSystem",
    dependencies: [
      .SPM.ComposableArchitecture
    ],
    resources: ["Resources/**"]
)
