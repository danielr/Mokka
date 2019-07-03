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
            .target(name: "Mokka"),
            .testTarget(
                name: "MokkaTests",
                dependencies: ["Mokka"]
            )
        ]
    )
)
