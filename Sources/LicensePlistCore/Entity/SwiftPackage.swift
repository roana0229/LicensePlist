//
//  SwiftPackage.swift
//  LicensePlistCore
//
//  Created by Matthias Buchetics on 20.09.19.
//

import Foundation

public struct SwiftPackage: Decodable, Equatable {
    struct State: Decodable, Equatable {
        let branch: String?
        let revision: String?
        let version: String
    }

    let package: String
    let repositoryURL: String
    let state: State
}

private struct ResolvedPackages: Decodable {
    struct Pins: Decodable {
        let pins: [SwiftPackage]
    }

    let object: Pins
    let version: Int
}

extension SwiftPackage {

    static func loadPackages(_ content: String) -> [SwiftPackage] {
        guard let data = content.data(using: .utf8) else { return [] }
        guard let resolvedPackages = try? JSONDecoder().decode(ResolvedPackages.self, from: data) else { return [] }

        return resolvedPackages.object.pins
    }

    func toGitHub(renames: [String: String]) -> GitHub? {
        guard repositoryURL.contains("github.com") else { return nil }

        let urlParts = repositoryURL
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .components(separatedBy: "/")

        guard urlParts.count >= 3 else { return nil }

        let name = urlParts.last?.components(separatedBy: ".").first ?? ""
        let owner = urlParts[urlParts.count - 2]

        return GitHub(name: name,
                      nameSpecified: renames[name],
                      owner: owner,
                      version: state.version)
    }
}
