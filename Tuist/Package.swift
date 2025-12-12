// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework,
        "TCACoordinators": .framework,
        "Moya": .framework,
        "LogMacro": .framework,
//        "FirebaseCore": .staticLibrary,
//        "FirebaseAuth": .staticLibrary,
//        "FirebaseFirestore": .staticLibrary,
//        "FirebaseAnalytics": .staticLibrary,
//        "FirebaseCrashlytics": .staticLibrary,
//        "FirebaseRemoteConfig": .staticLibrary
    ]
)
#endif

let package = Package(
    name: "SseuDam",
    dependencies: [
        // MARK: - Architecture
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.18.0"),
        .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", exact: "0.11.1"),
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.37.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "9.0.0"),
        .package(url: "https://github.com/Roy-wonji/LogMacro.git", from: "1.1.1"),
        .package(url: "https://github.com/Moya/Moya.git", exact: "15.0.3"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "12.7.0")
    ]
)
