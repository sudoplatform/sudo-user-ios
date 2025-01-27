// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SudoUser",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SudoUser",
            targets: ["SudoUser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sudoplatform/sudo-logging-ios", from: "2.0.0"),
        .package(url: "https://github.com/sudoplatform/sudo-key-manager-ios", from: "4.0.0"),
        .package(url: "https://github.com/sudoplatform/sudo-config-manager-ios", from: "4.0.0"),
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm", exact: "2.36.7"),
        .package(url: "https://github.com/sudoplatform/aws-mobile-appsync-sdk-ios.git", exact: "3.7.2"),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: "4.0.8")
    ],
    targets: [
        .target(
            name: "SudoUser",
            dependencies: [
                .product(name: "AWSCognitoIdentityProvider", package: "aws-sdk-ios-spm"),
                .product(name: "AWSAppSync", package: "aws-mobile-appsync-sdk-ios"),
                .product(name: "AWSCore", package: "aws-sdk-ios-spm"),
                .product(name: "AWSMobileClientXCF", package: "aws-sdk-ios-spm"),
                .product(name: "AWSS3", package: "aws-sdk-ios-spm"),
                .product(name: "Starscream", package: "starscream"),
                .product(name: "SudoLogging", package: "sudo-logging-ios"),
                .product(name: "SudoConfigManager", package: "sudo-config-manager-ios"),
                .product(name: "SudoKeyManager", package: "sudo-key-manager-ios")
            ],
            path: "SudoUser"
        )
    ]
)

