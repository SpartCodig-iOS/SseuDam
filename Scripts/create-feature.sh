#!/bin/bash

# Feature 생성 스크립트
# 사용법: ./Scripts/create-feature.sh FeatureName

if [ $# -eq 0 ]; then
    echo "사용법: $0 <FeatureName>"
    echo "예시: $0 Login"
    exit 1
fi

FEATURE_NAME="$1"
FEATURE_DIR="Feature/$FEATURE_NAME"
BUNDLE_ID_BASE="com.modular.$(echo $FEATURE_NAME | tr '[:upper:]' '[:lower:]')"

echo "🚀 Creating Feature: $FEATURE_NAME"

# 디렉터리 생성
mkdir -p "$FEATURE_DIR/Sources"
mkdir -p "$FEATURE_DIR/Demo/Sources"
mkdir -p "$FEATURE_DIR/Demo/Resources"

# Project.swift 파일 생성
cat > "$FEATURE_DIR/Project.swift" << EOF
import ProjectDescription

let project = Project(
    name: "${FEATURE_NAME}Feature",
    targets: [
        .target(
            name: "${FEATURE_NAME}Feature",
            destinations: .iOS,
            product: .framework,
            bundleId: "${BUNDLE_ID_BASE}feature",
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Domain", path: "../../Domain"),
                .project(target: "DesignSystem", path: "../../DesignSystem")
            ]
        ),
        .target(
            name: "${FEATURE_NAME}FeatureDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "${BUNDLE_ID_BASE}feature.demo",
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "\$(PRODUCT_MODULE_NAME).SceneDelegate"
                            ]
                        ]
                    ]
                ]
            ]),
            sources: ["Demo/Sources/**"],
            resources: ["Demo/Resources/**"],
            dependencies: [
                .target(name: "${FEATURE_NAME}Feature")
            ]
        )
    ]
)
EOF

# 빈 Feature 파일 생성
cat > "$FEATURE_DIR/Sources/${FEATURE_NAME}ViewController.swift" << EOF
import UIKit
import DesignSystem

public class ${FEATURE_NAME}ViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "${FEATURE_NAME}"
        
        let label = UILabel()
        label.text = "${FEATURE_NAME} Feature"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
EOF

# AppDelegate 생성
cat > "$FEATURE_DIR/Demo/Sources/AppDelegate.swift" << EOF
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
EOF

# SceneDelegate 생성
cat > "$FEATURE_DIR/Demo/Sources/SceneDelegate.swift" << EOF
import UIKit
import ${FEATURE_NAME}Feature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let rootViewController = ${FEATURE_NAME}ViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
EOF

# LaunchScreen.storyboard 생성
cat > "$FEATURE_DIR/Demo/Resources/LaunchScreen.storyboard" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="32700.99.1234" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <device id="retina6_1" orientation="portrait" appearance="light"/>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="22685"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="414" height="896"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Demo" textAlignment="center" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="GJd-Yh-RWb">
                                <rect key="frame" x="183.5" y="437.5" width="47" height="21"/>
                                <fontDescription key="fontDescription" type="system" pointSize="17"/>
                                <nil key="textColor"/>
                                <nil key="highlightedColor"/>
                            </label>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="Bcu-3y-fUS"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                        <constraints>
                            <constraint firstItem="GJd-Yh-RWb" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="Q3B-4B-g5h"/>
                            <constraint firstItem="GJd-Yh-RWb" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="akx-eg-2+P"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <systemColor name="systemBackgroundColor">
            <color white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
        </systemColor>
    </resources>
</document>
EOF

echo "✅ Feature '$FEATURE_NAME' 생성 완료!"
echo ""
echo "다음 단계:"
echo "1. Workspace.swift에 'Feature/$FEATURE_NAME' 추가"
echo "2. 메인 앱에서 필요시 '$FEATURE_NAME}Feature' 의존성 추가"
echo "3. tuist generate 실행"
echo ""
echo "데모앱 실행: ${FEATURE_NAME}FeatureDemo 스킴 선택 후 실행"
EOF