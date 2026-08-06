---
name: pr
description: Open a clean pull request for the current branch. Grounds title and body in the actual diff, terse and exact, follows the repo template. Use when the user says "open a PR", "/pr", or asks to create a pull request.
---

# PR

Open a pull request grounded in the diff. Title and body terse and exact. No fluff. Why over what — the diff says what.

## Steps

1. `git status`, `git log <base>..HEAD`, `git diff <base>...HEAD` — understand exactly what changed. Default base is the repo's main branch unless told otherwise.
2. If branch isn't pushed: `git push -u origin <branch>`.
3. Look for a template (`.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/`). If present, structure the body around it — don't override its sections with this style.
4. Write title + body grounded in the actual diff. Never invent details, vendor names, or scope not in the diff.
5. Open with `gh pr create`. `--draft` if work incomplete or user asks.

## Rules

**Title:**
- `<type>(<scope>): <imperative summary>` if the repo enforces Conventional Commits (check for PR-title validation). Else match repo convention.
- Imperative mood: "add", "fix", "remove" — not "added", "adds".
- ≤72 chars, no trailing period.

**Body:**
- Lead with the *why* — the motivation/problem the diff doesn't show. One short paragraph.
- Then a terse bullet list of notable changes (`-` not `*`), only what a reviewer can't infer at a glance.
- Skip sections that add nothing. A small, self-explanatory PR can be one line.
- No hard line wraps. Reference issues at end: `Closes #42`, `Refs #17`.
- Always end body with: `🤖 Generated with [<current harness name>](<web link to harness>)`
  - Codex example: `🤖 Generated with [Codex](https://openai.com/codex/)`
  - Claude Code example: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

**What NEVER goes in:**
- "This PR does X", "I", "we", "now", "currently" — restating the diff.
- Emoji unless repo convention requires.
- Restating the filename when scope already says it.
- A test-plan section invented out of thin air — only include if you actually ran/know the steps.

## Examples

Diff: new profile endpoint, bandwidth-driven
- ❌ "This PR adds a new endpoint to fetch user profile info from the database."
- ✅
  ```
  feat(api): add GET /users/:id/profile

  Mobile client needs profile data without the full user payload to cut LTE bandwidth on cold-launch screens.

  - new route returns only display fields, no nested orders
  - cached 60s at the edge

  Closes #128
  ```

Diff: one-line typo fix
- ✅ title `docs: fix broken link in README`, body empty

## Auto-Clarity

Always include the *why* for: breaking changes, security fixes, data migrations, reverts. Note rollout/migration steps reviewers must take.

## Boundaries

Writes the PR title and body and opens via `gh pr create`. Does not commit, stage, or push unrelated work-in-progress. Confirm the base branch if ambiguous. "stop caveman" / "normal mode": revert to verbose PR style.
