import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Settlement,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)