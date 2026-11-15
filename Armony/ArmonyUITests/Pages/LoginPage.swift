//
//  LoginPage.swift
//  ArmonyUITests
//

import XCTest

final class LoginPage: Page {

    override var anchor: XCUIElement {
        return staticText(.loginTitleLabel)
    }

    // MARK: - Elements

    private var emailField: XCUIElement { element(.loginEmailTextField) }
    private var passwordField: XCUIElement { element(.loginPasswordTextField) }
    private var signInButton: XCUIElement { button(.loginSignInButton) }

    // MARK: - State

    var isSignInEnabled: Bool {
        return signInButton.isEnabled
    }

    var isDisplayed: Bool {
        return anchor.exists
    }

    var isForgotPasswordVisible: Bool {
        return button(.loginForgotPasswordButton).exists
    }

    var isPasswordMasked: Bool {
        return app.secureTextFields[AccessibilityIdentifier.loginPasswordTextField.rawValue].exists
    }

    var passwordValue: String? {
        return passwordField.value as? String
    }

    // MARK: - Actions

    @discardableResult
    func typeEmail(_ email: String) -> Self {
        enterText(email, into: emailField)
        return self
    }

    @discardableResult
    func typePassword(_ password: String) -> Self {
        enterText(password, into: passwordField)
        return self
    }

    @discardableResult
    func fillCredentials(_ user: TestUser) -> Self {
        return typeEmail(user.email)
            .typePassword(user.password)
            .dismissKeyboard()
    }

    @discardableResult
    func togglePasswordVisibility() -> Self {
        button(.loginPasswordVisibilityButton).tap()
        return self
    }

    /// The screen ends editing when its background is tapped.
    @discardableResult
    func dismissKeyboard() -> Self {
        anchor.tap()
        return self
    }

    // MARK: - Navigation

    /// Taps "Sign In" and waits for the login screen to close, returning to the tab bar underneath.
    func signIn(file: StaticString = #filePath, line: UInt = #line) -> HomePage {
        signInButton.tap()
        waitUntilDismissed(file: file, line: line)
        return HomePage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    /// Taps "Sign In" for credentials the backend rejects: the screen stays and an alert explains why.
    func signInExpectingAlert(file: StaticString = #filePath, line: UInt = #line) -> AlertPage {
        signInButton.tap()
        return AlertPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    func goToSignUp(file: StaticString = #filePath, line: UInt = #line) -> RegistrationPage {
        dismissKeyboard()
        button(.loginGoToSignUpButton).tap()
        return RegistrationPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    func close(file: StaticString = #filePath, line: UInt = #line) -> HomePage {
        button(.dismissButton).tap()
        return HomePage(app: app).waitUntilDisplayed(file: file, line: line)
    }
}
