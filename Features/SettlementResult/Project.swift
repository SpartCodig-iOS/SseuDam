import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .SettlementResult,
    dependencies: [
        .Features.SettlementDetail
    ],
    hasTests: true
)
