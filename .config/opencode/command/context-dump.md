---
description: Dump current context for model switch or context limit recovery
---

You're hitting context limits or switching models. Dump everything needed to continue seamlessly.

## Step 1: Capture Conversation State

Analyze the current conversation to extract:

- **Goal:** What are we trying to accomplish?
- **Progress:** What's been done so far?
- **Current State:** What file/function are we in the middle of?
- **Blockers:** Any issues or decisions pending?

## Step 2: Gather Technical Context

```bash
# Current branch and status
git branch --show-current
git status --short

# Recent changes (uncommitted)
git diff --stat

# Beads in progress
bd list --status in_progress --json

# Recent commits
git log --oneline -5
```

## Step 3: Identify Key Files

List files that are central to the current task:

- Files currently being edited
- Files that were read for context
- Files that will need changes next

## Step 4: Generate Context Dump

Output in this format:

```markdown
## Context Dump - [timestamp]

### Goal

[One sentence describing the objective]

### Current Task

[What specifically we're working on right now]

### Progress

- [x] [Completed step]
- [x] [Completed step]
- [ ] [Current step] <-- YOU ARE HERE
- [ ] [Next step]

### Key Files

| File            | Purpose          | State                   |
| --------------- | ---------------- | ----------------------- |
| path/to/file.ts | [why it matters] | [modified/read/pending] |

### Beads

- [bead-id]: [title] - [status]

### Key Decisions Made

- [Decision 1 and rationale]
- [Decision 2 and rationale]

### Current Problem/Blocker

[If any - what we're stuck on]

### Uncommitted Changes
```

[git diff --stat output]

```

### Continuation Prompt
---
Continue working on [goal].

Current state:
- Working in [file] on [function/component]
- [Specific context about where we left off]

Next steps:
1. [Immediate next action]
2. [Following action]

Key context:
- [Important detail 1]
- [Important detail 2]
---
```

## Step 5: Offer Options

After dumping context:

1. **Copy the continuation prompt** - for pasting into new session
2. **Commit WIP** - `git commit -m "refactor: wip - [current state]"` if appropriate
3. **File a bead** - if this is a good stopping point

**TIP:** The continuation prompt should be self-contained - assume the next session has zero prior context.
