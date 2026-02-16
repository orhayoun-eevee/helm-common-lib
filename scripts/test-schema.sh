#!/bin/bash

# Schema validation test script
# Tests that invalid values files fail schema validation as expected

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FAIL_CASES_DIR="$PROJECT_ROOT/tests/schema-fail-cases"

pass_count=0
fail_count=0

echo "Testing schema validation with intentionally invalid values files..."
echo ""

# Test each file in the fail-cases directory
shopt -s nullglob
test_files=("$FAIL_CASES_DIR"/*.yaml)

if [ ${#test_files[@]} -eq 0 ]; then
    echo "No schema fail-case files found in: $FAIL_CASES_DIR"
    exit 1
fi

for test_file in "${test_files[@]}"; do
    test_name=$(basename "$test_file" .yaml)
    
    # Run helm lint and expect it to fail
    if helm lint "$PROJECT_ROOT/libChart" -f "$test_file" >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} $test_name - Expected validation to FAIL but it PASSED"
        fail_count=$((fail_count + 1))
    else
        echo -e "${GREEN}✓${NC} $test_name - Failed as expected"
        pass_count=$((pass_count + 1))
    fi
done

echo ""
echo "========================================="
echo "Schema validation tests complete"
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo "========================================="

if [ $fail_count -gt 0 ]; then
    exit 1
fi

exit 0
