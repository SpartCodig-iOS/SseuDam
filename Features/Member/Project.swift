import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Member,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)