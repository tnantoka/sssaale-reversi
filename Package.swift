import PackageDescription

let package = Package(
    name: "sssaale-reversi",
    targets: [
        Target(name: "App", dependencies: ["AppLogic"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/ysnrkdm/Graphene", majorVersion: 2, minor: 4),
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)


