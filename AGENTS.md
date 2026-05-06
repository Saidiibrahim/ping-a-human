# Repository Guidelines

## Project Orientation

This repository is a Codex skill/plugin project. The primary deliverable is the repo-local `ping-a-human` plugin and its `$ping-a-human` skill, which lets macOS coding agents send one short local desktop ping when they are blocked on human input.

Treat the root SwiftPM package, Bash wrapper, AppleScript fallback, and SVG preview as development sources for the runtime bundled inside the skill. Any runtime change must be reflected in `plugins/ping-a-human/skills/ping-a-human/scripts/` or `plugins/ping-a-human/skills/ping-a-human/assets/` before completion.

## Project Structure & Module Organization

- `plugins/ping-a-human/.codex-plugin/plugin.json`: plugin manifest and UI metadata.
- `plugins/ping-a-human/skills/ping-a-human/SKILL.md`: agent-facing skill instructions and trigger contract.
- `plugins/ping-a-human/skills/ping-a-human/agents/openai.yaml`: skill UI metadata.
- `plugins/ping-a-human/skills/ping-a-human/scripts/`: bundled Bash, AppleScript, and SwiftPM runtime used by the skill.
- `.agents/plugins/marketplace.json`: repo-local marketplace registration.
- `Package.swift`, `Sources/PingHumanToast/main.swift`, `ping-human`, `ping-human.applescript`, `docs/ping-human-toast.svg`: root development sources for the bundled runtime.

## Build, Test, And Validation Commands

- `python3 /Users/ibrahimsaidi/.codex/skills/.system/skill-creator/scripts/quick_validate.py plugins/ping-a-human/skills/ping-a-human`: validate skill frontmatter and naming.
- `python3 -m json.tool plugins/ping-a-human/.codex-plugin/plugin.json >/dev/null && python3 -m json.tool .agents/plugins/marketplace.json >/dev/null`: validate plugin and marketplace JSON.
- `swift build`: build the root development copy of the native toast helper.
- `(cd plugins/ping-a-human/skills/ping-a-human/scripts && swift build)`: build the bundled skill copy.
- `bash -n plugins/ping-a-human/skills/ping-a-human/scripts/ping-human`: syntax-check the bundled wrapper.
- `osacompile -o /tmp/ping-human-plugin-fallback.scpt plugins/ping-a-human/skills/ping-a-human/scripts/ping-human.applescript && rm -f /tmp/ping-human-plugin-fallback.scpt`: compile-check the bundled AppleScript fallback.
- `./ping-human "Short message"` or `plugins/ping-a-human/skills/ping-a-human/scripts/ping-human "Short message"`: smoke the desktop ping path when an actual local notification is acceptable.

## Runtime Sync Contract

After changing a root runtime source, update the bundled skill copy:

```sh
cp Package.swift plugins/ping-a-human/skills/ping-a-human/scripts/Package.swift
cp Sources/PingHumanToast/main.swift plugins/ping-a-human/skills/ping-a-human/scripts/Sources/PingHumanToast/main.swift
cp ping-human plugins/ping-a-human/skills/ping-a-human/scripts/ping-human
cp ping-human.applescript plugins/ping-a-human/skills/ping-a-human/scripts/ping-human.applescript
cp docs/ping-human-toast.svg plugins/ping-a-human/skills/ping-a-human/assets/ping-human-toast.svg
chmod +x plugins/ping-a-human/skills/ping-a-human/scripts/ping-human
```

Before finishing, confirm parity for copied runtime files:

```sh
cmp -s Package.swift plugins/ping-a-human/skills/ping-a-human/scripts/Package.swift
cmp -s Sources/PingHumanToast/main.swift plugins/ping-a-human/skills/ping-a-human/scripts/Sources/PingHumanToast/main.swift
cmp -s ping-human plugins/ping-a-human/skills/ping-a-human/scripts/ping-human
cmp -s ping-human.applescript plugins/ping-a-human/skills/ping-a-human/scripts/ping-human.applescript
cmp -s docs/ping-human-toast.svg plugins/ping-a-human/skills/ping-a-human/assets/ping-human-toast.svg
```

## Coding Style & Naming Conventions

Use Swift 5.9 and keep the macOS 13 minimum declared in `Package.swift`. Follow existing Swift style: 4-space indentation, `private` for file-local implementation details, PascalCase types such as `ToastController`, and lowerCamelCase functions/properties such as `shortenedMessage`.

Keep Bash strict-mode compatible with `set -euo pipefail`, quote path expansions, and resolve paths relative to the wrapper. AppleScript fallback code uses tab indentation. Keep skill names, plugin names, and marketplace entries lowercase hyphen-case.

## Skill Content Rules

Keep `SKILL.md` concise and agent-facing. It should explain when to use `$ping-a-human`, how to run the bundled helper, and the operating rules for short non-sensitive messages. Do not add generic README, changelog, or installation files inside the skill folder; bundled resources should directly support the skill.

## Security & Configuration Tips

Do not commit `.build/`, `.swiftpm/`, `.codex/`, `.vscode/`, or other generated local metadata. Keep ping messages short and non-sensitive; they are desktop attention signals, not detailed handoffs.
