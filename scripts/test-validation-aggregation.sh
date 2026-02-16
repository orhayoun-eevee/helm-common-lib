#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CMD=(
  helm template test-release "$PROJECT_ROOT/test-chart"
  -f "$PROJECT_ROOT/test-chart/tests/fixtures/valid-base.yaml"
  -f "$PROJECT_ROOT/test-chart/tests/fixtures/no-enabled-containers.yaml"
  --set podDisruptionBudget.enabled=true
  --set podDisruptionBudget.minAvailable=1
  --set podDisruptionBudget.maxUnavailable=1
)

set +e
OUTPUT="$("${CMD[@]}" 2>&1)"
STATUS=$?
set -e

if [ "$STATUS" -eq 0 ]; then
  echo "Expected helm template to fail, but it succeeded"
  exit 1
fi

echo "$OUTPUT" | grep -F "deployment.containers must have at least one enabled container" >/dev/null || {
  echo "Missing aggregated deployment validation error"
  exit 1
}

echo "$OUTPUT" | grep -F "podDisruptionBudget.minAvailable and maxUnavailable are mutually exclusive (set only one)" >/dev/null || {
  echo "Missing aggregated PDB validation error"
  exit 1
}

echo "Validation aggregation test passed"
