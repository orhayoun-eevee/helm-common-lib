.PHONY: help docker-build deps lint test test-schema test-aggregation validate snapshot-update snapshot-diff security bump check-validations ci pre-push

# ============================================================================
# Configuration
# ============================================================================
CHART_PATH       ?= ./test-chart
KUBERNETES_VERSION ?= 1.30.0
SCENARIOS_DIR    ?= tests/scenarios
SNAPSHOTS_DIR    ?= tests/snapshots

# Docker configuration
DOCKER_IMAGE     ?= helm-validate:local
BUILD_WORKFLOW   ?= ../build-workflow

# Resolve BUILD_WORKFLOW to absolute path for Docker mount
BW_ABS_PATH := $(shell cd $(BUILD_WORKFLOW) 2>/dev/null && pwd)

# Version check: disabled for local dev (CI sets to true)
RUN_VERSION_CHECK ?= false

# Docker run base command
# Mounts:
#   - Current chart repo  → /workspace
#   - build-workflow repo  → /opt/build-workflow (scripts + configs)
# Environment variables configure validation behavior
DOCKER_RUN = docker run --rm \
	-v $(shell pwd):/workspace \
	-v $(BW_ABS_PATH):/opt/build-workflow \
	-w /workspace \
	-e CHART_PATH=$(CHART_PATH) \
	-e KUBERNETES_VERSION=$(KUBERNETES_VERSION) \
	-e SCENARIOS_DIR=$(SCENARIOS_DIR) \
	-e SNAPSHOTS_DIR=$(SNAPSHOTS_DIR) \
	-e CONFIGS_DIR=/opt/build-workflow/configs \
	-e RUN_VERSION_CHECK=$(RUN_VERSION_CHECK) \
	$(DOCKER_IMAGE)

SCRIPTS = /opt/build-workflow/scripts

# ============================================================================
# Targets
# ============================================================================

help: ## Show this help message
	@echo "Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

docker-build: ## Build the validation Docker image locally
	@echo "Building validation Docker image ($(DOCKER_IMAGE))..."
	@docker build -t $(DOCKER_IMAGE) $(BW_ABS_PATH)/docker/

deps: ## Update Helm chart dependencies
	@echo "Updating test-chart dependencies..."
	@if ! $(DOCKER_RUN) -c "helm dependency update $(CHART_PATH)"; then \
		echo ""; \
		echo "Dependency update failed."; \
		echo "If your validation image is hosted in GHCR, authenticate Docker first:"; \
		echo "  echo <TOKEN> | docker login ghcr.io -u <USER> --password-stdin"; \
		exit 1; \
	fi

lint: ## Run syntax checks (yamllint + helm lint --strict)
	@$(DOCKER_RUN) $(SCRIPTS)/validate-syntax.sh

validate: ## Run full validation pipeline (all layers, sequential)
	@$(DOCKER_RUN) $(SCRIPTS)/validate-orchestrator.sh

test: deps ## Run helm-unittest on test-chart
	@echo "Running unit tests..."
	@$(DOCKER_RUN) -c "helm unittest $(CHART_PATH) --color"

test-schema: ## Run schema validation tests (fail-case tests)
	@echo "Running schema validation tests..."
	@$(DOCKER_RUN) -c "/workspace/scripts/test-schema.sh"

test-aggregation: ## Run template validation aggregation test
	@echo "Running validation aggregation test..."
	@$(DOCKER_RUN) -c "/workspace/scripts/test-validation-aggregation.sh"

check-validations: ## Verify all validation files are wired into orchestrator
	@file_count=$$(ls -1 libChart/templates/helpers/validations/_*.tpl 2>/dev/null | wc -l | tr -d ' '); \
	include_count=$$(grep -E '^[[:space:]]*"libChart\.validation\.[^"]+"' libChart/templates/helpers/_validations.tpl | wc -l | tr -d ' '); \
	if [ "$$file_count" != "$$include_count" ]; then \
		echo "Mismatch: $$file_count validation files but $$include_count includes in orchestrator"; \
		echo "   Check libChart/templates/helpers/_validations.tpl"; \
		exit 1; \
	fi; \
	echo "All $$file_count validation files are wired into orchestrator"

snapshot-update: deps ## Regenerate all scenario snapshots
	@echo "Updating snapshots for all scenarios..."
	@$(DOCKER_RUN) $(SCRIPTS)/update-snapshots.sh
	@echo ""
	@echo "Snapshots updated. Review changes with: make snapshot-diff"

snapshot-diff: ## Show snapshot differences
	@echo "Snapshot differences:"
	@git diff --stat $(SNAPSHOTS_DIR)/ || true
	@echo ""
	@git diff $(SNAPSHOTS_DIR)/ || true

security: ## Run security checks (checkov + kube-linter)
	@$(DOCKER_RUN) $(SCRIPTS)/validate-policy.sh

ci: test test-schema test-aggregation validate check-validations ## Run full local CI suite
	@echo ""
	@echo "All CI checks passed!"

bump: ## Bump version, refresh Chart.lock, and regenerate snapshots (requires VERSION=x.y.z)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Usage: make bump VERSION=x.y.z"; \
		exit 1; \
	fi
	@./scripts/bump-version.sh $(VERSION)

pre-push: ci ## Pre-push checks (runs ci and checks for uncommitted snapshot changes)
	@echo "Checking for uncommitted snapshot changes..."
	@if ! git diff --exit-code $(SNAPSHOTS_DIR)/ > /dev/null 2>&1; then \
		echo ""; \
		echo "Error: Snapshots have uncommitted changes!"; \
		echo ""; \
		echo "Review changes with: make snapshot-diff"; \
		echo ""; \
		echo "If the changes are expected:"; \
		echo "  1. Review the diff carefully"; \
		echo "  2. git add $(SNAPSHOTS_DIR)/"; \
		echo "  3. git commit"; \
		echo ""; \
		exit 1; \
	fi
	@echo ""
	@echo "All pre-push checks passed! Safe to push."
