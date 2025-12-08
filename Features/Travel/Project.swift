import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Travel,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    demoDependencies: [
        .Data
    ],
    hasTests: true
)
