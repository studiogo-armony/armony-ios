//
//  IntegrationFixtures.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import Foundation

/// Loads JSON fixtures that live anywhere under `ArmonyIntegrationTests/`.
/// The folder is synchronized with the target, so new `.json` files are bundled automatically.
enum IntegrationFixtures {

    private final class BundleToken { }

    static func data(named name: String,
                     file: StaticString = #file,
                     line: UInt = #line) -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            preconditionFailure("Missing fixture \(name).json in ArmonyIntegrationTests bundle", file: file, line: line)
        }
        return data
    }
}
