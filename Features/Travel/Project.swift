import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Travel,
    dependencies: [
        .Domain,
        .DesignSystem,
        .Features.Profile
    ],
    demoDependencies: [
        .Data,
        .NetworkService
    ],
    hasTests: true
)
