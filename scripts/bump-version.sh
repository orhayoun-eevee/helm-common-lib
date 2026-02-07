#!/bin/bash

# =============================================================================
# Version Bump Script for helm-common-lib
# =============================================================================
# This script updates the version in all Chart.yaml files atomically:
#   - libChart/Chart.yaml: version and appVersion
#   - appChart/Chart.yaml: version, appVersion, and dependency version
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
APP_CHART="$PROJECT_ROOT/appChart/Chart.yaml"

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
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$LIB_CHART"
    sed -i '' "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$LIB_CHART"
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION/" "$LIB_CHART"
    sed -i "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$LIB_CHART"
fi

# Update appChart/Chart.yaml
info "Updating $APP_CHART..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$APP_CHART"
    sed -i '' "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$APP_CHART"
    sed -i '' "s/^\(    version: \).*/\1$NEW_VERSION/" "$APP_CHART"
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION/" "$APP_CHART"
    sed -i "s/^appVersion: .*/appVersion: \"$NEW_VERSION\"/" "$APP_CHART"
    sed -i "s/^\(    version: \).*/\1$NEW_VERSION/" "$APP_CHART"
fi

# Verify changes
echo ""
info "Verifying changes..."

LIB_NEW_VERSION=$(grep '^version:' "$LIB_CHART" | awk '{print $2}')
LIB_NEW_APP_VERSION=$(grep '^appVersion:' "$LIB_CHART" | awk '{print $2}' | tr -d '"')
APP_NEW_VERSION=$(grep '^version:' "$APP_CHART" | awk '{print $2}')
APP_NEW_APP_VERSION=$(grep '^appVersion:' "$APP_CHART" | awk '{print $2}' | tr -d '"')
APP_DEP_VERSION=$(grep -A 3 'dependencies:' "$APP_CHART" | grep 'version:' | awk '{print $2}')

if [ "$LIB_NEW_VERSION" != "$NEW_VERSION" ] || \
   [ "$LIB_NEW_APP_VERSION" != "$NEW_VERSION" ] || \
   [ "$APP_NEW_VERSION" != "$NEW_VERSION" ] || \
   [ "$APP_NEW_APP_VERSION" != "$NEW_VERSION" ] || \
   [ "$APP_DEP_VERSION" != "$NEW_VERSION" ]; then
    error "Version mismatch after update!"
    echo "libChart version: $LIB_NEW_VERSION"
    echo "libChart appVersion: $LIB_NEW_APP_VERSION"
    echo "appChart version: $APP_NEW_VERSION"
    echo "appChart appVersion: $APP_NEW_APP_VERSION"
    echo "appChart dependency version: $APP_DEP_VERSION"
    exit 1
fi

info "✓ Successfully bumped version to $NEW_VERSION"
echo ""
echo "Changes made:"
echo "  - libChart/Chart.yaml: version=$NEW_VERSION, appVersion=\"$NEW_VERSION\""
echo "  - appChart/Chart.yaml: version=$NEW_VERSION, appVersion=\"$NEW_VERSION\", dependencies[0].version=$NEW_VERSION"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Commit: git add . && git commit -m 'chore: bump version to $NEW_VERSION'"
echo "  3. Push: git push"
echo "  4. Tag: git tag v$NEW_VERSION && git push origin v$NEW_VERSION"
