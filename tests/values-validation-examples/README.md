# Validation error examples

These values files are **intended to fail** template or schema validation. They are used to:

- Manually verify that error messages are clear and actionable
- Document expected failure cases (e.g. in VALIDATION_SUMMARY.md, TEMPLATE_VALIDATION.md)
- Optionally add unit tests with `failedTemplate` asserts

**They are not run in CI.** Use them locally:

```bash
cd appChart
helm dependency update
# Expect exit code != 0 and an error mentioning the invalid field
helm template test . -f ../tests/values-validation-examples/empty-name.yaml
helm template test . -f ../tests/values-validation-examples/invalid-name-format.yaml
```

Validations are **fail-fast**: invalid values cause `helm template` to exit with an error. By default **schema** runs first (e.g. empty name); to see **template** validation only, use `--skip-schema-validation`.

| File | Intended failure |
|------|------------------|
| `empty-name.yaml` | Schema or template: `global.name is required` |
| `invalid-name-format.yaml` | Template: `global.name` must be DNS-1123 compliant (e.g. no uppercase) |

You can add more examples here (e.g. empty image repository, missing HTTPRoute gateway, invalid PVC size) and reference them in docs or unit tests.
