// swift-tools-version: 5.9

import PackageDescription

/// Defines the Swift Package Manager build graph for the native ping toast
/// bundled by the Ping A Human Codex skill.
///
/// The package intentionally exposes a single executable product:
/// `ping-human-toast`. The skill's shell wrapper can call this helper when
/// available, while the AppleScript fallback remains independent of SwiftPM for
/// zero-dependency environments.
let package = Package(
    name: "PingHuman",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ping-human-toast",
            targets: ["PingHumanToast"]
        )
    ],
    targets: [
        .executableTarget(
            name: "PingHumanToast"
        )
    ]
)
