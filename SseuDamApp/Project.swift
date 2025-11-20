import ProjectDescription
import SseuDamPlugin

let project = Project.makeApp(
    name: "SseuDamApp",
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .SPM.Swinject,
        .Features.Login
    ],
    infoPlist: .defaultSwiftUIApp
)
