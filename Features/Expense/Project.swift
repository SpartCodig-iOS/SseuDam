import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Expense,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)