//
//  TestUser.swift
//  ArmonyUITests
//

/// Form input for UI tests. Nothing is ever submitted: the app cannot reach a backend in UI tests.
struct TestUser {
    let name: String
    let email: String
    let password: String

    static let valid = TestUser(name: "Test User", email: "ui.test@example.com", password: "Secret123")

    /// Fails the form rules: name under 3 characters, malformed email, password under 6 characters.
    static let invalid = TestUser(name: "ab", email: "not-an-email", password: "12345")
}
