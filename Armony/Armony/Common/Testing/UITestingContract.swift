//
//  UITestingContract.swift
//  Armony
//

import UIKit

// This file is compiled into both the app and the `ArmonyUITests` target,
// so identifiers and launch arguments are never duplicated as strings.

/// Launch arguments the UI tests pass to the app.
enum UITestLaunchArgument {
    /// Starts the app hermetically (see `UITestLaunchConfiguration`).
    static let enabled = "-UITesting"
    /// Starts the app with a signed in session (`UITestSession`) instead of signed out.
    static let signedIn = "-UITestSignedIn"
}

/// The session `UITestLaunchArgument.signedIn` starts with. The auth fixtures use the same values.
enum UITestSession {
    static let userID = "ui-test-user"
    static let accessToken = "ui-test-access"
    static let refreshToken = "ui-test-refresh"
}

/// Launch environment keys the UI tests pass to the app.
enum UITestLaunchEnvironment {
    /// Path of a file holding the JSON encoded `[UITestStub]` the app answers its network requests with.
    /// A file, not the value itself: the environment is size limited, fixtures are not.
    static let stubsFile = "UI_TEST_STUBS_FILE"
    /// Path of a file the app appends every network request to, one JSON encoded `UITestRecordedRequest` per line.
    static let requestLogFile = "UI_TEST_REQUEST_LOG_FILE"
    /// Deeplink path (e.g. `/settings`) the app opens right after starting. Opening a deeplink that requires
    /// authentication while signed out presents login directly.
    static let deeplink = "UI_TEST_DEEPLINK"
}

/// A canned HTTP response. In UI test mode the app answers a request with the first stub whose
/// method matches and whose `path` is a suffix of the request path; any other request fails.
struct UITestStub: Codable {
    let method: String
    let path: String
    let statusCode: Int
    /// Raw JSON text of the response body.
    let body: String
}

/// A network request the app made, as the UI tests read it back from `UITestLaunchEnvironment.requestLogFile`.
struct UITestRecordedRequest: Codable {
    let method: String
    let path: String
    /// Request body as text, if the request had one.
    let body: String?
    /// Whether a stub answered the request. An unstubbed request failed.
    let isStubbed: Bool
}

/// Accessibility identifiers UI tests use to find elements, independent of the app language.
/// The raw value is the case name.
enum AccessibilityIdentifier: String {

    // MARK: - Registration
    case registrationTitleLabel
    case registrationNameTextField
    case registrationEmailTextField
    case registrationPasswordTextField
    case registrationPasswordVisibilityButton
    case registrationSignUpButton
    case registrationGoToLoginButton

    // MARK: - Login
    case loginTitleLabel
    case loginEmailTextField
    case loginPasswordTextField
    case loginPasswordVisibilityButton
    case loginSignInButton
    case loginForgotPasswordButton
    case loginGoToSignUpButton

    // MARK: - Account
    case accountEditButton

    // MARK: - Navigation
    case dismissButton
}

extension UIView {

    func setAccessibilityIdentifier(_ identifier: AccessibilityIdentifier) {
        accessibilityIdentifier = identifier.rawValue
    }
}
