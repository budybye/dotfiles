# Reference: ghq + Context7

## ghq Command Details

### Installation

```bash
# via mise (Recommended)
mise use -g ghq@latest

# via Homebrew
brew install ghq

# via Go
go install github.com/x-motemen/ghq@latest
```

### Basic Commands

| Command          | Description               | Example                        |
| ---------------- | ------------------------- | ------------------------------ |
| `ghq get <repo>` | Clone a repository        | `ghq get github.com/user/repo` |
| `ghq list`       | List local repositories   | `ghq list`                     |
| `ghq list -p`    | List with full paths      | `ghq list -p`                  |
| `ghq root`       | Show ghq root directory   | `ghq root`                     |
| `ghq root --all` | Show all root directories | `ghq root --all`               |

### `ghq get` Advanced Options

```bash
# Basic format
ghq get <repository-url>

# Protocol and update
ghq get -p <repo>              # Clone via SSH
ghq get --update <repo>        # Update if it exists
ghq get --shallow <repo>       # Shallow clone
ghq get --branch <name> <repo> # Clone specific branch
ghq get --bare <repo>          # Clone as bare repository
```

### Supported URL Formats

```bash
ghq get https://github.com/owner/repo
ghq get github.com/owner/repo
ghq get git@github.com:owner/repo.git
```

### Configuration (`.gitconfig`)

```ini
[ghq]
  # Root directories
  root = ~/ghq
  root = ~/go/src  # Multiple roots supported

  # VCS specification
  [ghq "https://gitlab.com/"]
    vcs = git
```

### Directory Structure Detail

```text
<ghq.root>/
└── <host>/
    └── <user>/
        └── <repo>/
            └── (Repository Content)

Example:
~/ghq/
├── github.com/
│   ├── facebook/
│   │   └── react/
│   └── vercel/
│       └── next.js/
└── gitlab.com/
    └── group/
        └── project/
```

## Context7 MCP Tool Specifications

### Tool 1: `resolve-library-id`

**Purpose**: Resolves a library name into a Context7 library ID.

**Parameters**:

```json
{
	"query": "string (required)"
}
```

**Tips for Queries**:

- Name + Description: "Next.js React framework"
- Specific Use Case: "Prisma ORM for database"
- Prefer Official Names: "TanStack Query" (formerly "React Query")

**Return Value**:

```json
{
	"library_id": "nextjs",
	"name": "Next.js",
	"confidence": 0.95
}
```

**Best Practices**: Use official names, avoid abbreviations, and add context if the name is ambiguous.

### Tool 2: `query-docs`

**Purpose**: Retrieves documentation for specific topics.

**Parameters**:

```json
{
	"library_id": "string (required)",
	"topic": "string (required)",
	"tokens": "number (optional, default: 4000)"
}
```

**Topic Writing**:

- **Good**: "middleware authentication redirect"
- **Bad**: "how to use" (too vague)

**Recommended Token Values**:

| Use Case          | tokens    | Description                 |
| ----------------- | --------- | --------------------------- |
| Quick Reference   | 1000-1500 | API specs only              |
| Standard Research | 2000-3000 | Explanations + Code samples |
| Detailed Research | 4000-6000 | Comprehensive documentation |

**Return Value**:

```json
{
	"content": "Markdown formatted documentation",
	"token_count": 2847,
	"sources": ["https://..."]
}
```

### Tool 3: `search-for-libraries`

**Purpose**: Search for library candidates (can be used before `resolve-library-id`).

**Parameters**:

```json
{
	"query": "string (required)",
	"limit": "number (optional, default: 10)"
}
```

**Example**:
`query: "React state management"` → Returns candidates like Redux, Zustand, Jotai.

## Common Research Scenarios

### Scenario 1: Introducing a New Library

**Context**: Want to introduce Zod to a project.

1.  **Context7**: Resolve "Zod TypeScript schema validation".
2.  **Context7**: Query "schema definition validation" (3000 tokens).
3.  Implement based on retrieved code samples.
    **Decision**: Docs are sufficient → `ghq` not needed.

### Scenario 2: Bug Investigation

**Context**: React Query cache behavior is unexpected.

1.  **Context7**: Resolve "TanStack Query" and query "cache behavior staleTime cacheTime" (2500 tokens).
2.  If docs are insufficient: `ghq get github.com/TanStack/query`.
3.  Grep for `staleTime|cacheTime` and read relevant files to understand internal logic.
    **Decision**: Docs first → Source code as backup.

### Scenario 3: Refactoring Existing Code

**Context**: Migrating Next.js Pages Router to App Router.

1.  **Context7**: Query "app router migration from pages" (4000 tokens).
2.  If implementation patterns are needed: `ghq get github.com/vercel/next.js`.
3.  Explore official examples with Glob patterns like `examples/*/app/**`.
    **Decision**: Docs for guidelines + Source for examples.

### Scenario 4: Custom Plugin Development

**Context**: Developing a Vite custom plugin.

1.  **Context7**: Query "plugin api hooks lifecycle" (3000 tokens).
2.  **ghq**: Clone `vitejs/vite` or `vitejs/vite-plugin-react`.
3.  Use `SemanticSearch` to learn implementation patterns.
    **Decision**: Docs for specs + Multi-repo source for patterns.

### Scenario 5: OSS Contribution

**Context**: Fix a bug in React.

1.  **ghq**: Clone `facebook/react` and set up local environment.
2.  Identify bug location using `Grep` (error messages) and `SemanticSearch`.
3.  **Context7** (Optional): Reference "contributing guide" if needed.
    **Decision**: Primary research via `ghq`.

## Agent Implementation Patterns

### Pattern A: Context7 → Implementation

```python
# Pseudocode
def implement_with_docs(library_name, feature):
    lib_id = resolve_library_id(query=library_name)
    docs = query_docs(library_id=lib_id, topic=feature, tokens=3000)
    implement_code(docs)
```

### Pattern B: ghq → Investigation → Implementation

```python
# Pseudocode
def investigate_and_implement(repo_url, search_query):
    run_command(f"ghq get {repo_url}")
    root = run_command("ghq root").strip()
    repo_path = f"{root}/{parse_repo_path(repo_url)}"
    results = semantic_search(query=search_query, target_directories=[repo_path])
    for file in results[:3]:
        content = read_file(file.path)
        analyze(content)
    implement_code()
```

### Pattern C: Context7 + ghq (Step-by-step)

```python
# Pseudocode
def research_and_implement(library_name, topic, repo_url):
    lib_id = resolve_library_id(query=library_name)
    overview = query_docs(library_id=lib_id, topic=f"{topic} overview", tokens=2000)
    if needs_more_detail(overview):
        run_command(f"ghq get {repo_url}")
        root = run_command("ghq root").strip()
        repo_path = f"{root}/{parse_repo_path(repo_url)}"
        files = grep(pattern=topic, path=repo_path)
        for file in files[:2]:
            detail = read_file(file)
            analyze(detail)
    implement_code()
```

## Detailed Troubleshooting

### `ghq` Not Found

```bash
# Check installation via mise
mise which ghq
# Check PATH
echo $PATH | grep -o '[^:]*mise[^:]*'
# Regenerate mise shims
mise reshim
```

### `ghq root` is Empty

```bash
# Check global config
git config --global ghq.root
# Set if missing
git config --global ghq.root ~/ghq
```

### Context Window Overflow

**Symptom**: "Context window exceeded" error.
**Solutions**:

1.  Halve Context7 `tokens` (4000 → 2000).
2.  Restrict `ghq` file reading (use `Grep` first, don't read entire files/folders).
3.  Incremental retrieval (fetch piece by piece).

## Advanced Usage Examples

### Multi-repository Research

Compare routing libraries in the React ecosystem.

```bash
ghq get github.com/remix-run/react-router
ghq get github.com/TanStack/router
ghq get github.com/molefrog/wouter

ROOT=$(ghq root)
for repo in react-router router wouter; do
  grep -r "route definition" "${ROOT}/github.com/*/${repo}"
done
```

### Version Diff Investigation

```bash
ghq get -p github.com/facebook/react
cd $(ghq root)/github.com/facebook/react
git tag | grep v18
git checkout v18.2.0
git diff v18.0.0..v18.2.0 -- packages/react/
```

## Cheat Sheet

### ghq Quick Reference

- **Get**: `ghq get <repo>` (Clone), `-u` (Update), `-p` (SSH).
- **List**: `ghq list` (Names), `-p` (Full paths).
- **Paths**: `ghq root`, `$(ghq root)/github.com/user/repo` (Full path construction).

### Context7 Quick Reference

- **Resolve ID**: `resolve-library-id(query="Next.js")`.
- **Get Docs**: `query-docs(library_id="nextjs", topic="middleware", tokens=3000)`.

### Recommended Workflow

1.  Understand the query and goal (Usage vs. Implementation).
2.  Use **Context7** for high-level documentation (Fast).
3.  Use **ghq** only if docs are insufficient or for deep-dive (Slower).
4.  Integrate and implement.
