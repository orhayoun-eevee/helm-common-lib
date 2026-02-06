#!/bin/bash

# =============================================================================
# Helm Chart Comprehensive Validation Script
# =============================================================================
# This is a "super-script" that runs all validation checks in sequence:
#   1. helm lint --strict (with subcharts)
#   2. Template generation test (via appChart)
#   3. Golden snapshot comparison (via validate.sh)
#   4. Optional: JSON Schema validation (if ajv is installed)
#
# Use this for local development to catch issues before CI.
# For just golden snapshot testing, use ./scripts/validate.sh directly.
# =============================================================================

set -euo pipefail

# Colors for output (match validate.sh)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_MANIFEST=$(mktemp)
trap 'rm -f "$TEMP_MANIFEST"' EXIT

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd "$PROJECT_ROOT"

# 1. Helm lint
info "Running helm lint..."
helm lint libChart --strict --with-subcharts

# 2. Template generation test (use appChart; library charts are not installable)
info "Testing template generation..."
cd "$PROJECT_ROOT/appChart"
helm dependency update > /dev/null 2>&1 || { error "Failed to update appChart dependencies"; exit 1; }
helm template test-release . -f "$PROJECT_ROOT/tests/values.test.yaml" > "$TEMP_MANIFEST" || { error "Template generation failed"; exit 1; }
info "Template generation successful"

# 3. Golden comparison (validate.sh lints both charts, templates, kubeconform, golden diff)
info "Comparing against golden file..."
cd "$PROJECT_ROOT"
./scripts/validate.sh
if ! git diff --exit-code tests/golden.yaml > /dev/null 2>&1; then
  error "Golden file has uncommitted changes. Review with 'git diff tests/golden.yaml' or run 'scripts/validate.sh --update' and commit."
  exit 1
fi

# 4. Optional schema check with ajv
if command -v ajv &> /dev/null; then
  info "Validating JSON Schema..."
  ajv validate -s libChart/values.schema.json -d libChart/values.yaml || { error "Schema validation failed"; exit 1; }
else
  warn "Skipping schema validation (ajv not installed)"
fi

info "All validations passed!"
