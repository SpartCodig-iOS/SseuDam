import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Main,
    dependencies: [
        .SPM.TCACoordinators,
        .Features.Travel,
        .Features.Settlement
    ],
    hasTests: true
)
