//
//  HomePage.swift
//  ArmonyUITests
//

import XCTest

/// The tab bar shell the app starts on.
final class HomePage: Page {

    enum Tab: Int {
        case home
        case placeAdvert
        case account
    }

    override var anchor: XCUIElement {
        return app.tabBars.firstMatch
    }

    // MARK: - State

    func isSelected(_ tab: Tab) -> Bool {
        return tabButton(tab).isSelected
    }

    @discardableResult
    func waitUntilSelected(_ tab: Tab, file: StaticString = #filePath, line: UInt = #line) -> Self {
        let selected = NSPredicate(format: "isSelected == true")
        let expectation = XCTNSPredicateExpectation(predicate: selected, object: tabButton(tab))
        XCTAssertEqual(
            XCTWaiter().wait(for: [expectation], timeout: Self.timeout),
            .completed,
            "\(tab) tab is not selected",
            file: file,
            line: line
        )
        return self
    }

    // MARK: - Navigation

    /// Signed-out users are sent to registration when they open the account tab.
    func openAccountTab(file: StaticString = #filePath, line: UInt = #line) -> RegistrationPage {
        selectTab(.account)
        return RegistrationPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    /// Signed-in users see their account.
    func openAccountTabSignedIn(file: StaticString = #filePath, line: UInt = #line) -> AccountPage {
        selectTab(.account)
        return AccountPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    /// Signed-out users are sent to registration when they open the place advert tab.
    func openPlaceAdvertTab(file: StaticString = #filePath, line: UInt = #line) -> RegistrationPage {
        selectTab(.placeAdvert)
        return RegistrationPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    private func tabButton(_ tab: Tab) -> XCUIElement {
        return app.tabBars.buttons.element(boundBy: tab.rawValue)
    }

    private func selectTab(_ tab: Tab) {
        tabButton(tab).tap()
    }
}
