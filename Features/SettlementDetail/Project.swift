import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .SettlementDetail,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
