# SseuDam

Created by Peter1119 on 11-13-25.
Copyright © 2025 SpartaCoding. All rights reserved.

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

```bash
# 새 Feature 생성
make feature

# Xcode 프로젝트 생성
make generate

# 프로젝트 정리
make clean

# 도움말
make help
```

### 🎯 Feature 개발

각 Feature는 독립적인 데모앱을 포함하여 개발 및 테스트가 가능합니다.

```bash
# 새 Feature 생성 (예: Login)
make feature
# > Login 입력

# Xcode에서 LoginFeatureDemo 스킴 선택 후 실행
```

### 📝 템플릿 구조

- Framework: 실제 기능 구현
- Demo App: 독립 실행 가능한 데모 애플리케이션
- 자동 의존성 관리

## 🛠️ 요구사항

- Xcode 15.0+
- iOS 15.0+
- Tuist 4.0+

## 📄 라이선스

Copyright © 2025 SpartaCoding. All rights reserved.
