// swift-tools-version: 6.0
// This Package.swift is for reference/CI only.
// The primary build method is via the Xcode project (Crate.xcodeproj),
// which must be created in Xcode to configure MusicKit entitlements,
// code signing, and the app target properly.
//
// To set up the Xcode project:
// 1. Open Xcode → File → New → Project → App
// 2. Product Name: Crate, Bundle ID: com.yourname.crate
// 3. Interface: SwiftUI, Language: Swift
// 4. Deployment target: iOS 17.0, Swift Language Version: 6
// 5. Add Capability: MusicKit
// 6. Drag the Crate/ folder into the project navigator
// 7. Add CrateTests/ and CrateUITests/ as test targets
// 8. Set Info.plist and Entitlements file paths in Build Settings

import PackageDescription

let package = Package(
    name: "Crate",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CrateLib", targets: ["CrateLib"])
    ],
    targets: [
        .target(
            name: "CrateLib",
            path: "Crate",
            exclude: ["Resources/Info.plist", "Resources/Crate.entitlements"],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "CrateTests",
            dependencies: ["CrateLib"],
            path: "CrateTests"
        )
    ]
)
