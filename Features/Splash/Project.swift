import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Splash,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
