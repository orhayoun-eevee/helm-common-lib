.PHONY: help deps lint test validate golden-update ci bump pre-push

help: ## Show this help message
	@echo "Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

deps: ## Update Helm chart dependencies
	@echo "Updating appChart dependencies..."
	@helm dependency update appChart

lint: ## Run helm lint on both charts
	@echo "Linting libChart..."
	@helm lint libChart --strict
	@echo "Linting appChart..."
	@helm lint appChart

test: deps ## Run helm unittest on appChart
	@echo "Running unit tests..."
	@helm unittest appChart

validate: ## Run full validation (lint, kubeconform, golden check)
	@echo "Running validation script..."
	@./scripts/validate.sh

golden-update: ## Update golden snapshot file
	@echo "Updating golden snapshot..."
	@./scripts/validate.sh --update

ci: test validate ## Run full local CI suite (test + validate)
	@echo ""
	@echo "✓ All CI checks passed!"

bump: ## Bump chart version (requires VERSION=x.y.z)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Usage: make bump VERSION=x.y.z"; \
		exit 1; \
	fi
	@./scripts/bump-version.sh $(VERSION)

pre-push: ci ## Pre-push checks (runs ci and checks for uncommitted golden changes)
	@echo "Checking for uncommitted golden file changes..."
	@if ! git diff --exit-code tests/golden.yaml > /dev/null 2>&1; then \
		echo ""; \
		echo "❌ Error: Golden file has uncommitted changes!"; \
		echo ""; \
		echo "Review changes with: git diff tests/golden.yaml"; \
		echo ""; \
		echo "If the changes are expected:"; \
		echo "  1. Review the diff carefully"; \
		echo "  2. git add tests/golden.yaml"; \
		echo "  3. git commit"; \
		echo ""; \
		exit 1; \
	fi
	@echo ""
	@echo "✓ All pre-push checks passed! Safe to push."
