import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .OnBoarding,
    dependencies: [
        .Domain,
        .DesignSystem
    ],
    hasTests: true
)
