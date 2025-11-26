import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
  name: "Data",
  dependencies: [
    .project(target: "Domain", path: "../Domain"),
    .project(target: "NetworkService", path: "../NetworkService"),
    .SPM.Supabase,
    .SPM.GoogleSignIn,
    .SPM.LogMacro,
    .SPM.ComposableArchitecture
  ],
  hasTests: true,
  settings: .settings(
    base: SettingsDictionary()
      .otherLinkerFlags(["-ObjC", "-all_load"])
  )

)
