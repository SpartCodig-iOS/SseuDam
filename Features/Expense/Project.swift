import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Expense,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
