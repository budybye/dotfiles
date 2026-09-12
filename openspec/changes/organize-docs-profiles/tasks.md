## 1. OpenSpec main specs

- [x] 1.1 Keep the structured deltas and capability specs available locally for optional planning
- [x] 1.2 Fill `openspec/config.yaml` project context from AGENTS.md + canonical documentation paths (no tool catalogs)

## 2. Architecture and documentation boundaries

- [x] 2.1 Keep `docs/architecture.md` as the public architecture entry point
- [x] 2.2 Keep OpenSpec artifacts optional and prevent reverse dependencies from `docs/` to OpenSpec
- [x] 2.3 Keep the eight canonical docs aligned with executable configuration sources

## 3. GitHub identity

- [ ] 3.1 Make source-managed gh default user `budybye`
- [ ] 3.2 Confirm `boborder` remains a `gh auth switch` target
- [ ] 3.3 Remove `dayjobdoor` from any repo-managed default or docs

## 4. Machine profiles

- [ ] 4.1 Add chezmoi data map hostname → desktop | minimal | darwin
- [ ] 4.2 Record `101` as this Mac
- [ ] 4.3 Gate `linux.gui` packages and Linux GUI scripts on desktop hostnames
- [ ] 4.4 Leave Ubuntu hostname rows blank or fail-closed until the operator fills them

## 5. Public documentation and local planning

- [x] 5.1 Keep README.md and AGENTS.md usable without OpenSpec
- [x] 5.2 Fix stale documentation links and remove retired public doc paths
- [x] 5.3 Keep OpenSpec files local-only via the root `.gitignore`
- [x] 5.4 Run `graphify update .`

## 6. Verify

- [ ] 6.1 `openspec validate --change organize-docs-profiles`
- [ ] 6.2 Confirm `docs/` is gone and C4 files exist under `openspec/specs/architecture/`
- [ ] 6.3 Confirm supported gh accounts are only `budybye` and `boborder`
