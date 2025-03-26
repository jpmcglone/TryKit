// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TryKit",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "TryKit",
      targets: ["TryKit"]
    ),
  ],
  targets: [
    .target(
      name: "TryKit"
    ),
    .testTarget(
      name: "TryKitTests",
      dependencies: ["TryKit"]
    ),
  ]
)
