---
name: ping-a-human
description: Use when a Codex coding agent running on macOS is blocked, waiting on human input, or explicitly asked to wake/notify/ping the human with a short local desktop toast or Notification Center message. Supports the bundled Ping A Human Swift/AppKit toast helper plus an AppleScript fallback; do not use for routine progress updates or detailed handoffs.
---

# Ping A Human

Send one short local macOS attention signal when work is blocked on a human. Keep the message terse and non-sensitive; this is a wake-up cue, not a task handoff.

## Decision

Use this skill only when at least one condition is true:

- The user explicitly asks to ping, wake, notify, or alert them.
- The agent cannot proceed without human approval, credentials, local UI action, or external decision.
- A long-running local workflow needs a human to return before the next step.

Do not ping for normal status updates, successful completion, or information that can wait for the final response.

## Quick Start

Set `SKILL_DIR` to this skill folder, then run the stable wrapper:

```bash
SKILL_DIR="/path/to/plugins/ping-a-human/skills/ping-a-human"
"$SKILL_DIR/scripts/ping-human" "Review database cutover?"
```

With no argument, the wrapper uses:

```text
An agent is paused and needs a human before continuing.
```

Messages are capped at 90 characters by the wrapper. Prefer short prompts such as:

```bash
"$SKILL_DIR/scripts/ping-human" "Need approval before applying live SQL."
"$SKILL_DIR/scripts/ping-human" "Please complete the browser login."
```

## Native Toast

Build the native helper once when SwiftPM is available:

```bash
(cd "$SKILL_DIR/scripts" && swift build)
```

After the build, `scripts/ping-human` automatically uses `.build/debug/ping-human-toast`. The native toast is a small top-right AppKit window with fixed title, subtitle, styling, and 10-second auto-dismiss.

Run the helper directly only when title/subtitle overrides are needed:

```bash
"$SKILL_DIR/scripts/.build/debug/ping-human-toast" \
  --title "Ping A Human" \
  --subtitle "Agent is waiting" \
  "Review database cutover?"
```

## Fallback

If the native helper is not built, the wrapper automatically runs the AppleScript fallback:

```bash
osascript "$SKILL_DIR/scripts/ping-human.applescript" "Review database cutover?"
```

The fallback posts a macOS Notification Center notification and exits immediately.

## Operating Rules

- Check that the environment is macOS before relying on the helper: `uname` should return `Darwin`.
- Keep messages short, specific, and free of secrets, tokens, URLs with credentials, customer data, or detailed incident context.
- Send at most one ping for the same blocker unless the user asks for repeated notifications.
- After pinging, state the blocker and the exact input/action needed in the conversation or task log.

## Bundled Files

- `scripts/ping-human`: stable Bash entrypoint for agents.
- `scripts/ping-human.applescript`: zero-dependency Notification Center fallback.
- `scripts/Package.swift` and `scripts/Sources/PingHumanToast/main.swift`: SwiftPM package for the native AppKit toast.
- `assets/ping-human-toast.svg`: static preview of the native toast design.
