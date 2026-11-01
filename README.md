# ICM Command Center

A Claude Code skill that shows an inline dashboard for an ICM (Interpretable Context Methodology)
workspace: one card per workflow with **Start** and **Results** buttons, plus a **Create with ICM**
section for building new workflows, knowledge libraries, context maps and more.

Every button sends a ready-made prompt to the chat, so running a workflow or checking its output is
one click instead of a typed request.

It is a companion to [icm-architect](https://github.com/RinDig/icm-architect), the skill that designs
ICM workspaces. Use icm-architect to build the workspace and its workflows, then use this skill to run
them and find their results.

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
- The [icm-architect](https://github.com/RinDig/icm-architect) skill, for the Create buttons. The
  workflow cards work without it in any workspace laid out the ICM way.
- A POSIX shell to run `fingerprint.sh` (Git Bash on Windows, macOS, Linux). It uses `sha1sum`
  where available and falls back to `shasum -a 1` (macOS).

## Installation

The skill is installed per workspace, inside the workspace's `.claude/skills/` folder. From the root
of your ICM workspace, clone the repository:

```bash
git clone https://github.com/phoem/icm-command-center.git .claude/skills/icm-command-center
```

The result should look like this:

```
<workspace>/
└── .claude/
    └── skills/
        └── icm-command-center/
            ├── SKILL.md
            ├── fingerprint.sh
            └── README.md
```

Start a new Claude Code session in the workspace (or restart the current one) so the skill is picked
up, then type `/icm-command-center`.

**Without git:** download the ZIP from
[github.com/phoem/icm-command-center](https://github.com/phoem/icm-command-center) (**Code → Download
ZIP**), extract it, and copy its contents into `<workspace>/.claude/skills/icm-command-center/`.

**Install it in the workspace, not in `~/.claude/skills/`.** `fingerprint.sh` locates the workspace
root three folders above itself, so a user-level install would fingerprint the wrong folder and never
use the cache.

`cache/` is not in the repository. It is created on the first run and belongs to the workspace that
built it (see [Caching](#caching)). If you copy the skill from another workspace instead of cloning
it, leave `cache/` behind.

### Updating

```bash
git -C .claude/skills/icm-command-center pull
```

Then ask for `/icm-command-center rebuild` so the widget picks up any changes to the layout.

## Usage

Type `/icm-command-center`, or ask for "the dashboard", "the command center" or "a menu of
workflows".

To force a fresh build, include *rebuild*, *refresh*, *regenerate* or *update* in the request, e.g.
`/icm-command-center rebuild`.

## How workflows are found

A workflow is any **top-level folder** in the workspace root that:

1. contains both `CLAUDE.md` and `CONTEXT.md`, and
2. has a name that does not start with `_`.

Workflows created with [icm-architect](https://github.com/RinDig/icm-architect) have a `CONTEXT.md`,
and in a Claude Code workspace a `CLAUDE.md` pointer to their `AGENTS.md`, so they appear on the
dashboard without any extra setup.

The card title is the folder name; the description is about eight words taken from the top of the
folder's `CLAUDE.md`, or from its `AGENTS.md` when `CLAUDE.md` is only an `@AGENTS.md` pointer. Add a folder that meets these rules and it appears on the dashboard; rename or
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

The fingerprint covers folder **names** only. If you change a workflow's `CLAUDE.md` or `AGENTS.md`
description and want the card text updated, ask for a rebuild.

## Files

| File | Purpose |
| --- | --- |
| `SKILL.md` | Instructions Claude follows to find workflows, build the widget and use the cache |
| `fingerprint.sh` | Prints the workspace fingerprint used to decide whether the cache is still valid |
| `cache/` | Generated per workspace; not part of the distributed skill |
