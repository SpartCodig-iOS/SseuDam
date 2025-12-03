# 🧳 SseuDam (쓰담쓰담)

> 여행 경비 관리와 정산을 쉽게! 함께하는 여행을 더 스마트하게 관리하는 iOS 앱

<div align="center">

[![iOS](https://img.shields.io/badge/iOS-17.0+-black?logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?logo=swift&logoColor=white)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-16.0+-1575F9?logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)
[![Tuist](https://img.shields.io/badge/Tuist-4.0+-6B73FF?logo=tuist&logoColor=white)](https://tuist.io/)
[![TCA](https://img.shields.io/badge/TCA-1.0+-FF6B6B)](https://github.com/pointfreeco/swift-composable-architecture)

</div>

## 📱 주요 기능

### 🌍 여행 관리
- **여행 생성 및 관리**: 여행 일정과 참가자 관리
- **초대 코드**: 친구들을 쉽게 여행에 초대
- **실시간 환율**: 최신 환율 정보로 정확한 경비 계산

### 💰 경비 관리 & 정산
- **실시간 경비 입력**: 여행 중 발생하는 모든 경비 기록
- **자동 정산 계산**: 복잡한 N분의 1 정산을 자동으로 계산
- **정산 내역 공유**: 투명한 정산 결과 공유

### 🔐 간편 인증
- **소셜 로그인**: Google, Apple 로그인 지원
- **안전한 인증**: OAuth 2.0 기반 보안 시스템

### 🎨 사용자 경험
- **Skeleton Loading**: 부드러운 로딩 경험
- **Toast 알림**: 직관적인 피드백 시스템
- **다크 모드**: 시스템 설정에 따른 테마 자동 변경

## 🏗️ 아키텍처

### 모듈러 아키텍처
**Clean Architecture + TCA (The Composable Architecture)** 기반의 확장 가능한 모듈러 구조

```
SseuDam/
├── 🎯 Features/          # 기능별 모듈
│   ├── Login/           # 로그인 & 회원가입
│   ├── Travel/          # 여행 관리
│   ├── Expense/         # 경비 관리
│   ├── Settlement/      # 정산
│   ├── Profile/         # 프로필
│   ├── Web/             # WebView 기능
│   ├── Main/            # 메인 탭
│   └── Splash/          # 스플래시
│
├── 🏛️ Core Layers/
│   ├── Domain/          # 비즈니스 로직 & 엔터티
│   ├── Data/            # Repository 구현 & DTO
│   ├── NetworkService/  # API 통신
│   └── DesignSystem/    # UI 컴포넌트 & 디자인 시스템
│
└── 📱 App/
    └── SseuDamApp/      # 메인 애플리케이션
```

### 기술 스택

#### 🏗️ 아키텍처 & 패턴
- **[TCA (The Composable Architecture)](https://github.com/pointfreeco/swift-composable-architecture)**: 단방향 데이터 플로우
- **[TCACoordinators](https://github.com/johnpatrickmorgan/TCACoordinators)**: 네비게이션 관리
- **Clean Architecture**: 계층 분리 및 의존성 역전
- **[Tuist](https://tuist.io/)**: 프로젝트 생성 및 모듈 관리

#### 🌐 네트워킹
- **[Supabase](https://supabase.com/)**: Backend as a Service
- **[Moya](https://github.com/Moya/Moya)**: 타입 세이프한 네트워킹
- **[Alamofire](https://github.com/Alamofire/Alamofire)**: HTTP 네트워킹

#### 🔐 인증
- **[Google Sign-In](https://developers.google.com/identity/sign-in/ios)**: Google OAuth
- **[AppAuth-iOS](https://github.com/openid/AppAuth-iOS)**: OAuth 2.0 / OpenID Connect

#### 🎨 UI/UX
- **SwiftUI**: 선언적 UI 프레임워크
- **Skeleton Loading**: 로딩 상태 UX
- **Toast System**: 사용자 피드백

#### 🛠️ 개발 도구
- **[FastLane](https://fastlane.tools/)**: 배포 자동화
- **Xcode 16.0+**: iOS 개발 환경

## 🚀 시작하기

### 필수 요구사항

- **Xcode 16.0+**
- **iOS 17.0+**
- **Tuist 4.0+**
- **Ruby 3.0+** (FastLane용)

### 설치 및 설정

#### 1. 저장소 클론
```bash
git clone https://github.com/SpartCodig-iOS/SseuDam.git
cd SseuDam
```

#### 2. Tuist 설치 (macOS)
```bash
# Homebrew 사용 (권장)
brew install tuist

# 또는 공식 설치 스크립트
curl -Ls https://install.tuist.io | bash
```

#### 3. 프로젝트 생성
```bash
# Xcode 프로젝트 생성
make generate

# 또는 직접 실행
tuist generate
```

#### 4. Xcode에서 프로젝트 열기
```bash
open SseuDam.xcworkspace
```

### 🎯 개발 시작하기

#### 새로운 Feature 모듈 생성
```bash
# 인터랙티브 Feature 생성
make feature
# > 예: Dashboard 입력 → DashboardFeature 모듈 생성

# 프로젝트 업데이트
make generate
```

#### 개별 Feature 개발 및 테스트
각 Feature는 독립적인 Demo 앱을 포함하여 개별 개발 및 테스트가 가능합니다.

```bash
# Xcode에서 {FeatureName}Demo 스킴 선택 후 실행
# 예: TravelFeatureDemo, LoginFeatureDemo 등
```

## 📦 빌드 및 배포

### 로컬 빌드
```bash
# Debug 빌드
tuist build

# Release 빌드
tuist build -c release
```

### FastLane을 통한 배포
```bash
# QA 빌드 (TestFlight)
fastlane QA
```

## 🛠️ 개발 가이드

### 📝 컨벤션

#### 코딩 컨벤션
- **Swift Style Guide**: [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) 준수
- **접근 제어자**: `private`, `fileprivate`, `internal`, `public` 적극 활용
- **final 키워드**: 상속이 불필요한 클래스에 `final` 사용


## 🛠️ 요구사항

- Xcode 16.0+
- iOS 17.0+
- Tuist 4.0+

## 📄 라이선스

Copyright © 2025 SpartaCoding. All rights reserved.