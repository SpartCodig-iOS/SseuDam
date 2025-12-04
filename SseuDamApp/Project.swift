import ProjectDescription
import SseuDamPlugin

let project = Project.makeApp(
    name: "SseuDamApp",
    dependencies: [
        .Features.Login,
        .Features.Main,
        .Features.Splash,
        .Data
    ],
    infoPlist: .defaultSwiftUIApp,
    entitlements: .file(path: .relativeToManifest("../Entitlements/SseuDamApp.entitlements"))
)
