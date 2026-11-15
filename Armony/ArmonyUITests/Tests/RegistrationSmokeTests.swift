//
//  RegistrationSmokeTests.swift
//  ArmonyUITests
//

import XCTest

final class RegistrationSmokeTests: UITestCase {

    func test_accountTab_whenSignedOut_showsRegistration() {
        let registration = launchHome().openAccountTab()

        XCTAssertFalse(registration.isSignUpEnabled)
    }

    func test_placeAdvertTab_whenSignedOut_showsRegistration() {
        let registration = launchHome().openPlaceAdvertTab()

        XCTAssertFalse(registration.isSignUpEnabled)
    }

    func test_signUpButton_withInvalidInput_staysDisabled() {
        let registration = launchHome().openAccountTab()

        registration.fillForm(.invalid)

        XCTAssertFalse(registration.isSignUpEnabled)
    }

    func test_signUpButton_withIncompleteInput_staysDisabled() {
        let registration = launchHome().openAccountTab()

        registration
            .typeName(TestUser.valid.name)
            .typeEmail(TestUser.valid.email)
            .dismissKeyboard()

        XCTAssertFalse(registration.isSignUpEnabled)
    }

    func test_signUpButton_withValidInput_isEnabled() {
        let registration = launchHome().openAccountTab()

        registration.fillForm(.valid)

        XCTAssertTrue(registration.isSignUpEnabled)
    }

    func test_passwordVisibilityButton_revealsAndMasksPassword() {
        let registration = launchHome().openAccountTab()
        registration.typePassword(TestUser.valid.password).dismissKeyboard()
        XCTAssertTrue(registration.isPasswordMasked)

        registration.togglePasswordVisibility()
        XCTAssertFalse(registration.isPasswordMasked)
        XCTAssertEqual(registration.passwordValue, TestUser.valid.password)

        registration.togglePasswordVisibility()
        XCTAssertTrue(registration.isPasswordMasked)
    }

    func test_goToLogin_opensLogin() {
        let login = launchHome().openAccountTab().goToLogin()

        XCTAssertFalse(login.isSignInEnabled)
    }

    func test_dismiss_returnsToHome() {
        launchHome().openAccountTab().close()
    }
}
