import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .SaveExpense,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
