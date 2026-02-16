#!/bin/bash

# =============================================================================
# Version Bump Script for helm-common-lib
# =============================================================================
# This script updates the version in all Chart.yaml files atomically:
#   - libChart/Chart.yaml: version and appVersion
#   - test-chart/Chart.yaml: version, appVersion, and dependency version
#   - test-chart/Chart.lock: regenerated to stay in sync with Chart.yaml
#   - tests/snapshots/*.yaml: regenerated from tests/scenarios/*.yaml
#
# Usage: ./scripts/bump-version.sh <new-version>
# Example: ./scripts/bump-version.sh 0.0.7
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_CHART="$PROJECT_ROOT/libChart/Chart.yaml"
TEST_CHART="$PROJECT_ROOT/test-chart/Chart.yaml"
TEST_CHART_DIR="$PROJECT_ROOT/test-chart"
TEST_CHART_LOCK="$PROJECT_ROOT/test-chart/Chart.lock"
SCENARIOS_DIR="$PROJECT_ROOT/tests/scenarios"
SNAPSHOTS_DIR="$PROJECT_ROOT/tests/snapshots"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.30.0}"

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

# Check if version argument is provided
if [ $# -eq 0 ]; then
    error "Version argument is required"
    echo "Usage: $0 <version>"
    echo "Example: $0 0.0.7"
    exit 1
fi

NEW_VERSION="$1"

# Check required commands
if ! command -v helm >/dev/null 2>&1; then
    error "helm is required to refresh test-chart/Chart.lock"
    echo "Install Helm or run the bump from an environment that has Helm available."
    exit 1
fi

# Validate semver format (basic check)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.+-]+)?$ ]]; then
    error "Invalid version format: $NEW_VERSION"
    echo "Version must follow semantic versioning (e.g., 0.0.7, 1.2.3, 1.0.0-alpha.1)"
    exit 1
fi

# Get current version from libChart
CURRENT_VERSION=$(grep '^version:' "$LIB_CHART" | awk '{print $2}')

if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
    error "New version ($NEW_VERSION) is the same as current version ($CURRENT_VERSION)"
    echo "Please specify a different version"
    exit 1
fi

info "Bumping version from $CURRENT_VERSION to $NEW_VERSION"
echo ""

# Update libChart/Chart.yaml
info "Updating $LIB_CHART..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$LIB_CHART"
    sed -i '' "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$LIB_CHART"
else
    sed -i "s/^version: .*/version: $NEW_VERSION/" "$LIB_CHART"
    sed -i "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$LIB_CHART"
fi

# Update test-chart/Chart.yaml
info "Updating $TEST_CHART..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$TEST_CHART"
    sed -i '' "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$TEST_CHART"
    sed -i '' "s/^\(    version: \).*/\1$NEW_VERSION/" "$TEST_CHART"
else
    sed -i "s/^version: .*/version: $NEW_VERSION/" "$TEST_CHART"
    sed -i "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$TEST_CHART"
    sed -i "s/^\(    version: \).*/\1$NEW_VERSION/" "$TEST_CHART"
fi

# Refresh lock file and vendored dependency so CI dependency build stays in sync
info "Refreshing dependency lockfile in ${TEST_CHART_DIR}..."
helm dependency update "${TEST_CHART_DIR}" --skip-refresh >/dev/null

# Regenerate snapshots so expected manifests match the new chart version metadata
info "Regenerating snapshots from ${SCENARIOS_DIR} (kube-version=${KUBERNETES_VERSION})..."
mkdir -p "${SNAPSHOTS_DIR}"
shopt -s nullglob
SCENARIO_FILES=("${SCENARIOS_DIR}"/*.yaml "${SCENARIOS_DIR}"/*.yml)
if [ "${#SCENARIO_FILES[@]}" -eq 0 ]; then
    error "No scenario files found in ${SCENARIOS_DIR}"
    exit 1
fi
for scenario in "${SCENARIO_FILES[@]}"; do
    scenario_name=$(basename "${scenario}" .yaml)
    scenario_name=$(basename "${scenario_name}" .yml)
    info "Updating snapshot: ${scenario_name}"
    helm template test-release "${TEST_CHART_DIR}" \
        --values "${scenario}" \
        --kube-version "${KUBERNETES_VERSION}" \
        > "${SNAPSHOTS_DIR}/${scenario_name}.yaml"
done

# Verify changes
echo ""
info "Verifying changes..."

LIB_NEW_VERSION=$(grep '^version:' "$LIB_CHART" | awk '{print $2}')
LIB_NEW_APP_VERSION=$(grep '^appVersion:' "$LIB_CHART" | awk '{print $2}' | tr -d '"')
TEST_NEW_VERSION=$(grep '^version:' "$TEST_CHART" | awk '{print $2}')
TEST_NEW_APP_VERSION=$(grep '^appVersion:' "$TEST_CHART" | awk '{print $2}' | tr -d '"')
TEST_DEP_VERSION=$(grep -A 3 'dependencies:' "$TEST_CHART" | grep 'version:' | awk '{print $2}')
LOCK_DEP_VERSION=$(grep '^  version:' "$TEST_CHART_LOCK" | awk '{print $2}')

if [ "$LIB_NEW_VERSION" != "$NEW_VERSION" ] || \
   [ "$LIB_NEW_APP_VERSION" != "$NEW_VERSION" ] || \
   [ "$TEST_NEW_VERSION" != "$NEW_VERSION" ] || \
   [ "$TEST_NEW_APP_VERSION" != "$NEW_VERSION" ] || \
   [ "$TEST_DEP_VERSION" != "$NEW_VERSION" ] || \
   [ "$LOCK_DEP_VERSION" != "$NEW_VERSION" ]; then
    error "Version mismatch after update!"
    echo "libChart version: $LIB_NEW_VERSION"
    echo "libChart appVersion: $LIB_NEW_APP_VERSION"
    echo "test-chart version: $TEST_NEW_VERSION"
    echo "test-chart appVersion: $TEST_NEW_APP_VERSION"
    echo "test-chart dependency version: $TEST_DEP_VERSION"
    echo "test-chart lockfile dependency version: $LOCK_DEP_VERSION"
    exit 1
fi

info "Successfully bumped version to $NEW_VERSION"
echo ""
echo "Changes made:"
echo "  - libChart/Chart.yaml: version=$NEW_VERSION, appVersion=\"$NEW_VERSION\""
echo "  - test-chart/Chart.yaml: version=$NEW_VERSION, appVersion=\"$NEW_VERSION\", dependencies[0].version=$NEW_VERSION"
echo "  - test-chart/Chart.lock: dependencies[0].version=$NEW_VERSION (regenerated)"
echo "  - tests/snapshots/*.yaml: regenerated from scenarios"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Commit: git add . && git commit -m 'chore: bump version to $NEW_VERSION'"
echo "  3. Push: git push"
echo "  4. Tag: git tag v$NEW_VERSION && git push origin v$NEW_VERSION"
