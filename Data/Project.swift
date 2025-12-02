import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
  name: "Data",
  dependencies: [
    .Domain,
    .NetworkService,
    .SPM.Supabase,
    .SPM.GoogleSignIn,
    .SPM.AppAuth
  ],
  hasTests: true,
)
