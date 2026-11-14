//
//  TestDefaults.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import Foundation

/// `Defaults` backed by a dedicated suite, so integration tests never touch the app's own settings.
enum TestDefaults {

    static let suiteName = "com.armony.integration-tests"

    static func make() -> Defaults {
        return Defaults(defaults: UserDefaults(suiteName: suiteName)!)
    }

    static func clear() {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }
}
