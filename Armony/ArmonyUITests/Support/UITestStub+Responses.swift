//
//  UITestStub+Responses.swift
//  ArmonyUITests
//

import Foundation

/// Canned backend responses, loaded from `Fixtures/`. JSON keys are the server's, not the Swift property
/// names (see the `CodingKeys` of `Token`, `UserDetail` and `APIError`).
extension UITestStub {

    // MARK: - Home

    /// What the home screen requests on launch. `UITestCase` registers these for every test.
    static func home() -> [UITestStub] {
        return [
            UITestStub(method: "GET", path: "/ads", statusCode: 200, fixture: "adverts_empty"),
            UITestStub(method: "GET", path: "/banners", statusCode: 200, fixture: "banners_inactive")
        ]
    }

    // MARK: - Auth

    static func signInSuccess() -> UITestStub {
        return UITestStub(method: "POST", path: "/auth/signin", statusCode: 200, fixture: "auth_token")
    }

    static func signInFailure(_ error: AuthError) -> UITestStub {
        return UITestStub(method: "POST", path: "/auth/signin", statusCode: 400, fixture: error.fixture)
    }

    static func signUpSuccess() -> UITestStub {
        return UITestStub(method: "POST", path: "/auth/signup", statusCode: 200, fixture: "auth_token")
    }

    static func signUpFailure(_ error: AuthError) -> UITestStub {
        return UITestStub(method: "POST", path: "/auth/signup", statusCode: 400, fixture: error.fixture)
    }

    // MARK: - Signed in

    static func userDetail() -> UITestStub {
        return UITestStub(method: "GET", path: "/users/\(UITestSession.userID)", statusCode: 200, fixture: "user_detail")
    }

    /// Requests the app makes right after a successful sign in or sign up.
    static func signedInUser() -> [UITestStub] {
        return [
            UITestStub(method: "PUT", path: "/users/\(UITestSession.userID)/fcm-token", statusCode: 200, fixture: "empty_data"),
            userDetail()
        ]
    }

    // MARK: - Errors

    /// Backend error codes the app turns into user facing messages (`AuthenticationErrorHandler`).
    enum AuthError {
        case emailNotFound
        case invalidPassword
        case emailExist

        /// The message the app shows for the error.
        var message: String {
            switch self {
            case .emailNotFound:
                return "The email you provided is not linked to any existing account."
            case .invalidPassword:
                return "Email or password is incorrect"
            case .emailExist:
                return "An account is already registered with this email. Try logging in instead."
            }
        }

        fileprivate var fixture: String {
            switch self {
            case .emailNotFound:
                return "auth_error_email_not_found"
            case .invalidPassword:
                return "auth_error_invalid_password"
            case .emailExist:
                return "auth_error_email_exist"
            }
        }
    }

    // MARK: - Fixtures

    fileprivate init(method: String, path: String, statusCode: Int, fixture: String) {
        self.init(method: method, path: path, statusCode: statusCode, body: Self.fixtureBody(named: fixture))
    }

    private static func fixtureBody(named name: String) -> String {
        guard let url = Bundle(for: UITestCase.self).url(forResource: name, withExtension: "json"),
              let body = try? String(contentsOf: url, encoding: .utf8) else {
            preconditionFailure("Missing UI test fixture \(name).json")
        }
        return body
    }
}
