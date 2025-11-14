import ProjectDescription
import SseuDamPlugin

let project = Project.makeApp(
    name: "SseuDamApp",
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Features.Login
    ],
    infoPlist: .defaultSwiftUIApp
)