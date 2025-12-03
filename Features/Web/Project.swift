import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Web,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)