# Codex Skills Collection

This repository is a dated snapshot of the local collection in `TRUSOGEN/GitHub/skills`. It keeps each package under its original folder name so the sources remain easy to identify.

Initial snapshot: 2026-09-25, Australia/Sydney. `SOURCE_MANIFEST.csv` records source modification time, snapshot time, file size, and SHA-256 for every packaged file except the manifest itself. Git commit time alone does not preserve source file timestamps.

## Included collections

| Folder | Source |
| --- | --- |
| `academic-research-skills-main/` | [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) |
| `agent-progress-board/` | Local skill folder; no upstream Git remote was configured |
| `lenny-skills-main/` | [RefoundAI/lenny-skills](https://github.com/RefoundAI/lenny-skills) |
| `nature-skills-main/` | [Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills) |
| `product-manager-skills-main/` | [Digidai/product-manager-skills](https://github.com/Digidai/product-manager-skills) |
| `skills-anthropics/` | [anthropics/skills](https://github.com/anthropics/skills) |
| `skills-mattpocock/` | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `superpowers-main/` | [obra/superpowers](https://github.com/obra/superpowers) |
| `ui-ux-pro-max-skill-main/` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) |

Nested upstream `.git` directories and macOS `.DS_Store` files are excluded. Package files, documentation, examples, tests, and licenses are retained.

## Sync later local changes

The current Mac source folder remains `/Users/trusoegn/GitHub/skills/`. After it changes, run this repository's sync helper from the clone:

```sh
./scripts/sync_from_local.sh
```

The helper fast-forwards `main`, copies changed files while excluding nested `.git` directories and `.DS_Store`, refreshes the timestamp/checksum manifest, commits the snapshot, and pushes it to GitHub. Pass a source directory as the first argument if it is elsewhere. It stops before copying when the destination clone already has uncommitted edits.
