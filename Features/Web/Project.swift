import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Web,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
