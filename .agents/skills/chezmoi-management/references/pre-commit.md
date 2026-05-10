# Pre-commit Management (prek + secretlint)

All commits are validated through `prek` which executes `secretlint`, automatically rejecting any diffs that contain API keys or authentication tokens.

## Common False Positives

- Example SHA256/hex strings (may trigger if length matches AWS keys or GitHub tokens)
- Sample values in comments within `.envrc` files

## Resolution Strategies

```bash
# For legitimate false positives, add exclusions to .secretlintrc.json
# For valid detections, correct the content and commit with git add ... && git commit
```

Sample exclusion configuration in `.secretlintrc.json`:

```json
{
	"rules": [
		{
			"id": "@secretlint/secretlint-rule-preset-recommend",
			"options": {
				"allows": [
					"/sha256-[a-f0-9]{64}/",
					"fake-token-for-example",
					"skill-examples/*"
				]
			}
		}
	]
}
```

The `allows` field accepts both regular expressions (enclosed in `/.../`) and literal string matches. File-level exclusions can be configured using `disabledRules` combined with `includes`/`excludes`.

Never use `--no-verify` as it defeats the security purpose of the checks.