//
//  LoginFlowTests.swift
//  ArmonyUITests
//

import XCTest

/// Completes the login flow against stubbed backend responses.
final class LoginFlowTests: UITestCase {

    func test_signIn_withValidCredentials_closesLoginAndOpensAccount() {
        stub(.signInSuccess())
        stub(contentsOf: UITestStub.signedInUser())
        let login = launchHome().openAccountTab().goToLogin()

        let home = login.fillCredentials(.valid).signIn()

        home.waitUntilSelected(.account)
        XCTAssertFalse(login.isDisplayed)
        let request = waitForRequest("POST", "/auth/signin")
        XCTAssertEqual(request.json["email"] as? String, TestUser.valid.email)
        XCTAssertEqual(request.json["password"] as? String, TestUser.valid.password)
    }

    /// The completion handed to login depends on where the user came from.
    func test_signIn_whenStartedFromPlaceAdvertTab_opensPlaceAdvert() {
        stub(.signInSuccess())
        stub(contentsOf: UITestStub.signedInUser())
        let login = launchHome().openPlaceAdvertTab().goToLogin()

        let home = login.fillCredentials(.valid).signIn()

        home.waitUntilSelected(.placeAdvert)
        XCTAssertFalse(login.isDisplayed)
    }

    func test_signIn_withWrongPassword_showsErrorAndStaysOnLogin() {
        stub(.signInFailure(.invalidPassword))
        let login = launchHome().openAccountTab().goToLogin()

        let alert = login.fillCredentials(.valid).signInExpectingAlert()

        XCTAssertTrue(alert.hasMessage(UITestStub.AuthError.invalidPassword.message))
        alert.dismiss()
        XCTAssertTrue(login.isDisplayed)
    }

    func test_signIn_withUnknownEmail_showsErrorAndStaysOnLogin() {
        stub(.signInFailure(.emailNotFound))
        let login = launchHome().openAccountTab().goToLogin()

        let alert = login.fillCredentials(.valid).signInExpectingAlert()

        XCTAssertTrue(alert.hasMessage(UITestStub.AuthError.emailNotFound.message))
        alert.dismiss()
        XCTAssertTrue(login.isDisplayed)
    }
}
