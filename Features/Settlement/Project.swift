import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Settlement,
    dependencies: [
        .Features.Expense,
        .Features.Travel,
        .SPM.TCACoordinators
    ],
    hasTests: true
)
