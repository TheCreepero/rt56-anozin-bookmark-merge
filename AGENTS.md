# RT56 - Anozin's USA Bookmark Merge - Agent Rules

Shared rules for every mod in this tree (file encodings, build commands, engine knowledge, git) are in the Modding Manager's `../../AGENTS.md`. `CLAUDE.md` and `GEMINI.md` import this file.

## What this mod is
- A patch for the Local Modpack: restores Road to 56's 1936 start screen for every country and keeps Anozin's entry for the United States.
- Ships one content file, `common/bookmarks/the_gathering_storm.txt`: the standalone's copy with the ideas and focuses of its USA entry replaced by Anozin's.
- Local only: it carries another author's file, so it is never published to the Workshop and has no Workshop id.
- Standard single-root layout: `descriptor.mod`, `build.ps1`, content folders, `tests/`, `tools/`, `wiki/` at the root; `artifacts/` and `scratch/` are git-ignored.
- The plan, with the design, the open questions and the verification, is `../../docs/mod-plans/rt56-anozin-bookmark-merge.md`.

## Mod invariants
- Ship only the merged bookmark file, under the game's own name: it takes the place of the whole file, so it must hold every country's entry [LOAD-010].
- Load after both required mods: `dependencies` in `descriptor.mod` names `RT56 - VNR - UTT Standalone v14` and `Anozin's USA Reimagined`, and the launcher's `.mod` file needs the same lines [LOAD-014]. `Anozin's USA Reimagined` (`3683330006`) must also list `RT56 - VNR - UTT Standalone v14` in its frozen `descriptor.mod` and `.mod` (`localDependencies` in `Config/frozen_workshop_mods.json`) so this patch does not tie their priorities [LOAD-014] [LOAD-015].
- A new frozen version of Anozin's USA Reimagined, or a new standalone version, means a new merge: compare the bookmark of each again and rewrite the file, and update the dependency names when a name changes.
- Write `.txt` files as UTF-8 without BOM [ENC-001]. Keep the `key="value"` form in `descriptor.mod`, no spaces around `=` [ENC-004].

## Commands beyond build.ps1
- None yet.

## Read when
| Task | Read |
|---|---|
| Changing the merge or checking it | `../../docs/mod-plans/rt56-anozin-bookmark-merge.md` |

## Engine Knowledge
- Engine facts live in the Modding Manager's register, reached through the user-level `hoi4-modding-knowledge` skill: search it before a new kind of file and before asking for a game launch, cite ids here, never write a fact into this repository.
- Topics this mod leans on: `encoding-and-syntax`, `loading-and-overrides`.
- `tests/Knowledge.Tests.ps1` runs the register's audit for this repository; it is a copy the Manager keeps current.
