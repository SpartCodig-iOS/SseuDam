import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Travel,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    demoDependencies: [
        .Data,
        .NetworkService
    ],
    hasTests: true
)
