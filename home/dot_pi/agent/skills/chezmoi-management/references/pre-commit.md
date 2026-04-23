# Pre-commit Management (prek + secretlint)

Commits are checked via `prek` which runs `secretlint`, rejecting diffs containing API keys or tokens.

## Common False Positives

- Example sha256 / hex strings (can be flagged if length matches aws key / github token)
- Sample values written in comments in `.envrc`

## Solutions

```bash
# If truly a false positive, exclude in .secretlintrc.json
# If detection is correct, fix the line and git add ... && git commit
```

Exclusion format in `.secretlintrc.json` (excerpt):

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

`allows` uses regular expressions (enclosed in `/.../`) or string matching. File-level exclusion is possible with `disabledRules` + `includes`/`excludes`.

Never use `--no-verify` (defeats the purpose).