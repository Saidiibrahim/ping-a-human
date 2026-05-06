---
allowed-tools: Bash(git tag:*), Bash(git push origin:*), Bash(gh release:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(grep:*), Bash(rg:*)
description: Create a new git tag and draft GitHub release
---

## Context

- Existing tags: !`git tag -l --sort=-v:refname`
- Existing releases: !`gh release list --limit 5`
- Current branch: !`git branch --show-current`
- Current HEAD: !`git log --oneline -1`
- Commits since last tag: run `git log <latest-tag>..HEAD --oneline` using the most recent tag above
- In-repo version references: run `rg -n '"version"\s*:' plugins` and `rg -n '^version:\s' plugins` to find plugin/skill manifests that pin a release version

## Your task

Based on the above context:

1. **Determine the next version** by incrementing from the latest tag (follow semver: vX.Y.Z). Ask the user to confirm before proceeding.
2. **Sync in-repo version references** before tagging. Check every plugin/skill manifest (e.g. `plugins/*/.codex-plugin/plugin.json`, any `SKILL.md` or `agents/*.yaml` that pins a version) against the new release version.
   - If any file still references the previous version (e.g. plugin.json says `0.1.0` while we are about to release `v0.2.0`), update those files first.
   - Commit the version bumps with a message like `chore: bump plugin/skill version to vX.Y.Z` and push to `origin` on the current branch.
   - Only proceed once HEAD reflects the new version everywhere.
3. **Create an annotated tag** at HEAD with the new version.
4. **Push the tag** to origin.
5. **Create a draft GitHub release** with release notes that summarize:
   - New features (from `feat:` commits)
   - Improvements (from `refactor:`, `perf:` commits)
   - Fixes (from `fix:` commits)
   - Other notable changes
