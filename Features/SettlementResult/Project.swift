import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Settlementresult,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)