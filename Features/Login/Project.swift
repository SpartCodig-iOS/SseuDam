import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Login,
    dependencies: [
        .Features.Web,
        .Features.OnBoarding
    ],
    hasTests: true
)
