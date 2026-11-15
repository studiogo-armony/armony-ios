//
//  AlertPage.swift
//  ArmonyUITests
//

import XCTest

/// An alert the app presents, e.g. for a failed request.
final class AlertPage: Page {

    override var anchor: XCUIElement {
        return app.alerts.firstMatch
    }

    func hasMessage(_ message: String) -> Bool {
        return anchor.staticTexts[message].exists
    }

    func dismiss() {
        anchor.buttons.firstMatch.tap()
    }
}
