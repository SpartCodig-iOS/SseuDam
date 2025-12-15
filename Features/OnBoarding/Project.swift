import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .OnBoarding,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)