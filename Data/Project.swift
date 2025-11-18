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
  settings: .settings(
    base: SettingsDictionary()
      .setOtherLdFlags("-ObjC -all_load")
  )
)
