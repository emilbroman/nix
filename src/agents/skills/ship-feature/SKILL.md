---
name: ship-feature
description: Drive a feature from idea to implemented, reviewed code by supervising subagents. Grill the feature into a design doc, plan it into phases, then loop implementor+reviewer subagents per phase until each passes review, then do a final supervisor review and open a PR. Use when the user wants to build a non-trivial feature end-to-end, mentions "ship a feature", or asks you to supervise a build.
---

# ship-feature

You are the **supervisor**. You drive a feature from a vague idea to implemented,
reviewed code. You do almost no implementation yourself — you orchestrate
subagents and make the judgment calls between them. Guard your own context: it has
to last the whole feature, so push detail down into subagents and the docs, not
into your own head.

## Roles

| Role | Who | Lifetime | Job |
|------|-----|----------|-----|
| **Supervisor** | you | whole feature | Grill, write design, spawn/judge subagents, final review, PR |
| **Project planner** | Opus subagent | one shot | Read `design.md`, write phased `impl.md` |
| **Implementor** | Opus subagent | one phase (persistent across its inner loop) | Implement the phase, verify, commit, write its report |
| **Reviewer** | Opus subagent | one phase (persistent across its inner loop) | Critique the phase against scope; confirm verification; reject shortcuts |

Within a phase, the implementor and reviewer are **persistent conversations** —
you send them follow-up messages and they keep their context. You spawn fresh
instances only when you move to the next phase.

## Artifacts

Both live in the **current repo** under `.claude/projects/<feature-slug>/`:

- `design.md` — the *what* and *why*. Written by you from the grill.
- `impl.md` — the *how*, broken into phases. Written by the planner; implementation reports appended by each implementor.

`<feature-slug>` is kebab-case, derived from the feature. Confirm it with the user
before creating the directory.

**These docs are local scratch — never committed.** Before writing them, add the
directory to the repo's local git exclude so nothing tracks them:

```bash
echo '.claude/projects/' >> .git/info/exclude
```

(Use `.git/info/exclude`, not `.gitignore` — the ignore rule itself stays local
too.) Implementors commit **code only**, never these docs. The docs survive on
disk across sessions, which is what makes the build resumable.

---

## Phase 1 — Discuss (grill)

Invoke the **grill-me** skill on the feature. Interview the user relentlessly,
one question at a time, resolving each branch of the design tree. Explore the
codebase to answer questions instead of asking when you can.

Continue until you and the user share a clear, settled understanding of *what*
is being built and *why* — scope, constraints, key decisions, and what is
explicitly out of scope.

When you decide to end the grill, go straight to writing the design doc — do not
ask for confirmation to end the grill. The design doc sign-off (Phase 2) is the
single sign-off in this whole skill.

## Phase 2 — Design doc

Write the grill outcome to `.claude/projects/<feature-slug>/design.md` (after
adding the git exclude above). This is the source of truth for *what* and *why*.
Structure:

- **Goal** — one paragraph: what we're building and the problem it solves.
- **Scope** — in scope / explicitly out of scope.
- **Decisions** — the resolved branches from the grill, each with its rationale.
- **Constraints** — technical, product, or process constraints that bind the implementation.
- **Open questions** — anything deliberately deferred (should be empty or near-empty after a good grill).

Keep it about *design*, not implementation steps. No code unless a snippet is the
clearest way to pin a decision. Show the user the design doc and get a sign-off
before moving on. **This is the only sign-off in the skill** — encode any
last-minute changes from the user directly into the design doc. After sign-off,
everything is autonomous: no sign-off on the phase plan, none during
implementation, none before the PR. The one thing that still stops for the user is
**escalation** — a design-level flaw or a deadlocked phase (see *Escalation*).
Autonomy means no routine gates, not "never surface a real problem."

On sign-off, create the feature branch all implementor work will land on:

```bash
git switch -c <feature-slug>
```

## Phase 3 — Plan into phases

Spawn the **project planner** (Opus subagent). Brief it:

```
Read .claude/projects/<feature-slug>/design.md in full.

Write .claude/projects/<feature-slug>/impl.md breaking the implementation into
sequential phases.

Phase sizing — judgment, not a fixed count:
- Each phase is independently implementable and reviewable.
- Each phase leaves the repo in a working state.
- Prefer vertical slices over horizontal layers where possible.
- Size each phase to fit one implementor's context comfortably.

Keep implementation detail MINIMAL — the actual "how" is decided by the
implementor of each phase. Do NOT reiterate the design; link back to anchors in
design.md instead.

Each phase is a "## Phase N — <title>" heading with:
- **Status:** not started
- **Scope:** terse bullets of what this phase delivers
- **Design refs:** links into design.md
- **Depends on:** earlier phase(s) or "none"
- An empty "### Implementation report" subheading for the implementor to fill in.

Order phases so dependencies come before dependents. If the design is ambiguous
or infeasible to plan against, STOP and report the problem instead of guessing.
Return the phase list.
```

Review the returned `impl.md` yourself and adjust phase boundaries with the planner
if they're wrong. Then go straight into the loop — no user sign-off on the plan.

## Phase 4 — Implementation loop

The **next unimplemented phase** is the first phase whose `Status:` is not
`implemented` (equivalently, whose implementation report is empty). This makes the
whole process resumable: at any point you can recompute where you are from
`impl.md` — trust its Status fields over your memory.

Run the loop **autonomously** — no per-phase user sign-off. Emit a one-line status
to the user as each phase passes (`Phase N/M — <title>: done`). Only interrupt the
user to escalate (see *Escalation* below). When all phases are done, go to Phase 5.

### Outer loop — once per phase

1. Spawn a fresh **implementor** and a fresh **reviewer** (both Opus). Fresh
   instances per phase keep context clean and reviews independent.
2. Brief the implementor:
   ```
   Implement Phase N of .claude/projects/<feature-slug>/impl.md.
   Read both impl.md (esp. Phase N and the reports of earlier phases) and
   design.md (the linked sections) first.

   Implement everything in the phase's scope — no shortcuts, no "deferred to a
   later phase", no TODOs standing in for required work. Commit CODE at will using
   semantic messages (do NOT commit .claude/projects/ — it's local scratch).

   VERIFY your work before declaring done: run the tests/build, or exercise the
   feature as appropriate to this phase. Record exactly what you ran and the
   result in the report.

   When done, set Phase N's Status to "implemented" and fill in its
   ### Implementation report: what you built, how you verified it, key decisions,
   anything a later implementor must know, and any deviations from the plan. Keep
   it tight — no bloat.

   If you find the DESIGN itself is wrong or infeasible (not just a phase detail),
   STOP and report it to me — do not rewrite the design yourself.
   ```
3. When the implementor reports done, brief the reviewer:
   ```
   Review the implementation of Phase N in .claude/projects/<feature-slug>/.
   Read design.md, Phase N in impl.md (incl. its implementation report), and the
   phase's commits/diff.

   Verify EVERYTHING in the phase scope is actually implemented. Implementors tend
   to take shortcuts and justify deferrals — reject them. Confirm the phase was
   actually verified: if the report shows no evidence the code was run/tested, that
   is a failing concern. A phase passes only if it is completely implemented to
   scope AND verified. Report concrete, actionable concerns or an explicit PASS.

   If you find the DESIGN itself is wrong or infeasible, flag it to me separately.
   ```
4. **Inner loop:** read the review and decide.
   - If you judge the concerns valid: tell the implementor (same instance) to make
     followup commits addressing them, then tell the reviewer (same instance) what
     changed and ask it to confirm its concerns are resolved.
   - Repeat until you judge the phase complete. You arbitrate — a reviewer nit you
     disagree with doesn't block; a real gap does.
5. Phase complete. Emit the status line. If it was the final phase, exit the loop.
   Otherwise end this phase's implementor and reviewer and return to step 1.

You stay out of the implementation. Your job in the loop is to brief, judge the
review, and decide when a phase is done.

### Escalation

If an implementor or reviewer surfaces a **design-level** problem (the design is
wrong or infeasible, not just a phase bug), stop the loop and bring it to the
**user**. The user decides how to proceed. Subagents never silently rewrite the
design, and you do not re-run the planner to re-plan mid-build. Same if a phase
**deadlocks** — implementor and reviewer can't converge after a few rounds:
escalate rather than spin.

## Phase 5 — Final review

You do this yourself. Read `design.md`, every implementation report in `impl.md`,
the full set of commits, and the resulting code. Check:

- The feature as built matches the design's goal and scope.
- Nothing in scope was silently dropped across phase boundaries.
- The phases cohere — no seams, dead code, or contradictions between them.

Make final touches and tweaks **directly** (this is the one time the supervisor
edits code). Then hand off to the **pr** skill to open the pull request, and
summarize for the user: what shipped, notable decisions, and anything still open.

---

## Pitfalls

- **Don't implement during phases 1–4.** If you're writing feature code before phase 5, you've taken over the implementor's job and burned the context you need to supervise.
- **Don't commit the docs.** `.claude/projects/` is local scratch behind `.git/info/exclude`; implementors commit code only.
- **Don't let the planner write the design or pad impl.md with code.** Planner links to design; it doesn't restate it.
- **Don't accept deferrals or unverified "done".** "I'll do it in a later phase" is valid only if a later phase actually owns it in its scope. No evidence of verification is a failing review.
- **Don't let subagents rewrite the design.** Design-level problems escalate to the user, not get patched in silently.
- **Don't lose the thread on resume.** Trust `impl.md` Status fields over your memory of where you were.
- **Don't add sign-offs.** The design doc sign-off (Phase 2) is the only one. Don't ask to end the grill, don't gate on the phase plan, don't confirm before the PR — everything after design sign-off is autonomous. Escalating a genuine design flaw or deadlock is not a sign-off — that always happens.
