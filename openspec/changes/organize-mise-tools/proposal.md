## Why

`home/private_dot_config/mise/conf.d/tools.toml` has grown to 443 lines organized mostly by implementation language, which scatters related tools and makes commented candidates difficult to scan. The inventory needs a readability-only reorganization now, while preserving the single Mise source of truth and the exact resolved tool set.

## What Changes

- Add a compact inventory legend immediately below `[tools]` explaining active rows, commented candidates, primary-purpose sections, backend prefixes, and one-tool/one-section placement.
- Reorder every existing declaration into ten purpose-first sections: runtimes/package managers; AI/agents/context; VCS/projects/dotfiles; web/cloud/network/API; security/secrets/policy; shell/terminal/editor/navigation; data/search/formats/documentation; build/native/language tooling; testing/review/lint/quality; and desktop/media/system/miscellaneous.
- Preserve every declaration key, backend namespace, version, inline note, and active/commented state; keep exactly one `[tools]` table and add no catalog, metadata key, generator, dependency, or new config file.
- Keep installation-exception comments and intentionally commented candidates with the section that matches their primary user-facing purpose.
- Replace the standalone `MISE_TOOLS_INVENTORY_PLAN.md` with this OpenSpec change so the plan has one maintained home.
- Verify the reorganization with normalized declaration snapshots, Mise config/tool resolution, whitespace checks, and scope review.

## Capabilities

### New Capabilities

None. This is a comment and ordering-only configuration refactor; no runtime capability changes are introduced.

### Modified Capabilities

None. The existing Mise loading and installation contract remains unchanged.

## Impact

- Implementation target: `home/private_dot_config/mise/conf.d/tools.toml`.
- Planning artifact removed after migration: `MISE_TOOLS_INVENTORY_PLAN.md`.
- No APIs, dependencies, package versions, or bootstrap behavior change.
- Verification uses the existing `mise` configuration directory and standard `awk`, `sort`, and `cmp` tools.
