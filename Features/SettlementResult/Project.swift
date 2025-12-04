import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .SettlementResult,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
