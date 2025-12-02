import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Settlement,
    dependencies: [
        .Features.Expense
    ],
    hasTests: true
)
