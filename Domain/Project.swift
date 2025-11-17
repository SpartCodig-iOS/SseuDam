import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
    name: "Domain",
    dependencies: [
      .SPM.GoogleSignIn,
      .SPM.Supabase,
    ],
    hasTests: true
)
