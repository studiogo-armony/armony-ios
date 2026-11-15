//
//  LoginSmokeTests.swift
//  ArmonyUITests
//

import XCTest

/// Signed-out users reach login from the registration screen ("Already have an account?").
/// Only the first test walks that path; the others start on login directly.
final class LoginSmokeTests: UITestCase {

    func test_login_isReachableFromRegistration() {
        let login = launchHome().openAccountTab().goToLogin()

        XCTAssertFalse(login.isSignInEnabled)
        XCTAssertTrue(login.isForgotPasswordVisible)
    }

    func test_signInButton_withInvalidInput_staysDisabled() {
        let login = launchLogin()

        login.fillCredentials(.invalid)

        XCTAssertFalse(login.isSignInEnabled)
    }

    func test_signInButton_withOnlyEmail_staysDisabled() {
        let login = launchLogin()

        login.typeEmail(TestUser.valid.email).dismissKeyboard()

        XCTAssertFalse(login.isSignInEnabled)
    }

    func test_signInButton_withValidInput_isEnabled() {
        let login = launchLogin()

        login.fillCredentials(.valid)

        XCTAssertTrue(login.isSignInEnabled)
    }

    func test_passwordVisibilityButton_revealsAndMasksPassword() {
        let login = launchLogin()
        login.typePassword(TestUser.valid.password).dismissKeyboard()
        XCTAssertTrue(login.isPasswordMasked)

        login.togglePasswordVisibility()
        XCTAssertFalse(login.isPasswordMasked)
        XCTAssertEqual(login.passwordValue, TestUser.valid.password)

        login.togglePasswordVisibility()
        XCTAssertTrue(login.isPasswordMasked)
    }

    func test_goToSignUp_opensRegistration() {
        let registration = launchLogin().goToSignUp()

        XCTAssertFalse(registration.isSignUpEnabled)
    }

    func test_dismiss_returnsToHome() {
        launchLogin().close()
    }
}
