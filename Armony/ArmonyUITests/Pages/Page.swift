//
//  Page.swift
//  ArmonyUITests
//

import XCTest

/// Page Object base class.
///
/// A page object wraps one screen: it knows how to find the screen's elements and exposes
/// user-level actions and state, so tests read as flows and never touch `XCUIElement` queries.
/// Actions that navigate return the page object of the screen they lead to.
class Page {

    /// Time to wait for a screen or element to appear.
    static let timeout: TimeInterval = 5

    let app: XCUIApplication

    required init(app: XCUIApplication) {
        self.app = app
    }

    /// The element whose presence means the screen is displayed.
    var anchor: XCUIElement {
        fatalError("Subclasses must override `anchor`")
    }

    @discardableResult
    func waitUntilDisplayed(file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertTrue(
            anchor.waitForExistence(timeout: Self.timeout),
            "\(Self.self) is not displayed",
            file: file,
            line: line
        )
        return self
    }

    @discardableResult
    func waitUntilDismissed(file: StaticString = #filePath, line: UInt = #line) -> Self {
        let gone = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gone, object: anchor)
        XCTAssertEqual(
            XCTWaiter().wait(for: [expectation], timeout: Self.timeout),
            .completed,
            "\(Self.self) is still displayed",
            file: file,
            line: line
        )
        return self
    }

    /// Finds an element by identifier regardless of its type. Needed where the type changes at runtime:
    /// a password field is a secure text field while masked and a plain text field once revealed.
    func element(_ identifier: AccessibilityIdentifier) -> XCUIElement {
        return app.descendants(matching: .any)
            .matching(identifier: identifier.rawValue)
            .firstMatch
    }

    func button(_ identifier: AccessibilityIdentifier) -> XCUIElement {
        return app.buttons[identifier.rawValue]
    }

    func staticText(_ identifier: AccessibilityIdentifier) -> XCUIElement {
        return app.staticTexts[identifier.rawValue]
    }

    func enterText(_ text: String, into field: XCUIElement) {
        field.tap()
        field.typeText(text)
    }
}
