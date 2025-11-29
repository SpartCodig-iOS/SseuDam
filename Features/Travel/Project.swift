import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Travel,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    demoDependencies: [
        .Data,
        .NetworkService
    ],
    hasTests: true
)
