// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "mParticle-BranchMetrics",
    platforms: [ .iOS(.v9) ],
    products: [
        .library(
            name: "mParticle-BranchMetrics",
            targets: ["mParticle-BranchMetrics"]),
    ],
    dependencies: [
      .package(name: "mParticle-Apple-SDK",
               url: "https://github.com/mParticle/mparticle-apple-sdk",
               .upToNextMajor(from: "8.2.0")),
      .package(name: "Branch",
               url: "https://github.com/BranchMetrics/ios-branch-sdk-spm",
               .upToNextMajor(from: "1.39.1")),
    ],
    targets: [
        .target(
            name: "mParticle-BranchMetrics",
            dependencies: ["mParticle-Apple-SDK","Branch"],
            path: "mParticle-BranchMetrics",
            publicHeadersPath: "."),
    ]
)
