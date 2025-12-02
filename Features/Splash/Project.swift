import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Splash,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)