## 1. OpenSpec main specs

- [ ] 1.1 Archive or copy this change's deltas into `openspec/specs/<capability>/spec.md` for documentation, directory, tech, security, go-template, architecture, github-identity, machine-profile
- [ ] 1.2 Fill `openspec/config.yaml` project context from AGENTS.md + tech source-of-truth paths (no tool catalogs)

## 2. Architecture move

- [ ] 2.1 Copy `docs/architecture/c4-*.md` to `openspec/specs/architecture/` keeping filenames
- [ ] 2.2 Rewrite C4 cross-links so they do not point at `docs/`
- [ ] 2.3 Put reading order in `openspec/specs/architecture/spec.md` (already specified)

## 3. GitHub identity

- [ ] 3.1 Make source-managed gh default user `budybye`
- [ ] 3.2 Confirm `boborder` remains a `gh auth switch` target
- [ ] 3.3 Remove `dayjobdoor` from any repo-managed default or docs

## 4. Machine profiles

- [ ] 4.1 Add chezmoi data map hostname → desktop | minimal | darwin
- [ ] 4.2 Record `101` as this Mac
- [ ] 4.3 Gate `linux.gui` packages and Linux GUI scripts on desktop hostnames
- [ ] 4.4 Leave Ubuntu hostname rows blank or fail-closed until the operator fills them

## 5. Retarget and delete docs

- [ ] 5.1 Point README.md and AGENTS.md at `openspec/`
- [ ] 5.2 Fix CI / workflow `docs/` path references
- [ ] 5.3 Delete `docs/` including architecture after links are clean
- [ ] 5.4 Run `graphify update .`

## 6. Verify

- [ ] 6.1 `openspec validate --change organize-docs-profiles`
- [ ] 6.2 Confirm `docs/` is gone and C4 files exist under `openspec/specs/architecture/`
- [ ] 6.3 Confirm supported gh accounts are only `budybye` and `boborder`
