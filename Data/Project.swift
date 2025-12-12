import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
  name: "Data",
  dependencies: [
    .Domain,
    .NetworkService,
    .SPM.Supabase,
    .SPM.GoogleSignIn,
    .SPM.AppAuth,
//    .SPM.FirebaseAnalytics,
//    .SPM.FirebaseCrashlytics,
  ],
  hasTests: true,
  settings: .settings(
    base: SettingsDictionary()
//      .otherLinkerFlags(["-all_load", "-ObjC"]),
  )
)
