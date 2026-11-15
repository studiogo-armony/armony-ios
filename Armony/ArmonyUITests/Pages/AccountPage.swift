//
//  AccountPage.swift
//  ArmonyUITests
//

import XCTest

/// The account tab of a signed in user.
final class AccountPage: Page {

    override var anchor: XCUIElement {
        return button(.accountEditButton)
    }
}
