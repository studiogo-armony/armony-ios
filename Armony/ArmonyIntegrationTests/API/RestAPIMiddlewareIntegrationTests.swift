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

    /// Alamofire asks the retrier a second time when the response serializer rethrows the 401 validation error.
    func test_execute_whenRefreshTokenIsRejected_refreshesAndAsksForLoginOnlyOnce() async {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(.post, path: "/auth/refresh", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))

        _ = await result { [sut] in
            try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }

        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 1)
        XCTAssertEqual(mockSessionExpiredHandler.invokedHandleCount, 1)
        XCTAssertEqual(mockLogger.invokedLogExceptionCount, 1)
    }

    func test_execute_whenTokenExpiresAgainAfterRefresh_refreshesForEachAttempt() async throws {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))
        StubURLProtocol.stub(.post, path: "/auth/refresh", body: IntegrationFixtures.data(named: "refresh_token_success"))

        let outcome = await result { [sut] in
            try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }

        XCTAssertEqual(try outcome?.get().data, Ping(message: "pong"))
        XCTAssertEqual(StubURLProtocol.recordedRequests(.get, path: "/integration/ping").count, 3)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 2)
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

    // MARK: - Concurrent requests

    func test_execute_whenConcurrentRequestsGetTokenExpired_refreshesOnceAndRetriesAll() async throws {
        stubServerAccepting(token: "new-access", paths: ConcurrentTasks.paths)
        StubURLProtocol.stub(.post, path: "/auth/refresh", body: IntegrationFixtures.data(named: "refresh_token_success"))

        let outcome = await result { [sut] in
            try await ConcurrentTasks.executeAll(on: sut!)
        }

        XCTAssertEqual(try outcome?.get(), Array(repeating: Ping(message: "pong"), count: 3))
        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 1)
        for path in ConcurrentTasks.paths {
            let requests = StubURLProtocol.recordedRequests(.get, path: path)
            XCTAssertEqual(requests.last?.value(forHTTPHeaderField: "Authorization"), "new-access", path)
        }
        XCTAssertEqual(authenticator.refreshToken, "refresh-2")
    }

    func test_execute_whenConcurrentRequestsGetTokenExpiredAndRefreshIsRejected_asksForLoginOnce() async {
        stubServerAccepting(token: "never-valid", paths: ConcurrentTasks.paths)
        StubURLProtocol.stub(.post, path: "/auth/refresh", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))

        let outcome = await result { [sut] in
            try await ConcurrentTasks.executeAll(on: sut!)
        }

        assertAPIError(outcome, code: 401)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 1)
        XCTAssertEqual(mockSessionExpiredHandler.invokedHandleCount, 1)
        XCTAssertFalse(authenticator.isAuthenticated)
    }

    func test_execute_whenTokenExpiresWhileLoginIsShown_waitsForLoginInsteadOfRefreshing() async {
        mockSessionExpiredHandler.stubbedShouldCallCompletion = false
        stubServerAccepting(token: "never-valid", paths: ConcurrentTasks.paths)
        StubURLProtocol.stub(.post, path: "/auth/refresh", statusCode: 401, body: IntegrationFixtures.data(named: "token_expired_error"))
        let firstStarted = expectation(description: "first request waits for login")

        Task { [sut] in
            _ = try? await sut?.execute(task: ConcurrentTasks.First(), type: RestObjectResponse<Ping>.self)
        }
        Task { [mockSessionExpiredHandler] in
            while mockSessionExpiredHandler?.invokedHandle == false {
                await Task.yield()
            }
            firstStarted.fulfill()
        }
        await fulfillment(of: [firstStarted], timeout: 2.0)

        // Login is on screen: a guest request that gets 401 must neither refresh again nor present a second login.
        Task { [sut] in
            _ = try? await sut?.execute(task: ConcurrentTasks.Second(), type: RestObjectResponse<Ping>.self)
        }
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(StubURLProtocol.recordedRequests(.get, path: ConcurrentTasks.paths[1]).count, 1)
        XCTAssertEqual(StubURLProtocol.recordedRequests(.post, path: "/auth/refresh").count, 1)
        XCTAssertEqual(mockSessionExpiredHandler.invokedHandleCount, 1)
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

    /// Behaves like the backend: 200 for requests carrying `token`, 401 otherwise, regardless of timing.
    func stubServerAccepting(token: String, paths: [String]) {
        let success = IntegrationFixtures.data(named: "rest_ping_success")
        let expired = IntegrationFixtures.data(named: "token_expired_error")
        for path in paths {
            StubURLProtocol.stub(path: path) { request in
                let isAuthorized = request.value(forHTTPHeaderField: "Authorization") == token
                return StubURLProtocol.json(statusCode: isAuthorized ? 200 : 401, body: isAuthorized ? success : expired)
            }
        }
    }

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

/// Separate task types: `RestService` cancels a running request whose task has the same `description` (type name).
private enum ConcurrentTasks {

    static let paths = ["/integration/first", "/integration/second", "/integration/third"]

    struct First: HTTPTask {
        var method: HTTPMethod = .get
        var path: String = ConcurrentTasks.paths[0]
    }

    struct Second: HTTPTask {
        var method: HTTPMethod = .get
        var path: String = ConcurrentTasks.paths[1]
    }

    struct Third: HTTPTask {
        var method: HTTPMethod = .get
        var path: String = ConcurrentTasks.paths[2]
    }

    static func executeAll(on service: RestService) async throws -> [Ping] {
        async let first = service.execute(task: First(), type: RestObjectResponse<Ping>.self)
        async let second = service.execute(task: Second(), type: RestObjectResponse<Ping>.self)
        async let third = service.execute(task: Third(), type: RestObjectResponse<Ping>.self)
        return try await [first.data, second.data, third.data]
    }
}

private struct SignInTask: HTTPTask {
    var method: HTTPMethod = .post
    var path: String = "/auth/signin"
}
