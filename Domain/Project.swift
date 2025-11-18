import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "Domain",
    dependencies: [
      .SPM.ComposableArchitecture,
      .SPM.GoogleSignIn,
      .SPM.Supabase,
      .SPM.LogMacro
    ],
    hasTests: true
)
