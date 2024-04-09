// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "mParticle-BranchMetrics",
    platforms: [ .iOS(.v12) ],
    products: [
        .library(
            name: "mParticle-BranchMetrics",
            targets: ["mParticle-BranchMetrics"]),
        .library(
            name: "mParticle-BranchMetrics-NoLocation",
            targets: ["mParticle-BranchMetrics-NoLocation"]
        )
    ],
    dependencies: [
      .package(name: "mParticle-Apple-SDK",
               url: "https://github.com/mParticle/mparticle-apple-sdk",
               .upToNextMajor(from: "8.9.0")),
      .package(name: "BranchSDK",
               url: "https://github.com/BranchMetrics/ios-branch-sdk-spm",
               .upToNextMajor(from: "3.4.1")),
    ],
    targets: [
        .target(
            name: "mParticle-BranchMetrics",
            dependencies: [
                .product(name: "mParticle-Apple-SDK", package: "mParticle-Apple-SDK"),
                .product(name: "BranchSDK", package: "BranchSDK"),
            ],
            path: "mParticle-BranchMetrics",
            publicHeadersPath: "."
        ),
        .target(
            name: "mParticle-BranchMetrics-NoLocation",
            dependencies: [
                .product(name: "mParticle-Apple-SDK-NoLocation", package: "mParticle-Apple-SDK"),
                .product(name: "BranchSDK", package: "BranchSDK"),
            ],
            path: "SPM/mParticle-BranchMetrics-NoLocation",
            publicHeadersPath: "."
        )
    ]
)
