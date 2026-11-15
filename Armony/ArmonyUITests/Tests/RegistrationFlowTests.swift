//
//  RegistrationFlowTests.swift
//  ArmonyUITests
//

import XCTest

/// Completes the registration flow against stubbed backend responses.
final class RegistrationFlowTests: UITestCase {

    func test_signUp_withValidInput_closesRegistrationAndOpensAccount() {
        stub(.signUpSuccess())
        stub(contentsOf: UITestStub.signedInUser())
        let registration = launchHome().openAccountTab()

        let home = registration.fillForm(.valid).signUp()

        home.waitUntilSelected(.account)
        XCTAssertFalse(registration.isDisplayed)
        let request = waitForRequest("POST", "/auth/signup")
        XCTAssertEqual(request.json["name"] as? String, TestUser.valid.name)
        XCTAssertEqual(request.json["email"] as? String, TestUser.valid.email)
        XCTAssertEqual(request.json["password"] as? String, TestUser.valid.password)
    }

    /// The completion handed to registration depends on where the user came from.
    func test_signUp_whenStartedFromPlaceAdvertTab_opensPlaceAdvert() {
        stub(.signUpSuccess())
        stub(contentsOf: UITestStub.signedInUser())
        let registration = launchHome().openPlaceAdvertTab()

        let home = registration.fillForm(.valid).signUp()

        home.waitUntilSelected(.placeAdvert)
        XCTAssertFalse(registration.isDisplayed)
    }

    func test_signUp_withRegisteredEmail_showsErrorAndStaysOnRegistration() {
        stub(.signUpFailure(.emailExist))
        let registration = launchHome().openAccountTab()

        let alert = registration.fillForm(.valid).signUpExpectingAlert()

        XCTAssertTrue(alert.hasMessage(UITestStub.AuthError.emailExist.message))
        alert.dismiss()
        XCTAssertTrue(registration.isDisplayed)
    }
}
