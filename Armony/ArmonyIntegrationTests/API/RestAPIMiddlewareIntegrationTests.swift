//
//  RestAPIMiddlewareIntegrationTests.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import Alamofire
@testable import Armony
import XCTest

/// Token refresh and request adaptation through the real `RestService` + `RestAPI` + `RestAPIMiddleware` stack,
/// with a real `AuthenticationService` on the test keychain. Only the network and the login UI are faked.
final class RestAPIMiddlewareIntegrationTests: IntegrationTestCase {

    private var authenticator: AuthenticationService!
    private var defaults: Defaults!
    private var mockLogger: MockErrorLogger!
    private var mockSessionExpiredHandler: MockSessionExpiredHandler!
    private var sut: RestService!

    override func setUp() {
        super.setUp()
        authenticator = AuthenticationService(keychain: TestKeychain.make(), notifier: NotificationCenter())
        authenticator.authenticate(accessToken: "expired-access", refreshToken: "refresh-1", userID: "42")
        defaults = TestDefaults.make()
        mockLogger = MockErrorLogger()
        mockSessionExpiredHandler = MockSessionExpiredHandler()

        let middleware = RestAPIMiddleware.stubbed(authenticator: authenticator,
                                                   defaults: defaults,
                                                   logger: mockLogger,
                                                   sessionExpiredHandler: mockSessionExpiredHandler.handle)
        sut = RestService(backend: .stubbed(middleware: middleware),
                          internetConnectionService: MockInternetConnectionChecker(),
                          logger: MockErrorLogger())
    }

    override func tearDown() {
        sut = nil
        mockSessionExpiredHandler = nil
        mockLogger = nil
        defaults = nil
        authenticator = nil
        super.tearDown()
    }

    // MARK: - Token refresh

    func test_execute_whenTokenExpired_refreshesTokenAndRetriesWithNewToken() async throws {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))
        StubURLProtocol.stub(.post, path: "/auth/refresh", body: IntegrationFixtures.data(named: "refresh_token_success"))

        let outcome = await result { [sut] in
            try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }

        XCTAssertEqual(try outcome?.get().data, Ping(message: "pong"))
        let pings = StubURLProtocol.recordedRequests(.get, path: "/integration/ping")
        XCTAssertEqual(pings.map { $0.value(forHTTPHeaderField: "Authorization") }, ["expired-access", "new-access"])
        let refreshBody = try XCTUnwrap(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").first?.body)
        let refreshJSON = try XCTUnwrap(JSONSerialization.jsonObject(with: refreshBody) as? [String: Any])
        XCTAssertEqual(refreshJSON["refreshToken"] as? String, "refresh-1")
        XCTAssertEqual(authenticator.additionalHTTPHeaders["Authorization"], "new-access")
        XCTAssertEqual(authenticator.refreshToken, "refresh-2")
        XCTAssertEqual(authenticator.userID, "42")
        XCTAssertEqual(mockLogger.invokedLogExceptionCount, 1)
        XCTAssertFalse(mockSessionExpiredHandler.invokedHandle)
    }

    func test_execute_whenRefreshTokenIsRejected_logsOutAsksForLoginAndFails() async {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(.post, path: "/auth/refresh", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))

        let outcome = await result { [sut] in
            try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }

        assertAPIError(outcome, code: 401)
        XCTAssertFalse(authenticator.isAuthenticated)
        XCTAssertTrue(authenticator.userID.isEmpty)
        XCTAssertTrue(mockSessionExpiredHandler.invokedHandle)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.get, path: "/integration/ping").count, 1)
    }

    /// Synchronous on purpose: `XCTExpectFailure` only matches issues recorded on the thread that called it.
    func test_execute_whenRefreshTokenIsRejected_refreshesAndAsksForLoginOnlyOnce() {
        XCTExpectFailure("""
            Known bug: Alamofire asks the retrier again when the response serializer rethrows the 401 validation error. \
            retryCount is still 0, so RestAPIMiddleware refreshes and presents login a second time.
            """)
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(.post, path: "/auth/refresh", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        let finished = expectation(description: "execute finished")

        Task { [sut] in
            _ = try? await sut?.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
            finished.fulfill()
        }

        wait(for: [finished], timeout: 2.0)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 1)
        XCTAssertEqual(mockSessionExpiredHandler.invokedHandleCount, 1)
    }

    func test_execute_whenTokenStaysExpired_stopsAfterFourRetries() async {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(.post, path: "/auth/refresh", body: IntegrationFixtures.data(named: "refresh_token_success"))

        let outcome = await result { [sut] in
            try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }

        assertAPIError(outcome, code: 401)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.get, path: "/integration/ping").count, 5)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 4)
        XCTAssertFalse(mockSessionExpiredHandler.invokedHandle)
    }

    func test_execute_whenWhitelistedEndpointReturns401_doesNotRefresh() async {
        StubURLProtocol.stub(.post, path: "/auth/signin", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))

        let outcome = await result { [sut] in
            try await sut!.execute(task: SignInTask(), type: RestObjectResponse<Ping>.self)
        }

        assertAPIError(outcome, code: 401)
        XCTAssertEqual(StubURLProtocol.recordedRequests.count, 1)
        XCTAssertFalse(mockLogger.invokedLogException)
        XCTAssertTrue(authenticator.isAuthenticated)
    }

    // MARK: - Request adaptation

    func test_execute_whenRegionIsActive_sendsSelectedRegion() async throws {
        defaults[.isRegionActive] = true
        defaults[.region] = "DE"
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        _ = try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)

        let request = try XCTUnwrap(StubURLProtocol.recordedRequests.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Region"), "DE")
        XCTAssertNotNil(request.value(forHTTPHeaderField: "Time-Zone"))
        XCTAssertNotNil(request.value(forHTTPHeaderField: "Time-Zone-Name"))
    }

    func test_execute_whenRegionIsInactive_sendsDeviceRegion() async throws {
        defaults[.isRegionActive] = false
        defaults[.region] = "DE"
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        _ = try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)

        let request = try XCTUnwrap(StubURLProtocol.recordedRequests.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Region"), Locale.current.regionCode)
    }
}

// MARK: - Assertions
private extension RestAPIMiddlewareIntegrationTests {

    func assertAPIError<T>(_ outcome: Result<T, Error>?,
                           code: Int,
                           file: StaticString = #filePath,
                           line: UInt = #line) {
        guard let outcome = outcome else { return }
        guard case let .failure(error) = outcome, let apiError = error as? APIError else {
            XCTFail("Expected APIError, got \(outcome)", file: file, line: line)
            return
        }
        XCTAssertEqual(apiError.code, code, file: file, line: line)
    }
}

// MARK: - Test tasks
private struct Ping: Decodable, Equatable {
    let message: String
}

private struct PingTask: HTTPTask {
    var method: HTTPMethod = .get
    var path: String = "/integration/ping"
}

private struct SignInTask: HTTPTask {
    var method: HTTPMethod = .post
    var path: String = "/auth/signin"
}
