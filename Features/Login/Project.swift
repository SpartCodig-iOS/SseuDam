import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Login,
    dependencies: [
        .Domain,
        .DesignSystem
    ]
)