// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Mokka",
    products: [
        .library(
            name: "Mokka",
            targets: ["Mokka"]),
    ],
    targets: [
        .target(
            name: "Mokka",
            path: "Mokka/Sources"
        ),
        .testTarget(
            name: "MokkaTests",
            path: "Mokka/Tests",
            dependencies: ["Mokka"]
        )
    ]
)
