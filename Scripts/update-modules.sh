#!/bin/bash

# TargetDependency+Modules.swift 자동 업데이트 스크립트
# Features 디렉터리를 스캔해서 자동으로 모듈 의존성 정의 업데이트

echo "🔄 Updating TargetDependency+Modules.swift..."

MODULES_FILE="Tuist/Plugins/SseuDamPlugin/ProjectDescriptionHelpers/TargetDependency+Modules.swift"

# Features 디렉터리에서 모든 Feature 찾기
FEATURES=$(find Features -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)

# 파일 생성
cat > "$MODULES_FILE" << 'EOF'
import ProjectDescription

// MARK: - Module Dependencies Extension
public extension TargetDependency {
    enum Features {}
}

public extension TargetDependency {
    // MARK: - Core Modules
    static let Domain: TargetDependency = .project(target: "Domain", path: "../../Domain")
    static let Data: TargetDependency = .project(target: "Data", path: "../../Data")
    static let DesignSystem: TargetDependency = .project(target: "DesignSystem", path: "../../DesignSystem")
    static let NetworkService: TargetDependency = .project(target: "NetworkService", path: "../../NetworkService")
}

public extension TargetDependency.Features {
    // MARK: - Feature Modules
EOF

# Feature 모듈들 추가
for feature in $FEATURES; do
    echo "    static let ${feature}: TargetDependency = .project(target: \"${feature}Feature\", path: .relativeToRoot(\"Features/${feature}\"))" >> "$MODULES_FILE"
done

# FeatureName enum 시작
cat >> "$MODULES_FILE" << 'EOF'
}

// MARK: - Feature Names
public enum FeatureName: String {
EOF

# Feature enum cases 추가
for feature in $FEATURES; do
    echo "    case ${feature}" >> "$MODULES_FILE"
done

# 파일 종료
cat >> "$MODULES_FILE" << 'EOF'

    public var targetName: String {
        return "\(rawValue)Feature"
    }
}
EOF

echo "✅ TargetDependency+Modules.swift 업데이트 완료!"
echo ""
echo "등록된 Features:"
for feature in $FEATURES; do
    echo "  - $feature"
done
