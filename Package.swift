// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NuDefndr",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "NuDefndr",
            targets: ["NuDefndr"]
        )
    ],
    targets: [
        .target(
            name: "NuDefndr",
            dependencies: [],
            path: ".",
            exclude: [
                "Docs",
                "Tests",
                ".github",
                "Assets",
                "README_NEW.swift",
                "README_WITH_IMAGES.md",
                "SETUP_GITHUB.md",
                "fix.txt",
                "SECURITY_ARCHITECTURE_SECTION.txt"
            ],
            sources: [
                "Security",
                "Vault",
                "PanicMode",
                "CryptoValidation.swift",
                "ScanRangeOption.swift"
            ]
        ),
        .testTarget(
            name: "NuDefndrTests",
            dependencies: ["NuDefndr"],
            path: "Tests"
        )
    ]
)