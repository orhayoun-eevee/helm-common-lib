# Library chart tests

Unit tests for libChart templates are run via the **appChart** (the consumer chart), because Helm library charts are not directly templateable.

## Run unit tests

```bash
cd appChart && helm dependency update && helm unittest .
```

Or from the repository root:

```bash
helm dependency update appChart
helm unittest appChart
```

Test files that assert on library behavior live in **`appChart/tests/`** (e.g. `appChart/tests/deployment_test.yaml`).

## How to extend

1. **Add a new test case** in an existing file under `appChart/tests/`:
   - Add an entry under `tests:` with `it: <description>`, `set:` (values overrides), and `asserts:` (e.g. `equal`, `documentIndex`).
   - Use [helm-unittest assertions](https://github.com/helm-unittest/helm-unittest/blob/master/docs/assertions.md) such as `equal`, `matchSnapshot`, or `failedTemplate` for validation failures.

2. **Add a new test file** (e.g. for Service or HTTPRoute):
   - Create `appChart/tests/<resource>_test.yaml`.
   - Set `suite:`, `templates: [templates/all.yaml]`, and a list of `tests:`.
   - Run `helm unittest appChart` to include it.

3. **Test that validation fails** when values are invalid:
   - In a test, use `set:` with invalid data (e.g. `global.name: ""`) and add an assert:
     ```yaml
     asserts:
       - failedTemplate:
           errorMessage: "global.name"
     ```

For the full testing guide (all test types, CI, golden snapshot, validation examples), see **[docs/TESTING.md](../docs/TESTING.md)**.
