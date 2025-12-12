import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Member,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
