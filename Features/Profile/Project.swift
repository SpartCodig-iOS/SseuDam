import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Profile,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)