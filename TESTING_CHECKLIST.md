# Testing Guide for Uncommitted Changes

This document provides a testing checklist to validate all uncommitted changes before committing.

## Changes Summary

### Modified Files (5)
1. ✅ `README.md` - Consolidated testing section
2. ✅ `appChart/values.yaml` - Changed placeholder to "CHANGEME"
3. ✅ `libChart/templates/classes/_configmap.tpl` - Reverted YAML separator
4. ✅ `libChart/templates/lib/_entrypoint.tpl` - Added deprecation warnings and validations
5. ✅ `libChart/templates/lib/_groups.tpl` - Added ConfigMap support

### New Files (~25)
- Validation system (helpers/validation/, lib/*-validations.tpl)
- Unit tests (appChart/tests/*.yaml)
- Documentation (docs/*.md)
- Scripts (scripts/lint.sh)
- ConfigMap support (lib/workload/_configmap-lib.tpl)

### Critical Changes
- ⚠️ **Validation system** - Now runs on all template renders (WARNING-ONLY mode)
- ⚠️ **Deprecation warnings** - Will emit warnings for deprecated configurations
- ⚠️ **ConfigMap support** - New feature added to workload group

## Testing Checklist

### Phase 1: Local Validation (helm-common-lib)

Run from the `helm-common-lib` directory:

#### 1.1 Update Dependencies
```bash
cd /Users/ohayoun/personal/eevee/helm-common-lib
helm dependency update appChart
```

Expected: Should complete without errors.

#### 1.2 Run Unit Tests
```bash
helm unittest appChart
```

Expected: All tests should pass. Look for:
- ✅ All test suites pass
- ✅ No template rendering errors
- ✅ Validation warnings appear in test output (if any)

#### 1.3 Run Helm Lint
```bash
helm lint libChart --strict
helm lint appChart --strict
```

Expected: 
- ✅ No errors
- ⚠️ Warnings acceptable (e.g., missing icon)

#### 1.4 Run Validation Script
```bash
./scripts/validate.sh
```

Expected:
- ✅ Lint passes
- ✅ Template generation succeeds
- ✅ Kubeconform validation passes
- ✅ Golden file matches (no diff)

#### 1.5 Run Comprehensive Lint
```bash
./scripts/lint.sh
```

Expected: All checks pass (helm lint + template + validate.sh + optional ajv)

#### 1.6 Test Chart-Testing (if installed)
```bash
ct lint --config ct.yaml --all
```

Expected: Both libChart and appChart lint successfully.

### Phase 2: Application Chart Testing

Test each application chart to ensure backward compatibility.

#### 2.1 Radarr-helm

```bash
cd /Users/ohayoun/personal/eevee/radarr-helm

# Template with current values
helm template radarr . -f values.yaml > /tmp/radarr-output.yaml

# Check for validation warnings
grep -A 20 "VALIDATION WARNINGS" /tmp/radarr-output.yaml || echo "No validation warnings"

# Check for deprecation warnings
grep -A 10 "DEPRECATION WARNINGS" /tmp/radarr-output.yaml || echo "No deprecation warnings"

# Verify all expected resources are present
grep "^kind:" /tmp/radarr-output.yaml | sort | uniq -c
```

**Expected Resources:**
- ServiceAccount
- Deployment
- Service (likely 2: main + metrics)
- PVC (config, media-data, media-downloads)
- HTTPRoute
- NetworkPolicy
- ServiceMonitor
- PrometheusRule

**Success Criteria:**
- ✅ No unexpected validation errors
- ✅ All resources render correctly
- ✅ No missing resources compared to before
- ⚠️ Warnings are acceptable (they're non-blocking)

#### 2.2 Sonarr-helm

```bash
cd /Users/ohayoun/personal/eevee/sonarr-helm
helm template sonarr . -f values.yaml > /tmp/sonarr-output.yaml

# Same checks as radarr
grep -A 20 "VALIDATION WARNINGS" /tmp/sonarr-output.yaml || echo "No validation warnings"
grep -A 10 "DEPRECATION WARNINGS" /tmp/sonarr-output.yaml || echo "No deprecation warnings"
grep "^kind:" /tmp/sonarr-output.yaml | sort | uniq -c
```

**Success Criteria:** Same as radarr

#### 2.3 Sabnzbd-helm

```bash
cd /Users/ohayoun/personal/eevee/sabnzbd-helm
helm template sabnzbd . -f values.yaml > /tmp/sabnzbd-output.yaml

grep -A 20 "VALIDATION WARNINGS" /tmp/sabnzbd-output.yaml || echo "No validation warnings"
grep -A 10 "DEPRECATION WARNINGS" /tmp/sabnzbd-output.yaml || echo "No deprecation warnings"
grep "^kind:" /tmp/sabnzbd-output.yaml | sort | uniq -c
```

**Success Criteria:** Same as radarr

#### 2.4 Transmission-helm

```bash
cd /Users/ohayoun/personal/eevee/transmission-helm
helm template transmission . -f values.yaml > /tmp/transmission-output.yaml

grep -A 20 "VALIDATION WARNINGS" /tmp/transmission-output.yaml || echo "No validation warnings"
grep -A 10 "DEPRECATION WARNINGS" /tmp/transmission-output.yaml || echo "No deprecation warnings"
grep "^kind:" /tmp/transmission-output.yaml | sort | uniq -c
```

**Success Criteria:** Same as radarr

### Phase 3: Validation Testing

Test that validations work correctly (warnings appear for invalid configs).

#### 3.1 Test Empty Name Validation
```bash
cd /Users/ohayoun/personal/eevee/helm-common-lib/appChart
helm template test . -f ../tests/values-validation-examples/empty-name.yaml > /tmp/empty-name-test.yaml

# Should see validation warnings
grep "global.name is required" /tmp/empty-name-test.yaml
```

Expected: Validation warning appears in output.

#### 3.2 Test Invalid Name Format
```bash
helm template test . -f ../tests/values-validation-examples/invalid-name-format.yaml > /tmp/invalid-name-test.yaml

# Should see validation warnings
grep "Must be DNS-1123 compliant" /tmp/invalid-name-test.yaml
```

Expected: Validation warning appears in output.

### Phase 4: ConfigMap Testing

Test the new ConfigMap feature.

#### 4.1 Create Test Values with ConfigMap
```bash
cd /Users/ohayoun/personal/eevee/helm-common-lib
cat > /tmp/test-configmap-values.yaml << 'EOF'
global:
  name: "test-app"
  namespace: "default"

deployment:
  containers:
    main:
      enabled: true
      image:
        repository: nginx
        tag: "1.25"

configMap:
  items:
    app-config:
      data:
        config.yaml: |
          setting: value
        database.url: "postgres://localhost"
    env-config:
      data:
        ENV: "production"
EOF

# Template with ConfigMaps
cd appChart
helm template test . -f /tmp/test-configmap-values.yaml > /tmp/configmap-test.yaml

# Verify ConfigMaps are rendered
grep "kind: ConfigMap" /tmp/configmap-test.yaml
grep "test-app-app-config" /tmp/configmap-test.yaml
grep "test-app-env-config" /tmp/configmap-test.yaml
```

Expected:
- ✅ 2 ConfigMap resources appear
- ✅ Names are correct: `test-app-app-config`, `test-app-env-config`
- ✅ Data sections contain the specified keys

### Phase 5: Breaking Change Analysis

Compare outputs before and after changes (optional but recommended).

```bash
# For each application chart:
cd /Users/ohayoun/personal/eevee/<chart-name>

# Stash changes temporarily
cd /Users/ohayoun/personal/eevee/helm-common-lib
git stash

# Template with OLD version
cd /Users/ohayoun/personal/eevee/<chart-name>
helm dependency update
helm template test . -f values.yaml > /tmp/<chart>-before.yaml

# Restore changes
cd /Users/ohayoun/personal/eevee/helm-common-lib
git stash pop

# Template with NEW version
cd /Users/ohayoun/personal/eevee/<chart-name>
helm dependency update
helm template test . -f values.yaml > /tmp/<chart>-after.yaml

# Compare (ignore comment lines which contain warnings)
diff -u <(grep -v "^#" /tmp/<chart>-before.yaml) <(grep -v "^#" /tmp/<chart>-after.yaml)
```

Expected:
- ✅ Minimal or no differences (except added warning comments)
- ⚠️ Any differences should be intentional (e.g., ConfigMap addition)

## Test Results Template

Copy this template and fill in results:

```
# Test Results for helm-common-lib Changes
Date: YYYY-MM-DD
Tester: [Your Name]

## Phase 1: Local Validation
- [ ] Dependencies updated successfully
- [ ] Unit tests: ___ passed, ___ failed
- [ ] Helm lint (libChart): PASS / FAIL
- [ ] Helm lint (appChart): PASS / FAIL
- [ ] validate.sh: PASS / FAIL
- [ ] lint.sh: PASS / FAIL
- [ ] Chart-testing: PASS / FAIL / SKIPPED

## Phase 2: Application Charts
- [ ] radarr-helm: PASS / FAIL (warnings: Y/N)
- [ ] sonarr-helm: PASS / FAIL (warnings: Y/N)
- [ ] sabnzbd-helm: PASS / FAIL (warnings: Y/N)
- [ ] transmission-helm: PASS / FAIL (warnings: Y/N)

## Phase 3: Validation Testing
- [ ] Empty name validation: WORKS / BROKEN
- [ ] Invalid format validation: WORKS / BROKEN

## Phase 4: ConfigMap Testing
- [ ] ConfigMaps render: YES / NO
- [ ] ConfigMap names correct: YES / NO
- [ ] ConfigMap data correct: YES / NO

## Phase 5: Breaking Changes
- [ ] radarr-helm diff: CLEAN / CHANGES DETECTED
- [ ] sonarr-helm diff: CLEAN / CHANGES DETECTED
- [ ] sabnzbd-helm diff: CLEAN / CHANGES DETECTED
- [ ] transmission-helm diff: CLEAN / CHANGES DETECTED

## Issues Found
[List any issues, with reproduction steps]

## Notes
[Any additional observations or recommendations]

## Decision
- [ ] READY TO COMMIT - All tests passed
- [ ] NEEDS FIXES - Issues found (see above)
- [ ] NEEDS DISCUSSION - Unclear results
```

## What to Do With Results

### If All Tests Pass ✅
1. Review the modified and new files one more time
2. Plan commit strategy (single commit vs multiple)
3. Write clear commit message(s)
4. Commit changes
5. Consider creating PR if this is a shared repo

### If Tests Fail ❌
1. Document the failure in detail
2. Analyze which change caused the failure
3. Fix the issue or revert problematic changes
4. Re-run affected tests
5. Repeat until all tests pass

### If Warnings Appear ⚠️
1. Verify warnings are expected (validation/deprecation system)
2. Check if warnings indicate real issues in application charts
3. Fix issues in application charts if needed
4. Document warnings for future reference
5. Warnings alone don't block commits (warning-only mode)

## Quick Test Command

For a rapid sanity check, run:

```bash
cd /Users/ohayoun/personal/eevee/helm-common-lib
helm dependency update appChart && \
helm unittest appChart && \
./scripts/validate.sh && \
cd /Users/ohayoun/personal/eevee/radarr-helm && \
helm template radarr . -f values.yaml > /dev/null && \
echo "✅ Quick test PASSED"
```

This tests:
1. Dependency resolution
2. Unit tests
3. Golden snapshot
4. At least one application chart templates successfully

## Troubleshooting

### "Chart.lock is out of date"
```bash
cd appChart
rm Chart.lock
helm dependency update
```

### "Template rendering failed"
- Check the error message carefully
- Run `helm lint` to catch syntax errors
- Check validation warnings for clues
- Review recent changes to templates

### "Golden file mismatch"
- Run `./scripts/validate.sh --update` to accept new output
- Review diff with `git diff tests/golden.yaml`
- Ensure changes are intentional
- Commit updated golden file

### "Unit tests fail"
- Check test file syntax
- Verify documentIndex is correct
- Update snapshots if needed: `helm unittest appChart --update-snapshot`
- Review assertion expectations

## CI/CD Considerations

Before pushing changes, ensure:
- [ ] All tests pass locally
- [ ] Golden file is up to date
- [ ] Unit tests include new features
- [ ] Documentation is updated
- [ ] CHANGELOG notes any breaking changes (even if warning-only)

## Contact

If you encounter issues or unclear test results, document them and seek clarification before committing.
