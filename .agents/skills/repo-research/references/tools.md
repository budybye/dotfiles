# Tools Reference — ghq + WebSearch

Commands, parameters, and troubleshooting for the primary tools used by `/repo-research`, plus fallback paths when they're unavailable.

---

## ghq — Local repository manager

### Install

```bash
# Cross-platform (recommended, matches user's environment)
mise use -g ghq@latest

# Homebrew (macOS)
brew install ghq

# Go toolchain
go install github.com/x-motemen/ghq@latest
```

Verify: `command -v ghq`.

### Commands

| Purpose                | Command                        |
| ---------------------- | ------------------------------ |
| Clone                  | `ghq get <repo>`               |
| Update in place        | `ghq get --update <repo>`      |
| Shallow clone          | `ghq get --shallow <repo>`     |
| Specific branch        | `ghq get --branch <name> <repo>` |
| SSH clone              | `ghq get -p <repo>`            |
| List repos (names)     | `ghq list`                     |
| List repos (paths)     | `ghq list -p`                  |
| Print root directory   | `ghq root`                     |

### Supported URL formats

```
github.com/owner/repo
https://github.com/owner/repo
git@github.com:owner/repo.git
```

### Config (`.gitconfig`)

```ini
[ghq]
    root = ~/ghq
    # Multiple roots are allowed — ghq picks based on the URL
    # root = ~/go/src
```

### Directory layout

```
$(ghq root)/<host>/<owner>/<repo>/
```

Example: `~/ghq/github.com/vercel/next.js/`.

### Troubleshooting

**`ghq: command not found`**

```bash
mise which ghq       # confirm mise manages it
mise reshim          # regenerate shims if needed
```

**`ghq root` is empty**

```bash
git config --global ghq.root     # inspect
git config --global ghq.root ~/ghq   # set
```

---

## WebSearch + WebFetch — Documentation lookup

```
WebSearch: <library> <topic> site:<official-domain>
WebFetch: <result-url>  → extract API shape manually
```

Prefer official docs domains (`hono.dev`, `docs.python.org`, etc.) over random blog posts.

Tips:

- Pin queries to one official domain at a time with `site:`
- Quote multi-word phrases for exact matches (`"staleTime"`)
- Add a version (`v18`, `4.x`) when the API has shifted recently

---

## Fallback — when ghq is unavailable

### No ghq → direct git clone

```bash
git clone --depth 1 <repo-url> /tmp/<repo-name>
# ...investigate via Grep / Read...
rm -rf /tmp/<repo-name>  # after writing the memo
```

The `--depth 1` keeps the clone small. Remove after the session to avoid disk creep.

### No WebSearch and no git clone

Ask the user to paste the relevant doc section or file contents directly. **Do not** hallucinate API shapes — empty answer is safer than wrong one.

---

## Common Scenarios

### S1 — Introducing a new library

Example: Zod for schema validation.

1. WebSearch → official docs page on schema definition / validation
2. Implement from retrieved samples
3. Source research unnecessary

### S2 — Investigating unexpected behavior

Example: TanStack Query cache timing.

1. WebSearch → `"staleTime" "cacheTime" site:tanstack.com`
2. If docs don't match observations: `ghq get github.com/TanStack/query`
3. Grep for `staleTime|cacheTime` in the repo, read 2–3 files

### S3 — Migrating between versions

Example: Next.js pages → app router.

1. WebSearch → migration guide on `nextjs.org`
2. `ghq get github.com/vercel/next.js` — read official examples under `examples/*/app/**`

### S4 — Custom plugin / extension development

1. WebSearch → plugin lifecycle docs
2. `ghq get <framework-repo>` + clone related plugins — copy proven patterns

### S5 — OSS contribution / bug fix

1. `ghq get <upstream-repo>` first
2. Grep error messages to locate code
3. WebSearch only for the project's CONTRIBUTING / style guide

---

## Advanced patterns

### Multi-repo comparison

```bash
ghq get github.com/remix-run/react-router
ghq get github.com/TanStack/router
ghq get github.com/molefrog/wouter

ROOT=$(ghq root)
# Compare routing-definition syntax across three repos:
for repo in remix-run/react-router TanStack/router molefrog/wouter; do
    echo "=== $repo ==="
    grep -rn "route definition" "$ROOT/github.com/$repo" | head -3
done
```

### Version-diff investigation

```bash
ghq get -p github.com/facebook/react
cd "$(ghq root)/github.com/facebook/react"
git tag | grep v18
git diff v18.0.0..v18.2.0 -- packages/react/
```

---

## Context window overflow — mitigation

If you see "context window exceeded":

1. Re-scope WebSearch to a narrower phrase (one specific API)
2. Use `Grep` output mode `files_with_matches` (just paths) before full-text grep
3. Read files in slices (`offset` + `limit`) rather than whole
4. Summarize findings into the memo immediately; don't hold raw docs in context
