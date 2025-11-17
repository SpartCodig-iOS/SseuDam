import ProjectDescription
import SseuDamPlugin

let project = Project.makeFeature(
    name: .Login,
    dependencies: [
        .SPM.ComposableArchitecture,
        .SPM.TCACoordinators,
        .SPM.Supabase,
        .SPM.GoogleSignIn,
        .Domain,
        .Data,
        .DesignSystem
    ],
    hasTests: true
)
