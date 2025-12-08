import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Main,
    dependencies: [
        .SPM.TCACoordinators,
        .Features.Settlement,
        .Features.Profile
    ],
    hasTests: true
)
