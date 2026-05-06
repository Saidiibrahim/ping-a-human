# Ping A Human

Use this script when an agent is blocked and needs to bring a human back to the desktop.

<p>
  <img src="docs/ping-human-toast.svg" alt="Ping A Human toast preview" width="448">
</p>

The preview above is a static SVG companion for the native AppKit toast design.
The source of truth for the rendered toast lives in `Sources/PingHumanToast/main.swift`.

## Recommended usage

Build the native toast helper once:

```sh
swift build
```

Then call the wrapper:

```sh
./ping-human
```

This uses the default message:

```text
An agent is paused and needs a human before continuing.
```

Agents can pass one short custom message:

```sh
./ping-human "Review database cutover?"
```

Messages are capped at 90 characters and longer text is shortened automatically.

The wrapper uses the polished Swift toast when `.build/debug/ping-human-toast` exists. If the helper has not been built, it falls back to the zero-dependency AppleScript notification.

## AppleScript fallback

```sh
osascript ping-human.applescript
```

With a custom message:

```sh
osascript ping-human.applescript "Review database cutover?"
```

The script sends a short-lived macOS notification and exits immediately.

## Native toast options

```sh
.build/debug/ping-human-toast \
  --title "Ping A Human" \
  --subtitle "Agent is waiting" \
  "Review database cutover?"
```

The native toast is a small top-right floating window with custom color, icon treatment, shadow, typography, and a fixed 10-second auto-dismiss.
