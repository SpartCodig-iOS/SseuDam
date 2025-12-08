import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .ExpenseList,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)