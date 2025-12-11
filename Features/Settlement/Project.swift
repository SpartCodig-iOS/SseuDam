import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Settlement,
    dependencies: [
        .Features.ExpenseList,
        .Features.SaveExpense,
        .Features.SettlementResult,
        .Features.SettlementDetail
    ],
    hasTests: true
)
