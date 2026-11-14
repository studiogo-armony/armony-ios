//
//  TestKeychainTests.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import XCTest

final class TestKeychainTests: IntegrationTestCase {

    func test_authenticationService_whenAuthenticatedWithTestKeychain_persistsAndClearsTokens() {
        let sut = AuthenticationService(keychain: TestKeychain.make(), notifier: NotificationCenter())

        sut.authenticate(accessToken: "access", refreshToken: "refresh", userID: "42")

        let reloaded = AuthenticationService(keychain: TestKeychain.make(), notifier: NotificationCenter())
        XCTAssertTrue(reloaded.isAuthenticated)
        XCTAssertEqual(reloaded.refreshToken, "refresh")
        XCTAssertEqual(reloaded.userID, "42")

        sut.unauthenticate()

        XCTAssertFalse(reloaded.isAuthenticated)
        XCTAssertTrue(reloaded.userID.isEmpty)
    }
}
