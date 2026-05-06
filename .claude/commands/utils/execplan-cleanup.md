---
allowed-tools: Bash(git *), Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(git mv:*), Bash(git rm:*), Bash(git rev-list:*), Bash(git merge-base:*), Bash(git log:*), Bash(python3:*), Bash(bun scripts/execplan:*), Bash(ls:*), Bash(mkdir:*), Bash(find:*), Read, Write, Glob, Grep
description: Promote completed execplans, prune with retention policy, and push
---

# Context

- Policy source: `docs/PLANS.md` (retention cleanup policy, pruning eligibility gate, required cleanup run evidence)
- Cleanup run format: see the most recent file in `docs/exec-plans/cleanup-runs/` for the expected structure
- Cleanup exclusions: `legacy-artifacts`, `manual-qa`, `migrations` subfolders in `completed/` are never pruning targets
- Active initiatives: !`ls docs/exec-plans/active/ 2>/dev/null | grep -v index.md || echo "(empty)"`
- Completed initiatives: !`ls docs/exec-plans/completed/ 2>/dev/null | grep -v index.md || echo "(empty)"`
- Branch status: !`git rev-list --left-right --count origin/main...HEAD`

## Your task

Run the full execplan cleanup lifecycle. Follow each phase in order, reporting progress as you go.

### Phase 1: Promote eligible active initiatives

1. For each initiative in `docs/exec-plans/active/` (skip `index.md`):
   - Check that a `PLAN_<name>.md` file exists
   - Read `state/feature-list.json` and count total vs `passing` features
   - Read `state/session-state.json` and count open blockers
2. Report a summary table: initiative name, features passing/total, blocker count, and eligibility (all passing + 0 blockers = eligible)
3. If there are eligible initiatives, `git mv` them to `docs/exec-plans/completed/`
4. Commit: `chore: promote <N> completed initiatives from active to completed`
5. `git push`
6. If no eligible initiatives exist, skip to Phase 2

### Phase 2: Prune completed initiatives (retention cleanup)

1. Verify the branch is up to date with `origin/main` (no local commits ahead). If ahead, push first.
2. For each initiative in `docs/exec-plans/completed/` (skip `index.md` and cleanup exclusion folders):
   - Check pruning eligibility gate per `docs/PLANS.md`:
     - Has `PLAN_<name>.md` file
     - Clean working tree for the folder
     - `git rev-list -1 HEAD -- <folder>` returns a commit
     - `git merge-base --is-ancestor <path-commit> origin/main` passes
     - No local commits ahead of `origin/main`
3. Report the dry-run eligibility table with gate evidence
4. If there are eligible initiatives:
   - Write the cleanup run record to `docs/exec-plans/cleanup-runs/<date>-execplan-retention-cleanup.md` following the format of the most recent existing cleanup run file. Include all 5 sections: Run Metadata, Dry-Run Eligibility Report, Per-Folder Gate Evidence, Confirmation Evidence, Deleted Folders Summary
   - `git rm -rf` each eligible folder
   - Commit: `chore: prune <N> completed initiatives and record cleanup run`
   - `git push`
5. If no eligible initiatives exist, report that the completed folder is already clean

### Phase 3: Report final state

Show the final state of `docs/exec-plans/active/` and `docs/exec-plans/completed/` and confirm the working tree is clean.
