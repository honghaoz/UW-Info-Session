import PackageDescription

let package = Package(
    name: "uw-info",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/honghaoz/Ji.git", majorVersion: 2),
        .Package(url: "https://github.com/malcommac/SwiftDate.git", majorVersion: 4, minor: 0),
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

