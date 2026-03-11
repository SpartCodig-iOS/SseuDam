import ProjectDescription
import SseuDamPlugin

let project = Project.makeFramework(
  name: "Data",
  dependencies: [
    .Domain,
    .NetworkService,
    .SPM.Supabase,
    .SPM.GoogleSignIn,
    .SPM.FirebaseAnalytics,
    .SPM.FirebaseCrashlytics,
    .SPM.Mixpanel
  ],
  hasTests: true,
  settings: .settings(
    base: SettingsDictionary()
      .otherLinkerFlags(["-all_load -Objc"]),
  )
)
