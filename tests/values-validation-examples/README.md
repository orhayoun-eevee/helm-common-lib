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

By default, **schema** validation runs first (e.g. empty name or invalid pattern). To see **template** validation messages instead, use `--skip-schema-validation`: e.g. `helm template test appChart -f ../tests/values-validation-examples/empty-name.yaml --skip-schema-validation`.

| File | Intended failure |
|------|------------------|
| `empty-name.yaml` | Template validation: `global.name` is required and cannot be empty |
| `invalid-name-format.yaml` | Template validation: `global.name` must be DNS-1123 (e.g. no uppercase) |

You can add more examples here (e.g. empty image repository, missing HTTPRoute gateway, invalid PVC size) and reference them in docs or unit tests.
