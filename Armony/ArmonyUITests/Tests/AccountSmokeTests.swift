//
//  AccountSmokeTests.swift
//  ArmonyUITests
//

import XCTest

/// Starts with a session instead of signing in through the UI.
final class AccountSmokeTests: UITestCase {

    func test_accountTab_whenSignedIn_showsAccountAndLoadsUser() {
        stub(.userDetail())

        launchHome(signedIn: true).openAccountTabSignedIn()

        waitForRequest("GET", "/users/\(UITestSession.userID)")
    }
}
