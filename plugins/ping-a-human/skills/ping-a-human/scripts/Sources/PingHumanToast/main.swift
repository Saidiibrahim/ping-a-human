import AppKit

/// User-visible configuration for one human ping toast.
///
/// The helper keeps this deliberately small: a short message, fixed title,
/// fixed subtitle, and fixed display duration. Agents can customize the message
/// for the human ping they need, but the UI remains predictable and compact.
private struct ToastOptions {
    /// Maximum number of characters shown in the toast message.
    ///
    /// Longer text is shortened with an ellipsis. The prompt is meant to be an
    /// attention signal; detailed context should stay in the agent session.
    static let maximumMessageLength = 90

    /// Body text shown under the title and subtitle.
    var message = "An agent is paused and needs a human before continuing."

    /// Primary heading for the toast.
    var title = "Ping A Human"

    /// Secondary context line, rendered in uppercase.
    var subtitle = "Agent is waiting"

    /// Fixed auto-dismiss duration in seconds.
    var duration: TimeInterval = 10
}

/// Custom AppKit view that draws the human ping toast.
///
/// This avoids Notification Center styling limits and gives the helper direct
/// control over the card shape, colors, icon, typography, and message layout.
private final class ToastView: NSView {
    private let options: ToastOptions

    /// Creates a fixed-size toast view using the supplied display options.
    init(options: ToastOptions) {
        self.options = options
        super.init(frame: NSRect(x: 0, y: 0, width: 448, height: 132))
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        nil
    }

    /// Draws the toast card background, icon, and text.
    ///
    /// The view is fully custom-drawn so the helper can stay dependency-free
    /// and does not need image assets or a bundled app resource folder.
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Leave two pixels for antialiasing and the window shadow so the card
        // edge remains crisp inside a borderless transparent window.
        let bounds = bounds.insetBy(dx: 2, dy: 2)
        let cardPath = NSBezierPath(roundedRect: bounds, xRadius: 14, yRadius: 14)

        // Clip all background paint to the rounded card. This lets the ocean
        // wash reach the edges without bleeding into the transparent window.
        NSGraphicsContext.saveGraphicsState()
        cardPath.addClip()
        drawOceanBackground(in: bounds)
        NSGraphicsContext.restoreGraphicsState()

        // A light border keeps the pale card readable on bright desktops,
        // while the shadow from NSWindow handles separation on dark desktops.
        NSColor(calibratedWhite: 1, alpha: 0.68).setStroke()
        cardPath.lineWidth = 1
        cardPath.stroke()

        drawIcon(in: NSRect(x: 28, y: bounds.midY - 25, width: 50, height: 50))
        drawText()
    }

    /// Paints the full ocean-blue and white Codex-inspired surface.
    private func drawOceanBackground(in bounds: NSRect) {
        // Start with a blue-to-white sweep like the Codex hero background:
        // saturated water color on the left, airy white through the content
        // area, and a controlled blue edge on the far right.
        let baseGradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.31, green: 0.37, blue: 1.0, alpha: 1.0),
            NSColor(calibratedRed: 0.55, green: 0.72, blue: 1.0, alpha: 1.0),
            NSColor(calibratedRed: 0.94, green: 0.98, blue: 1.0, alpha: 1.0),
            NSColor(calibratedRed: 0.28, green: 0.54, blue: 0.96, alpha: 1.0)
        ])
        baseGradient?.draw(in: bounds, angle: 16)

        // Add a dark lower wash so the card still nods to the black Codex app
        // UI in the screenshots without turning the whole toast back into a
        // dark notification.
        let bottomFade = NSGradient(colors: [
            NSColor(calibratedRed: 0.02, green: 0.03, blue: 0.06, alpha: 0.0),
            NSColor(calibratedRed: 0.02, green: 0.03, blue: 0.08, alpha: 0.22)
        ])
        bottomFade?.draw(in: bounds, angle: -90)
    }

    /// Draws a small Codex-inspired ping glyph without using official assets.
    private func drawIcon(in rect: NSRect) {
        // The white tile mirrors the Codex app icon treatment from the hero,
        // while the inner mark remains custom instead of using official assets.
        let tile = NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12)
        NSColor(calibratedWhite: 1, alpha: 0.92).setFill()
        tile.fill()

        NSColor(calibratedWhite: 1, alpha: 0.88).setStroke()
        tile.lineWidth = 1
        tile.stroke()

        let inner = rect.insetBy(dx: 10, dy: 10)
        drawAppMark(in: inner)
        drawPromptMark(in: NSRect(x: rect.minX + 16, y: rect.minY + 12, width: 18, height: 8))
    }

    /// Draws a soft blue app mark inside the white tile.
    private func drawAppMark(in rect: NSRect) {
        // This abstract pill-stack shape is intentionally close in mood to the
        // Codex icon's blue app mark, but it avoids tracing the real logo.
        let mark = NSBezierPath()
        mark.move(to: NSPoint(x: rect.minX + 10, y: rect.minY + 3))
        mark.curve(
            to: NSPoint(x: rect.maxX - 3, y: rect.minY + 10),
            controlPoint1: NSPoint(x: rect.minX + 16, y: rect.minY - 1),
            controlPoint2: NSPoint(x: rect.maxX - 4, y: rect.minY + 1)
        )
        mark.curve(
            to: NSPoint(x: rect.maxX - 8, y: rect.maxY - 3),
            controlPoint1: NSPoint(x: rect.maxX + 1, y: rect.minY + 18),
            controlPoint2: NSPoint(x: rect.maxX - 1, y: rect.maxY - 2)
        )
        mark.curve(
            to: NSPoint(x: rect.minX + 4, y: rect.maxY - 8),
            controlPoint1: NSPoint(x: rect.maxX - 15, y: rect.maxY + 2),
            controlPoint2: NSPoint(x: rect.minX + 3, y: rect.maxY)
        )
        mark.curve(
            to: NSPoint(x: rect.minX + 10, y: rect.minY + 3),
            controlPoint1: NSPoint(x: rect.minX - 1, y: rect.maxY - 15),
            controlPoint2: NSPoint(x: rect.minX + 1, y: rect.minY + 8)
        )
        mark.close()

        let gradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.58, green: 0.76, blue: 1.0, alpha: 1),
            NSColor(calibratedRed: 0.23, green: 0.37, blue: 0.96, alpha: 1)
        ])
        gradient?.draw(in: mark, angle: 45)
    }

    /// Adds a tiny command-line cue at the bottom of the icon tile.
    private func drawPromptMark(in rect: NSRect) {
        // A minimal prompt mark connects the toast to terminal-driven Codex
        // workflows without adding extra text or requiring an icon asset.
        let promptPath = NSBezierPath()
        promptPath.move(to: NSPoint(x: rect.minX, y: rect.maxY))
        promptPath.line(to: NSPoint(x: rect.minX + 4, y: rect.midY))
        promptPath.line(to: NSPoint(x: rect.minX, y: rect.minY))

        NSColor(calibratedWhite: 1, alpha: 0.9).setStroke()
        promptPath.lineWidth = 1.4
        promptPath.lineCapStyle = .round
        promptPath.lineJoinStyle = .round
        promptPath.stroke()

        let linePath = NSBezierPath()
        linePath.move(to: NSPoint(x: rect.minX + 8, y: rect.minY))
        linePath.line(to: NSPoint(x: rect.maxX, y: rect.minY))
        linePath.lineWidth = 1.4
        linePath.lineCapStyle = .round
        linePath.stroke()
    }

    /// Draws title, subtitle, and message text into stable regions.
    ///
    /// Fixed text rectangles prevent layout shifts and keep long custom
    /// messages from resizing the toast. The message is also shortened before
    /// it reaches this view.
    private func drawText() {
        // Text rectangles are hand-positioned to keep the toast stable and
        // compact; dynamic layout is unnecessary for this fixed notification.
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: NSColor.black
        ]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor(calibratedWhite: 0.04, alpha: 0.82)
        ]
        let messageStyle = NSMutableParagraphStyle()
        messageStyle.lineBreakMode = .byTruncatingTail
        messageStyle.maximumLineHeight = 18

        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: NSColor.black,
            .paragraphStyle: messageStyle
        ]

        NSString(string: options.title).draw(
            in: NSRect(x: 96, y: 86, width: 318, height: 22),
            withAttributes: titleAttributes
        )
        NSString(string: options.subtitle.uppercased()).draw(
            in: NSRect(x: 96, y: 66, width: 318, height: 16),
            withAttributes: subtitleAttributes
        )
        NSString(string: options.message).draw(
            in: NSRect(x: 96, y: 27, width: 318, height: 36),
            withAttributes: messageAttributes
        )
    }
}

/// Owns the native floating window lifecycle.
///
/// The controller creates a borderless top-right window, fades it in, waits for
/// the fixed duration, fades it out, and then terminates the helper process.
private final class ToastController: NSObject, NSApplicationDelegate {
    private let options: ToastOptions
    private var window: NSWindow?

    /// Stores the toast options used to render the window.
    init(options: ToastOptions) {
        self.options = options
    }

    /// Creates and displays the human ping toast.
    ///
    /// The app uses accessory activation policy so it does not appear in the
    /// Dock. The window level and collection behavior keep the toast visible
    /// across spaces and fullscreen contexts where possible.
    func show() {
        NSApp.setActivationPolicy(.accessory)

        let size = NSSize(width: 448, height: 132)
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

        // Position inside the visible frame so the toast avoids the menu bar
        // and Dock while remaining visually close to Notification Center.
        let origin = NSPoint(
            x: screenFrame.maxX - size.width - 24,
            y: screenFrame.maxY - size.height - 24
        )

        let toastWindow = NSWindow(
            contentRect: NSRect(origin: origin, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        toastWindow.isOpaque = false
        toastWindow.backgroundColor = .clear
        toastWindow.hasShadow = true
        toastWindow.level = .floating
        toastWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        toastWindow.contentView = ToastView(options: options)
        toastWindow.alphaValue = 0
        toastWindow.orderFrontRegardless()

        window = toastWindow

        // Fast fade-in makes the helper feel lightweight without being abrupt.
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.16
            toastWindow.animator().alphaValue = 1
        }

        Timer.scheduledTimer(withTimeInterval: options.duration, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }

    /// Fades out the toast and exits the process.
    ///
    /// Terminating after dismissal keeps command-line callers simple: running
    /// the helper blocks only for the visible lifetime of the toast.
    private func dismiss() {
        guard let window else {
            NSApp.terminate(nil)
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            window.animator().alphaValue = 0
        } completionHandler: {
            NSApp.terminate(nil)
        }
    }
}

/// Parses command-line arguments into toast options.
///
/// Supported flags are intentionally narrow:
/// - `--title <value>`
/// - `--subtitle <value>`
///
/// All other arguments are joined into the message. Duration is fixed in
/// `ToastOptions` so agents cannot accidentally create sticky or too-brief
/// human ping prompts.
private func parseOptions(from arguments: [String]) -> ToastOptions {
    var options = ToastOptions()
    var index = 0
    var messageParts: [String] = []

    while index < arguments.count {
        let argument = arguments[index]

        switch argument {
        case "--title":
            if index + 1 < arguments.count {
                options.title = arguments[index + 1]
                index += 1
            }
        case "--subtitle":
            if index + 1 < arguments.count {
                options.subtitle = arguments[index + 1]
                index += 1
            }
        default:
            messageParts.append(argument)
        }

        index += 1
    }

    if !messageParts.isEmpty {
        options.message = shortenedMessage(messageParts.joined(separator: " "))
    }

    return options
}

/// Returns a display-safe message that fits the toast.
///
/// The limit is based on character count rather than rendered width because it
/// is simple, deterministic, and shared with the shell wrapper. The drawing
/// layer still truncates as a final guard against unusually wide glyphs.
private func shortenedMessage(_ message: String) -> String {
    if message.count <= ToastOptions.maximumMessageLength {
        return message
    }

    return String(message.prefix(ToastOptions.maximumMessageLength)) + "..."
}

/// Process entrypoint.
///
/// AppKit command-line helpers need an application object and run loop for
/// windows, timers, and animations to work. The controller terminates the app
/// after the fixed auto-dismiss duration.
private let options = parseOptions(from: Array(CommandLine.arguments.dropFirst()))
private let app = NSApplication.shared
private let controller = ToastController(options: options)

app.delegate = controller
controller.show()
app.run()
