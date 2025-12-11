# SseuDam Project Makefile

.PHONY: feature generate clean help

# Find Tuist path
TUIST_PATH := $(shell command -v tuist 2>/dev/null || find /usr/local/bin /opt/homebrew/bin ~/.local/share/mise/installs/tuist/*/bin -name tuist 2>/dev/null | head -1)

# Create a new feature module
feature:
	@echo "========================================="
	@echo "Feature 생성"
	@echo "========================================="
	@echo ""
	@echo "💡 팁:"
	@echo "  - 공백이나 하이픈을 사용하면 자동으로 카멜케이스로 변환됩니다"
	@echo "  - 예: 'settlement detail' → 'SettlementDetail'"
	@echo "  - 취소하려면 빈 값을 입력하거나 Ctrl+C를 누르세요"
	@echo ""
	@if [ -z "$(TUIST_PATH)" ]; then \
		echo "❌ Tuist를 찾을 수 없습니다."; \
		echo "다음 명령어로 설치해주세요:"; \
		echo "curl -Ls https://install.tuist.io | bash"; \
		exit 1; \
	fi
	@read -p "Feature 이름을 입력하세요: " input; \
	if [ -z "$$input" ]; then \
		echo ""; \
		echo "❌ 취소되었습니다."; \
		exit 0; \
	fi; \
	name=$$(echo "$$input" | sed -E 's/[-_[:space:]]+/ /g' | awk '{for(i=1;i<=NF;i++) $$i=toupper(substr($$i,1,1)) substr($$i,2)}1' | sed 's/ //g'); \
	if [ "$$input" != "$$name" ]; then \
		echo "✨ 자동 변환: '$$input' → '$$name'"; \
	fi; \
	if ! echo "$$name" | grep -qE '^[A-Za-z][A-Za-z0-9]*$$'; then \
		echo ""; \
		echo "❌ 잘못된 Feature 이름입니다: $$name"; \
		echo "   알파벳으로 시작하고 알파벳과 숫자만 사용할 수 있습니다."; \
		exit 1; \
	fi; \
	echo ""; \
	echo "📦 생성할 Feature: $$name"; \
	echo "   경로: Features/$$name/"; \
	echo ""; \
	read -p "계속하시겠습니까? (y/N): " confirm; \
	if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
		echo ""; \
		echo "❌ 취소되었습니다."; \
		exit 0; \
	fi; \
	echo ""; \
	echo "🚀 Feature를 생성하는 중..."; \
	echo ""; \
	$(TUIST_PATH) scaffold feature --name $$name && \
	./Scripts/update-modules.sh && \
	echo "" && \
	echo "=========================================" && \
	echo "✅ Feature '$$name'가 성공적으로 생성되었습니다!" && \
	echo "=========================================" && \
	echo "" && \
	echo "📂 생성된 파일:" && \
	echo "   - Features/$$name/Project.swift" && \
	echo "   - Features/$$name/Sources/$${name}View.swift" && \
	echo "   - Features/$$name/Tests/$${name}FeatureTests.swift" && \
	echo "   - Features/$$name/Demo/" && \
	echo "" && \
	echo "다음 단계:" && \
	echo "   1. make generate" && \
	echo "   2. Xcode에서 $$name 작업 시작" && \
	echo ""

# Generate Xcode project
generate:
	@echo "📦 Xcode 프로젝트를 생성합니다..."
	@if [ -z "$(TUIST_PATH)" ]; then \
		echo "❌ Tuist를 찾을 수 없습니다."; \
		echo "다음 명령어로 설치해주세요:"; \
		echo "curl -Ls https://install.tuist.io | bash"; \
		exit 1; \
	fi
	$(TUIST_PATH) generate

# Clean build artifacts
clean:
	@echo "🧹 정리 중..."
	@if [ -z "$(TUIST_PATH)" ]; then \
		echo "❌ Tuist를 찾을 수 없습니다."; \
		echo "다음 명령어로 설치해주세요:"; \
		echo "curl -Ls https://install.tuist.io | bash"; \
		exit 1; \
	fi
	$(TUIST_PATH) clean
	@echo "✅ 정리 완료!"

# Show help
help:
	@echo "사용 가능한 명령어:"
	@echo "  make feature   - 새 Feature 모듈 생성"
	@echo "  make generate  - Xcode 프로젝트 생성/업데이트"
	@echo "  make clean     - 빌드 아티팩트 정리"
	@echo "  make help      - 이 도움말 표시"