---
allowed-tools: Bash(git log:*)
argument-hint: [number-of-commits]
description: Review recent git commits and summarize what has been worked on
---

## Context

Recent commits (last $ARGUMENTS or 30 if not specified): !`git log --oneline -${1:-30}`

## Your Task

Based on the commit history above:

1. **Group commits by feature/area** - Identify the main themes or features being worked on
2. **Summarize each area** - Provide a brief description of what was accomplished
3. **Highlight recent focus** - What appears to be the most active area of development
4. **Note any patterns** - Mention any notable patterns (e.g., lots of bug fixes, new features, refactoring)

Keep the summary concise but informative. Use bullet points and headers for clarity.
