// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BrowserTerminal",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "BrowserTerminal",
            targets: ["BrowserTerminal"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "BrowserTerminal",
            dependencies: [
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ]
        )
    ]
)
