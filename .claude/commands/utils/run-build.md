---
allowed-tools: Bash(*)
description: Check and fix linting/type errors
---

# Context

The development team has been busy making changes in this codebase.

## Your task

Your task is now to ensure everything builds successfully. Please run `POSTHOG_SOURCEMAPS_ENABLED=false bun run build`, fixing any linting or type errors, until we're error free.

Note: PostHog sourcemaps are disabled for local builds because they require a valid git commit ID, which may not exist when there are uncommitted changes.
