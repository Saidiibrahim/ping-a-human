# Ping A Human

A skill and plugin for agents that are blocked and need human input. The native AppKit toast, Bash wrapper, and AppleScript fallback exist to support the `$ping-a-human` skill.

<p>
  <img src="docs/ping-human-toast.svg" alt="Ping A Human toast preview" width="448">
</p>

## Skill Package

- Skill: `plugins/ping-a-human/skills/ping-a-human/SKILL.md`
- Skill UI metadata: `plugins/ping-a-human/skills/ping-a-human/agents/openai.yaml`
- Plugin manifest: `plugins/ping-a-human/.codex-plugin/plugin.json`
- Repo marketplace entry: `.agents/plugins/marketplace.json`
- Bundled runtime: `plugins/ping-a-human/skills/ping-a-human/scripts/`

The root SwiftPM, Bash, AppleScript, and SVG files are the development sources for the runtime that the skill bundles. When those files change, sync the matching files into the plugin skill before treating the repo as complete.

## Using The Skill

Invoke the skill when an agent is blocked on human input:

```text
Use $ping-a-human to notify me that browser login is needed.
```

For direct local testing, run the bundled skill wrapper:

```sh
SKILL_DIR="plugins/ping-a-human/skills/ping-a-human"
"$SKILL_DIR/scripts/ping-human" "Review database cutover?"
```

With no argument, the wrapper uses:

```text
An agent is paused and needs a human before continuing.
```

Messages are capped at 90 characters and longer text is shortened automatically.

## Runtime Development

Build the root native toast helper while working on the AppKit implementation:

```sh
swift build
./ping-human "Review database cutover?"
```

The wrapper uses `.build/debug/ping-human-toast` when present. If the helper has not been built, it falls back to the zero-dependency AppleScript notification:

```sh
osascript ping-human.applescript "Review database cutover?"
```

After runtime changes, sync the skill bundle:

```sh
cp Package.swift plugins/ping-a-human/skills/ping-a-human/scripts/Package.swift
cp Sources/PingHumanToast/main.swift plugins/ping-a-human/skills/ping-a-human/scripts/Sources/PingHumanToast/main.swift
cp ping-human plugins/ping-a-human/skills/ping-a-human/scripts/ping-human
cp ping-human.applescript plugins/ping-a-human/skills/ping-a-human/scripts/ping-human.applescript
cp docs/ping-human-toast.svg plugins/ping-a-human/skills/ping-a-human/assets/ping-human-toast.svg
chmod +x plugins/ping-a-human/skills/ping-a-human/scripts/ping-human
```

## Validation

Run the skill and plugin checks before handing off changes:

```sh
python3 /Users/ibrahimsaidi/.codex/skills/.system/skill-creator/scripts/quick_validate.py plugins/ping-a-human/skills/ping-a-human
python3 -m json.tool plugins/ping-a-human/.codex-plugin/plugin.json >/dev/null
python3 -m json.tool .agents/plugins/marketplace.json >/dev/null
bash -n plugins/ping-a-human/skills/ping-a-human/scripts/ping-human
osacompile -o /tmp/ping-human-plugin-fallback.scpt plugins/ping-a-human/skills/ping-a-human/scripts/ping-human.applescript
rm -f /tmp/ping-human-plugin-fallback.scpt
(cd plugins/ping-a-human/skills/ping-a-human/scripts && swift build)
rm -rf plugins/ping-a-human/skills/ping-a-human/scripts/.build
```

The native toast is a small top-right floating window with custom color, icon treatment, shadow, typography, and a fixed 10-second auto-dismiss. Human ping messages should stay short and non-sensitive; detailed context belongs in the agent session, not the desktop notification.
