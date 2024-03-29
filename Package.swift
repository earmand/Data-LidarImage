// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data+LidarImage",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Data+LidarImage",
            targets: ["Data+LidarImage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/earmand/DEFoundation.git", from: "1.0.0"),
        .package(url: "https://github.com/earmand/DEColor.git", from: "1.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Data+LidarImage",
            dependencies: ["DEColor",
                           "DEFoundation"]
        ),
        
        
        .testTarget(
            name: "Data+LidarImageTests",
            dependencies: ["Data+LidarImage",
                           "DEColor",
                           "DEFoundation"
                          ]
        ),
    ]
)
