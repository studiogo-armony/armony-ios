//
//  RegistrationPage.swift
//  ArmonyUITests
//

import XCTest

final class RegistrationPage: Page {

    override var anchor: XCUIElement {
        return staticText(.registrationTitleLabel)
    }

    // MARK: - Elements

    private var nameField: XCUIElement { element(.registrationNameTextField) }
    private var emailField: XCUIElement { element(.registrationEmailTextField) }
    private var passwordField: XCUIElement { element(.registrationPasswordTextField) }
    private var signUpButton: XCUIElement { button(.registrationSignUpButton) }

    // MARK: - State

    var isSignUpEnabled: Bool {
        return signUpButton.isEnabled
    }

    var isDisplayed: Bool {
        return anchor.exists
    }

    var isPasswordMasked: Bool {
        return app.secureTextFields[AccessibilityIdentifier.registrationPasswordTextField.rawValue].exists
    }

    var passwordValue: String? {
        return passwordField.value as? String
    }

    // MARK: - Actions

    @discardableResult
    func typeName(_ name: String) -> Self {
        enterText(name, into: nameField)
        return self
    }

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
    func fillForm(_ user: TestUser) -> Self {
        return typeName(user.name)
            .typeEmail(user.email)
            .typePassword(user.password)
            .dismissKeyboard()
    }

    @discardableResult
    func togglePasswordVisibility() -> Self {
        button(.registrationPasswordVisibilityButton).tap()
        return self
    }

    /// The screen ends editing when its background is tapped.
    @discardableResult
    func dismissKeyboard() -> Self {
        anchor.tap()
        return self
    }

    // MARK: - Navigation

    /// Taps "Sign Up" and waits for the registration screen to close, returning to the tab bar underneath.
    func signUp(file: StaticString = #filePath, line: UInt = #line) -> HomePage {
        signUpButton.tap()
        waitUntilDismissed(file: file, line: line)
        return HomePage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    /// Taps "Sign Up" for input the backend rejects: the screen stays and an alert explains why.
    func signUpExpectingAlert(file: StaticString = #filePath, line: UInt = #line) -> AlertPage {
        signUpButton.tap()
        return AlertPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    func goToLogin(file: StaticString = #filePath, line: UInt = #line) -> LoginPage {
        dismissKeyboard()
        button(.registrationGoToLoginButton).tap()
        return LoginPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    func close(file: StaticString = #filePath, line: UInt = #line) -> HomePage {
        button(.dismissButton).tap()
        return HomePage(app: app).waitUntilDisplayed(file: file, line: line)
    }
}
