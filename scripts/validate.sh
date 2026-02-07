#!/bin/bash

# Helm Chart Validation and Drift Detection Script
# This script validates Helm charts using linting, schema validation, and golden snapshot testing

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$PROJECT_ROOT/tests"
GOLDEN_FILE="$TESTS_DIR/golden.yaml"
TEST_VALUES="$TESTS_DIR/values.test.yaml"
TEMP_MANIFEST=$(mktemp)

# Cleanup function
cleanup() {
    rm -f "$TEMP_MANIFEST"
}
trap cleanup EXIT

# Check if update flag is set
UPDATE_GOLDEN=false
if [[ "${1:-}" == "--update" ]]; then
    UPDATE_GOLDEN=true
fi

# Function to print colored output
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    if ! command -v helm &> /dev/null; then
        error "helm is not installed"
        exit 1
    fi
    
    if ! command -v kubeconform &> /dev/null; then
        error "kubeconform is not installed"
        exit 1
    fi
    
    if ! command -v diff &> /dev/null; then
        error "diff is not installed"
        exit 1
    fi
    
    info "All prerequisites met"
}

# Lint Helm charts
lint_charts() {
    info "Linting Helm charts..."
    
    # Lint library chart
    info "Linting libChart..."
    if ! helm lint "$PROJECT_ROOT/libChart"; then
        error "libChart linting failed"
        exit 1
    fi
    
    # Update dependencies for appChart
    info "Updating appChart dependencies..."
    cd "$PROJECT_ROOT/appChart"
    helm dependency update > /dev/null 2>&1 || {
        error "Failed to update appChart dependencies"
        exit 1
    }
    
    # Lint application chart
    info "Linting appChart..."
    if ! helm lint "$PROJECT_ROOT/appChart"; then
        error "appChart linting failed"
        exit 1
    fi
    
    info "All charts passed linting"
}

# Generate manifests and validate with kubeconform
generate_and_validate() {
    info "Generating manifests from test values..."
    
    if [[ ! -f "$TEST_VALUES" ]]; then
        error "Test values file not found: $TEST_VALUES"
        exit 1
    fi
    
    # Generate manifests using helm template
    cd "$PROJECT_ROOT/appChart"
    if ! helm template test-release . -f "$TEST_VALUES" > "$TEMP_MANIFEST" 2>&1; then
        error "Failed to generate manifests"
        cat "$TEMP_MANIFEST"
        exit 1
    fi
    
    info "Validating manifests with kubeconform..."
    
    # Validate with kubeconform
    # Using strict mode and skipping CRDs that might not have schemas
    if ! kubeconform -strict -skip ServiceMonitor,PrometheusRule,HTTPRoute,AuthorizationPolicy,DestinationRule "$TEMP_MANIFEST"; then
        error "kubeconform validation failed"
        exit 1
    fi
    
    info "All manifests passed kubeconform validation"
}

# Compare against golden snapshot
check_drift() {
    info "Checking for drift against golden snapshot..."
    
    if [[ ! -f "$GOLDEN_FILE" ]]; then
        if [[ "$UPDATE_GOLDEN" == "true" ]]; then
            info "Golden file not found. Creating initial golden snapshot..."
            mkdir -p "$TESTS_DIR"
            cp "$TEMP_MANIFEST" "$GOLDEN_FILE"
            info "Golden snapshot created at $GOLDEN_FILE"
            return 0
        else
            error "Golden file not found: $GOLDEN_FILE"
            error "Run with --update flag to create initial golden snapshot"
            exit 1
        fi
    fi
    
    # Normalize both files for comparison (remove timestamps, sort, etc.)
    # Using diff to compare
    if diff -u "$GOLDEN_FILE" "$TEMP_MANIFEST" > /dev/null 2>&1; then
        info "No drift detected - manifests match golden snapshot"
        return 0
    else
        error "Drift detected! Generated manifests differ from golden snapshot"
        echo ""
        echo "Diff (golden vs current):"
        diff -u "$GOLDEN_FILE" "$TEMP_MANIFEST" || true
        echo ""
        
        if [[ "$UPDATE_GOLDEN" == "true" ]]; then
            warn "Updating golden snapshot as requested..."
            cp "$TEMP_MANIFEST" "$GOLDEN_FILE"
            info "Golden snapshot updated at $GOLDEN_FILE"
            warn "Please review the changes and commit the updated golden file"
            return 0
        else
            error "To update the golden snapshot, run: $0 --update"
            exit 1
        fi
    fi
}

# Main execution
main() {
    info "Starting Helm chart validation..."
    echo ""
    
    check_prerequisites
    echo ""
    
    lint_charts
    echo ""
    
    generate_and_validate
    echo ""
    
    check_drift
    echo ""
    
    # Optional JSON Schema validation
    validate_schema
    echo ""
    
    info "Validation complete - all checks passed!"
}

# Optional JSON Schema validation
validate_schema() {
    if command -v ajv &> /dev/null; then
        info "Validating JSON Schema with ajv..."
        cd "$PROJECT_ROOT"
        if ajv validate -s libChart/values.schema.json -d libChart/values.yaml; then
            info "JSON Schema validation passed"
        else
            error "JSON Schema validation failed"
            exit 1
        fi
    else
        warn "Skipping JSON Schema validation (ajv not installed)"
    fi
}

main

