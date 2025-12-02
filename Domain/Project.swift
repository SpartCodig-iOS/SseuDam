import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "Domain",
    dependencies: [
      .SPM.ComposableArchitecture,
      .SPM.LogMacro,
    ],
    hasTests: true,
)
