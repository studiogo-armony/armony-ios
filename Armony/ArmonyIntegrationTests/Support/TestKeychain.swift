//
//  TestKeychain.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import KeychainAccess

/// Real keychain under a dedicated service, so integration tests never touch the app's own tokens.
enum TestKeychain {

    static let service = "com.armony.integration-tests"

    static func make() -> Keychain {
        return Keychain(service: service)
    }

    static func clear() {
        try? make().removeAll()
    }
}
