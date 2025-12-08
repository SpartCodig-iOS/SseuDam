import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Profile,
    dependencies: [
        .SPM.TCACoordinators,
        .Features.Web
    ],
    hasTests: true
)
