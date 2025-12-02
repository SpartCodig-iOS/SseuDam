import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Profile,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
