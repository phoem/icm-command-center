# ICM Command Center

A Claude Code skill that shows an inline dashboard for an ICM (Interpretable Context Methodology)
workspace: one card per workflow with **Start** and **Results** buttons, plus a **Create with ICM**
section for building new workflows, knowledge libraries, context maps and more.

Every button sends a ready-made prompt to the chat, so running a workflow or checking its output is
one click instead of a typed request.

## What it shows

**Run a workflow** — one card for every workflow in the workspace:
- **Start** asks Claude to run the workflow, following its `CLAUDE.md` and asking the questions it needs.
- **Results** lists the workflow's most recent output files (from `output/`, `outputs/`, `reports/`,
  `presentations/`, `response/`, `RUN-LOG.md`, and similar) with links and one-line summaries.
- **All results** (below the cards) summarises the latest output across every workflow.

**Create with ICM** — fixed buttons that start the `icm-architect` skill:
New workflow, Knowledge library, Context map, Repo edit map, Restructure to ICM.

## Requirements

- Claude Code with the `visualize` tools (`show_widget` / `read_me`) available — the dashboard is an
  inline widget.
- The `icm-architect` skill, for the Create buttons.
- A POSIX shell to run `fingerprint.sh` (Git Bash on Windows, macOS, Linux). It uses `sha1sum`
  where available and falls back to `shasum -a 1` (macOS).

## Installation

Copy the skill folder into your workspace:

```
<workspace>/
└── .claude/
    └── skills/
        └── icm-command-center/
            ├── SKILL.md
            ├── fingerprint.sh
            └── README.md
```

Do **not** copy `cache/`. It is created on the first run and belongs to the workspace that built it
(see [Caching](#caching)).

## Usage

Type `/icm-command-center`, or ask for "the dashboard", "the command center" or "a menu of
workflows".

To force a fresh build, include *rebuild*, *refresh*, *regenerate* or *update* in the request, e.g.
`/icm-command-center rebuild`.

## How workflows are found

A workflow is any **top-level folder** in the workspace root that:

1. contains both `CLAUDE.md` and `CONTEXT.md`, and
2. has a name that does not start with `_`.

The card title is the folder name; the description is about eight words taken from the top of the
folder's `CLAUDE.md`. Add a folder that meets these rules and it appears on the dashboard; rename or
remove it (or delete either file) and it drops off.

## Caching

Building the widget means reading every workflow folder, so the finished widget is cached:

| File | Contents |
| --- | --- |
| `cache/widget.html` | The rendered widget code |
| `cache/fingerprint.txt` | A 12-character hash of the workflow folder names it was built from |

On each run, `fingerprint.sh` hashes the current workflow folder names and compares the result with
`cache/fingerprint.txt`:

- **Match** — the cached widget is shown as-is, with no rebuild.
- **No match** (a workflow was added, removed or renamed) — Claude says so and rebuilds.
- **`cache/` missing** — Claude builds the widget and creates `cache/` with both files.

The fingerprint covers folder **names** only. If you change a workflow's `CLAUDE.md` description and
want the card text updated, ask for a rebuild.

## Files

| File | Purpose |
| --- | --- |
| `SKILL.md` | Instructions Claude follows to find workflows, build the widget and use the cache |
| `fingerprint.sh` | Prints the workspace fingerprint used to decide whether the cache is still valid |
| `cache/` | Generated per workspace; not part of the distributed skill |
