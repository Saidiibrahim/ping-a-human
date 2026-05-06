-- ping-human.applescript
--
-- Zero-dependency fallback for human ping prompts.
--
-- This script intentionally uses macOS Notification Center instead of a modal
-- dialog. It should get the human's attention and exit immediately, leaving the
-- agent session free to continue polling, waiting, or logging its blocked state.
use scripting additions

on run argv
	-- Default message used when an agent only needs a generic human ping.
	set pingMessage to "An agent is paused and needs a human before continuing."
	
	-- Treat the first argument as the full custom message. The wrapper already
	-- caps message length before invoking this fallback.
	if (count of argv) > 0 then set pingMessage to item 1 of argv
	
	-- AppleScript notifications support title, subtitle, body, and optional
	-- sound only. Color, icon, and layout are owned by macOS Notification Center.
	display notification pingMessage with title "Ping A Human" subtitle "Agent is waiting"
end run
