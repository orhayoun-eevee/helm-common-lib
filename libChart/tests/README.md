# libChart Tests

Unit tests for libChart templates are run via **test-chart** (the consumer chart), because Helm library charts are not directly templateable.

## Running Tests

```bash
cd test-chart && helm dependency update && helm unittest .
```

Or from the project root:

```bash
helm dependency update test-chart
helm unittest test-chart
```

Test files live in **`test-chart/tests/`** (e.g. `test-chart/tests/deployment_test.yaml`).

## Adding Tests

1. **Add a new test case** in an existing file under `test-chart/tests/`:
   - Follow the existing patterns in `deployment_test.yaml`, `service_test.yaml`, etc.

2. **Add a new test file** for a new template:
   - Create `test-chart/tests/<resource>_test.yaml`.
   - Follow the helm-unittest format.
   - Run `helm unittest test-chart` to include it.
