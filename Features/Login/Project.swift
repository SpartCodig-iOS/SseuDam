import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Login,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ]
)