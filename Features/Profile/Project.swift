import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Profile,
    dependencies: [
        .Domain,
        .DesignSystem,
        .Features.Web
    ],
    hasTests: true
)
