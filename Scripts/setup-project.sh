#!/bin/bash

# 프로젝트 초기 설정 스크립트
# 사용법: ./Scripts/setup-project.sh

echo "🚀 ModularAppTemplate 프로젝트 설정을 시작합니다!"
echo ""

# 사용자 정보 수집
read -p "📝 프로젝트 이름을 입력하세요: " PROJECT_NAME
read -p "👤 개발자 이름을 입력하세요: " FULL_USERNAME
read -p "🏢 회사/조직명을 입력하세요 (개인이면 엔터): " ORGANIZATION_NAME
read -p "🌐 Bundle ID 접두사를 입력하세요: " BUNDLE_ID_PREFIX

# 기본값 설정
PROJECT_NAME=${PROJECT_NAME:-"MyAwesomeApp"}
FULL_USERNAME=${FULL_USERNAME:-"Developer"}

# 조직명이 비어있으면 개발자 이름 사용
if [ -z "$ORGANIZATION_NAME" ]; then
    ORGANIZATION_NAME="$FULL_USERNAME"
fi

BUNDLE_ID_PREFIX=${BUNDLE_ID_PREFIX:-"com.mycompany"}

# 현재 날짜 및 연도 설정
CURRENT_DATE=$(date +"%m-%d-%y")
CURRENT_YEAR=$(date +"%Y")

echo ""
echo "📋 설정 정보:"
echo "  프로젝트명: $PROJECT_NAME"
echo "  개발자: $FULL_USERNAME"
echo "  조직: $ORGANIZATION_NAME"
echo "  Bundle ID 접두사: $BUNDLE_ID_PREFIX"
echo "  생성일: $CURRENT_DATE"
echo ""

read -p "✅ 이 정보로 프로젝트를 설정하시겠습니까? (y/N): " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ 설정이 취소되었습니다."
    exit 1
fi

echo ""
echo "🔧 프로젝트를 설정 중..."

# 프로젝트 디렉터리 생성
echo "📁 프로젝트 디렉터리 생성 중: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"

# Tuist 관련 파일들 복사
echo "📋 Tuist 설정 복사 중..."
cp -r Tuist "$PROJECT_NAME/"
cp -r Scripts "$PROJECT_NAME/"

# 프로젝트용 Makefile 생성
echo "📋 Makefile 생성 중..."
sed "s/{{ name }}/$PROJECT_NAME/g" Tuist/Templates/project-makefile.stencil > "$PROJECT_NAME/Makefile"

# 설정 파일 생성
cat > "$PROJECT_NAME/.project-config" << EOF
PROJECT_NAME="$PROJECT_NAME"
FULL_USERNAME="$FULL_USERNAME"
ORGANIZATION_NAME="$ORGANIZATION_NAME"
BUNDLE_ID_PREFIX="$BUNDLE_ID_PREFIX"
CURRENT_DATE="$CURRENT_DATE"
CURRENT_YEAR="$CURRENT_YEAR"
EOF

# 템플릿 파일들에서 플레이스홀더 치환하는 함수
replace_placeholders() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        sed -i.bak \
            -e "s|___PROJECTNAME___|$PROJECT_NAME|g" \
            -e "s|___FULLUSERNAME___|$FULL_USERNAME|g" \
            -e "s|___ORGANIZATIONNAME___|$ORGANIZATION_NAME|g" \
            -e "s|___DATE___|$CURRENT_DATE|g" \
            -e "s|___YEAR___|$CURRENT_YEAR|g" \
            -e "s|com\.modular|$BUNDLE_ID_PREFIX|g" \
            "$file"
        rm "$file.bak" 2>/dev/null
    fi
}

# 모든 Swift 파일과 템플릿 파일 업데이트
echo "📝 파일들을 업데이트 중..."

# 기존 프로젝트 파일들 업데이트
find "$PROJECT_NAME" -name "*.swift" -not -path "./$PROJECT_NAME/Scripts/*" | while read file; do
    replace_placeholders "$file"
done

# 템플릿 파일들 업데이트
find "$PROJECT_NAME/Tuist/Templates" -name "*.stencil" | while read file; do
    replace_placeholders "$file"
done

find "$PROJECT_NAME/Tuist/Templates" -name "*.swift" | while read file; do
    replace_placeholders "$file"
done

# Workspace 이름 변경 (파일이 있는 경우에만)
if [ -f "$PROJECT_NAME/Workspace.swift" ]; then
    sed -i.bak "s/ModularAppTemplate/$PROJECT_NAME/g" "$PROJECT_NAME/Workspace.swift"
    rm "$PROJECT_NAME/Workspace.swift.bak" 2>/dev/null
fi

# App 프로젝트 이름 변경 (파일이 있는 경우에만)
if [ -f "$PROJECT_NAME/${PROJECT_NAME}App/Project.swift" ]; then
    sed -i.bak \
        -e "s/SampleApp/${PROJECT_NAME}App/g" \
        -e "s/com\.modular\.sampleapp/$BUNDLE_ID_PREFIX.$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]')/g" \
        "$PROJECT_NAME/${PROJECT_NAME}App/Project.swift"
    rm "$PROJECT_NAME/${PROJECT_NAME}App/Project.swift.bak" 2>/dev/null
elif [ -f "$PROJECT_NAME/App/Project.swift" ]; then
    sed -i.bak \
        -e "s/SampleApp/${PROJECT_NAME}App/g" \
        -e "s/com\.modular\.sampleapp/$BUNDLE_ID_PREFIX.$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]')/g" \
        "$PROJECT_NAME/App/Project.swift"
    rm "$PROJECT_NAME/App/Project.swift.bak" 2>/dev/null
fi


# README 생성
cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

Created by $FULL_USERNAME on $CURRENT_DATE.
Copyright © $CURRENT_YEAR $ORGANIZATION_NAME. All rights reserved.

## 🏗️ 모듈러 아키텍처

이 프로젝트는 Tuist를 사용한 모듈러 iOS 아키텍처 템플릿입니다.

### 📁 모듈 구조

- **App**: 메인 애플리케이션
- **Domain**: 비즈니스 로직 및 엔터티
- **Data**: 데이터 레이어 (Repository 구현)
- **NetworkService**: 네트워크 통신
- **DesignSystem**: UI 컴포넌트 및 디자인 시스템
- **Feature**: 각 기능별 모듈들

### 🚀 시작하기

\`\`\`bash
# 새 Feature 생성
make feature

# Xcode 프로젝트 생성
make generate

# 프로젝트 정리
make clean

# 도움말
make help
\`\`\`

### 🎯 Feature 개발

각 Feature는 독립적인 데모앱을 포함하여 개발 및 테스트가 가능합니다.

\`\`\`bash
# 새 Feature 생성 (예: Login)
make feature
# > Login 입력

# Xcode에서 LoginFeatureDemo 스킴 선택 후 실행
\`\`\`

### 📝 템플릿 구조

- Framework: 실제 기능 구현
- Demo App: 독립 실행 가능한 데모 애플리케이션
- 자동 의존성 관리

## 🛠️ 요구사항

- Xcode 15.0+
- iOS 15.0+
- Tuist 4.0+

## 📄 라이선스

Copyright © $CURRENT_YEAR $ORGANIZATION_NAME. All rights reserved.
EOF

echo ""
echo "✅ 프로젝트 설정이 완료되었습니다!"
echo ""
echo "📋 완료된 작업:"
echo "  ✓ 프로젝트명: $PROJECT_NAME"
echo "  ✓ 개발자 정보 설정"
echo "  ✓ Bundle ID 설정: $BUNDLE_ID_PREFIX"
echo "  ✓ 생성일 및 저작권 정보 설정"
echo "  ✓ README.md 생성"
echo ""
echo "🚀 다음 단계:"
echo "  1. make generate    # Xcode 프로젝트 생성"
echo "  2. make feature     # 새 Feature 생성"
echo ""
# 기본 모듈 구조 생성
echo ""
echo "🏗️ 기본 모듈 구조를 생성 중..."

# 프로젝트 폴더로 이동
cd "$PROJECT_NAME"

# Tuist 경로 찾기 (Makefile과 동일한 로직 사용)
TUIST_PATH=$(command -v tuist 2>/dev/null || find /usr/local/bin /opt/homebrew/bin ~/.local/share/mise/installs/tuist/*/bin -name tuist 2>/dev/null | head -1)

if [ -n "$TUIST_PATH" ]; then
    echo "✅ Tuist 발견: $TUIST_PATH"
    
    # Tuist 버전 확인 및 .mise.toml 생성
    echo "🔍 Tuist 버전 확인 중..."
    TUIST_VERSION=$($TUIST_PATH version 2>/dev/null)
    if [ -n "$TUIST_VERSION" ]; then
        echo "📋 .mise.toml 파일 생성 중... (Tuist $TUIST_VERSION)"
        cat > .mise.toml << MISE_EOF
[tools]
tuist = "$TUIST_VERSION"
MISE_EOF
        echo "✅ .mise.toml 생성 완료!"
    fi
else
    echo "⚠️ Tuist를 찾을 수 없습니다."
    echo ""
    echo "🔍 다음 위치들을 확인했지만 Tuist를 찾을 수 없습니다:"
    echo "  - PATH에서: $(command -v tuist 2>/dev/null || echo "없음")"
    echo "  - /usr/local/bin/"
    echo "  - /opt/homebrew/bin/"
    echo "  - ~/.local/share/mise/installs/tuist/*/bin/"
    echo ""
    echo "📥 Tuist 설치 방법:"
    echo "  curl -Ls https://install.tuist.io | bash"
    echo "  또는"
    echo "  mise install tuist"
    echo "  또는"
    echo "  brew install tuist"
    echo ""
fi

if [ -n "$TUIST_PATH" ]; then
    # 기본 모듈들 생성
    echo "📱 App 모듈 생성 중..."
    if ! $TUIST_PATH scaffold app --name "${PROJECT_NAME}App"; then
        echo "  ❌ App 모듈 생성 실패!"
        echo "  🔍 가능한 원인:"
        echo "    - Tuist 버전 호환성 문제"
        echo "    - 템플릿 파일 손상"
        echo "    - 권한 문제"
        echo "  💡 해결 방법: 'tuist scaffold app --help'로 도움말 확인"
        echo ""
    fi
    
    # App 폴더를 프로젝트명App으로 변경
    if [ -d "App" ]; then
        mv App "${PROJECT_NAME}App"
        echo "📁 App 폴더가 '${PROJECT_NAME}App'으로 변경되었습니다."
    fi
    
    echo "🏛️ Domain 모듈 생성 중..."
    $TUIST_PATH scaffold domain || echo "  ⚠️ Domain 모듈 생성 실패"
    
    echo "📊 Data 모듈 생성 중..."
    $TUIST_PATH scaffold data || echo "  ⚠️ Data 모듈 생성 실패"
    
    echo "🌐 NetworkService 모듈 생성 중..."
    $TUIST_PATH scaffold network || echo "  ⚠️ NetworkService 모듈 생성 실패"
    
    echo "🎨 DesignSystem 모듈 생성 중..."
    $TUIST_PATH scaffold designsystem || echo "  ⚠️ DesignSystem 모듈 생성 실패"
    
    # Feature 폴더 생성
    echo "📁 Feature 폴더 생성 중..."
    mkdir -p Feature
    
    # Workspace.swift 생성
    echo "📁 Workspace.swift 생성 중..."
    cat > Workspace.swift << WORKSPACE_EOF
import ProjectDescription

let workspace = Workspace(
    name: "$PROJECT_NAME",
    projects: [
        "${PROJECT_NAME}App",
        "Domain",
        "DesignSystem",
        "Data",
        "NetworkService"
    ]
)
WORKSPACE_EOF

    echo "✅ 기본 모듈 구조 생성 완료!"
    echo ""
    echo "📋 생성된 모듈들을 확인하세요:"
    echo "  $(ls -la | grep '^d' | grep -v '^\.$\|^\.\.$' | wc -l | tr -d ' ') 개의 모듈 디렉터리가 생성되었습니다"
else
    echo "⚠️ Tuist 없이 기본 설정만 완료되었습니다."
    echo ""
    echo "📁 최소 구조만 생성합니다..."
    mkdir -p Feature
    
    echo "⚠️ 완전한 프로젝트 설정을 위해서는:"
    echo "  1. Tuist를 설치하세요"
    echo "  2. 다시 'make project'를 실행하거나"
    echo "  3. 수동으로 'tuist scaffold [module-name]' 명령어를 사용하세요"
    echo ""
fi

# Git 초기화
echo ""
echo "🔄 Git 저장소 초기화 중..."
git init
git add .
git commit -m "Initial commit: $PROJECT_NAME 프로젝트 생성

🏗️ 모듈러 아키텍처 템플릿으로 생성된 프로젝트
- 프로젝트명: $PROJECT_NAME
- 개발자: $FULL_USERNAME
- 조직: $ORGANIZATION_NAME

🤖 Generated with ModularAppTemplate
"

echo ""
echo "🎉 프로젝트 생성 완료!"
echo ""
echo "📁 프로젝트 위치: $(pwd)"
echo ""
echo "🚀 다음 단계:"
echo "  1. cd $PROJECT_NAME    # 프로젝트 폴더로 이동 (이미 이동됨)"
echo "  2. make generate       # Xcode 프로젝트 생성"
echo "  3. make feature        # 새 Feature 생성"
echo ""
echo "🎉 Happy coding!"