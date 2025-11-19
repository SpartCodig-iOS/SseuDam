import ProjectDescription
import SseuDamPlugin

let project = Project.makeApp(
    name: "SseuDamApp",
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .Features.Login,
        .Data
    ],
    infoPlist: .defaultSwiftUIApp,
    entitlements: .file(path: .relativeToManifest("../Entitlements/SseuDamApp.entitlements"))
)
