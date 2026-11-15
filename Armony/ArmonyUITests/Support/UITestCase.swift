//
//  UITestCase.swift
//  ArmonyUITests
//

import XCTest

/// Base class for UI tests.
///
/// The app is started by one of the `launch…` methods with `UITestLaunchArgument.enabled`, so every test starts
/// without onboarding and can never reach a real backend (see `UITestLaunchConfiguration` in the app).
///
/// - Register the responses a test needs with `stub(_:)` **before** launching. The app answers every request from
///   those stubs (plus the home screen's, see `UITestStub.home()`) and fails any request without one; a test
///   fails if the app made such a request, so a missing stub is never silently ignored.
/// - Read back what the app sent with `waitForRequest(_:_:)`.
/// - Skip navigation a test is not about: `launchLogin()` opens login directly and `launchHome(signedIn: true)`
///   starts with a session.
class UITestCase: XCTestCase {

    private(set) var app: XCUIApplication!
    private var stubs: [UITestStub] = []

    /// Per test, so tests running in parallel never share files.
    private var sessionDirectory: URL!
    private var requestLogFile: URL { sessionDirectory.appendingPathComponent("requests.jsonl") }

    override func setUpWithError() throws {
        try super.setUpWithError()
        // A failed step leaves the UI in an unknown state, so later steps would only add noise.
        continueAfterFailure = false

        sessionDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: sessionDirectory, withIntermediateDirectories: true)
        XCTAssertTrue(FileManager.default.createFile(atPath: requestLogFile.path, contents: nil))

        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        let unstubbed = requests.filter { !$0.isStubbed }
        XCTAssertTrue(
            unstubbed.isEmpty,
            "The app made requests without a stub: \(unstubbed.map { "\($0.method) \($0.path)" })"
        )

        try? FileManager.default.removeItem(at: sessionDirectory)
        app = nil
        stubs = []
        try super.tearDownWithError()
    }

    // MARK: - Stubs

    func stub(_ stub: UITestStub) {
        stubs.append(stub)
    }

    func stub(contentsOf stubs: [UITestStub]) {
        self.stubs.append(contentsOf: stubs)
    }

    // MARK: - Requests

    /// Every request the app made so far, in order.
    var requests: [UITestRecordedRequest] {
        guard let contents = try? String(contentsOf: requestLogFile, encoding: .utf8) else { return [] }
        return contents
            .split(separator: "\n")
            .compactMap { try? JSONDecoder().decode(UITestRecordedRequest.self, from: Data($0.utf8)) }
    }

    /// The last request with `method` whose path ends with `path`, waiting for the app to make it.
    @discardableResult
    func waitForRequest(
        _ method: String,
        _ path: String,
        timeout: TimeInterval = Page.timeout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> UITestRecordedRequest {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if let request = requests.last(where: { $0.method == method && $0.path.hasSuffix(path) }) {
                return request
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        XCTFail("The app did not make a \(method) \(path) request", file: file, line: line)
        return UITestRecordedRequest(method: method, path: path, body: nil, isStubbed: false)
    }

    // MARK: - Launch

    /// Launches the app and returns the starting point of every flow.
    @discardableResult
    func launchHome(signedIn: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> HomePage {
        launch(signedIn: signedIn, deeplink: nil, file: file, line: line)
        return HomePage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    /// Launches the app signed out with login already open, as when a deeplink needs authentication.
    @discardableResult
    func launchLogin(file: StaticString = #filePath, line: UInt = #line) -> LoginPage {
        launch(signedIn: false, deeplink: Self.authenticatedDeeplink, file: file, line: line)
        return LoginPage(app: app).waitUntilDisplayed(file: file, line: line)
    }

    /// Any deeplink whose screen requires authentication; settings is the simplest one.
    private static let authenticatedDeeplink = "/settings"

    private func launch(signedIn: Bool, deeplink: String?, file: StaticString, line: UInt) {
        do {
            let stubsFile = sessionDirectory.appendingPathComponent("stubs.json")
            try JSONEncoder().encode(stubs + UITestStub.home()).write(to: stubsFile)

            app.launchArguments.append(UITestLaunchArgument.enabled)
            if signedIn {
                app.launchArguments.append(UITestLaunchArgument.signedIn)
            }
            app.launchEnvironment[UITestLaunchEnvironment.stubsFile] = stubsFile.path
            app.launchEnvironment[UITestLaunchEnvironment.requestLogFile] = requestLogFile.path
            if let deeplink {
                app.launchEnvironment[UITestLaunchEnvironment.deeplink] = deeplink
            }
        }
        catch {
            XCTFail("Could not write stubs: \(error)", file: file, line: line)
        }
        app.launch()
    }
}

// MARK: - UITestRecordedRequest
extension UITestRecordedRequest {

    /// The body parsed as a JSON object.
    var json: [String: Any] {
        guard let data = body?.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return object
    }
}
