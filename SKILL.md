---
name: icm-command-center
description: Show a command center for the current ICM workspace, an inline widget with a Start button and a Results button for every workflow and Create buttons for ICM items. Use when the user types /icm-command-center or asks for the dashboard, command center, or a menu of workflows.
---

# ICM command center

## Cache first (do this before anything else)
The finished widget is saved in `cache/widget.html`, with a fingerprint of the workspace it was built
from in `cache/fingerprint.txt`. The cache belongs to one workspace: if this skill is copied to another
workspace, the fingerprint won't match and it rebuilds (or delete `cache/`).
1. If the user's request says rebuild, refresh, regenerate or update, skip to **Build** below.
2. Otherwise run `sh .claude/skills/icm-command-center/fingerprint.sh` from the workspace root and
   compare its output with `cache/fingerprint.txt`.
3. Same fingerprint: read `cache/widget.html` and pass its contents unchanged as `widget_code` to
   `show_widget` (call `read_me` with `modules: ["interactive"]` first, silently). Do not rebuild, re-read
   the workflow cards, or edit it. Add no text beyond one short line.
4. Different fingerprint (a workflow was added, removed or renamed): say in one line
   that the workflows changed, then **Build**.
5. After every Build: save the new widget code to `cache/widget.html` and the new fingerprint to
   `cache/fingerprint.txt`, then show it.
If `cache/` is missing or unreadable, Build, then create `cache/` (next to this file) and save both files there.

## Build

Render an inline widget with `mcp__visualize__show_widget` (call `mcp__visualize__read_me` with
`modules: ["interactive"]` first, silently). Every button calls `sendPrompt(...)`, which sends a
message to this chat as if the user typed it. Show only the widget plus one short line of text.

## Build the workflow cards from the workspace (never from memory)
1. A workflow is any top-level folder in the workspace root that contains both `CLAUDE.md` and
   `CONTEXT.md` and whose name does not start with `_`. List them with the folder names.
2. Title = the folder name. Description = about 8 words taken from the first lines of the folder's own
   `CLAUDE.md`. Read nothing outside the workflow folders and the root `CLAUDE.md`.
3. Each card has two buttons:
   - **Start**: `Run the <title> workflow. Follow its CLAUDE.md and ask me the questions it needs.`
   - **Results**: `Show me the results and output files for the <title> workflow: list the most recent ones with clickable links and a one-line summary of each.`
     When answering, look in the folder's `output/`, `outputs/`, `reports/`, `presentations/`, `response/` and `RUN-LOG.md`, plus any other output-like folder it names.
4. Under the cards, one **All results** button: `Show me a summary of the latest results and output files for every workflow in this repository, with clickable links.`

## ICM create section
Fixed list. Each **Create** button sends a prompt that asks Claude to start and ask what it needs:
- New workflow, Knowledge library, Context map, Repo edit map, Restructure to ICM: the `icm-architect` skill only.
- If `icm-architect` changes, update this list.

## Look and feel
Same layout as the original: section labels "RUN A WORKFLOW" and "CREATE WITH ICM", a responsive grid
(`repeat(auto-fit,minmax(260px,1fr))`), one raised card per item (12px radius, 0.5px border), a Tabler
icon in a tinted square, title 14px/500, description 12px secondary, buttons in the card's bottom row
(Start has an accent border), `↗` after every button label. Use CSS variables only, no emoji, no
hard-coded colours. Pick one icon per workflow that fits its job and colour-group related workflows
by theme of the workflow (accent, warning, success), ICM = pro. Build the cards in JS from an array
and attach one delegated click handler (`data-*` attributes), as before.

## Keeping it current
A new workflow appears automatically once its folder has both `CLAUDE.md` and `CONTEXT.md`. A folder
that is renamed, removed, or loses either file drops off the dashboard. This skill assumes nothing about a specific workspace.
