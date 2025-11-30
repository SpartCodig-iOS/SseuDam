import ProjectDescription
import SseuDamPlugin

let project = Project.makeApp(
    name: "SseuDamApp",
    dependencies: [
        .Features.Login,
        .Features.Main,
        .Data
    ],
    infoPlist: .defaultSwiftUIApp,
    entitlements: .file(path: .relativeToManifest("../Entitlements/SseuDamApp.entitlements"))
)
