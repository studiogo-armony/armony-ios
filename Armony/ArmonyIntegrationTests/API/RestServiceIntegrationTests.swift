//
//  RestServiceIntegrationTests.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import Alamofire
@testable import Armony
import XCTest

/// `RestService` + `RestAPI` + `RestAPIMiddleware` + Alamofire, with only the network (`StubURLProtocol`),
/// connectivity and Crashlytics faked.
final class RestServiceIntegrationTests: IntegrationTestCase {

    private var mockConnection: MockInternetConnectionChecker!
    private var mockLogger: MockErrorLogger!
    private var sut: RestService!

    override func setUp() {
        super.setUp()
        mockConnection = MockInternetConnectionChecker()
        mockLogger = MockErrorLogger()
        sut = RestService(backend: .stubbed(), internetConnectionService: mockConnection, logger: mockLogger)
    }

    override func tearDown() {
        sut = nil
        mockLogger = nil
        mockConnection = nil
        super.tearDown()
    }

    // MARK: - Request building

    func test_execute_buildsURLFromEnvironmentPathAndQuery() async throws {
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        _ = try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)

        let request = try XCTUnwrap(StubURLProtocol.recordedRequests.first)
        XCTAssertEqual(request.request.url?.absoluteString, "https://test.armony.local/v1/integration/ping?page=2")
        XCTAssertEqual(request.method, "GET")
    }

    func test_execute_sendsSessionAndMiddlewareHeaders() async throws {
        TestKeychain.make()["Authorization"] = "access-token"
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        _ = try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)

        let request = try XCTUnwrap(StubURLProtocol.recordedRequests.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Client-Type"), "IOS")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "access-token")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Custom-Header"), "custom")
    }

    func test_execute_whenPostTask_sendsBodyAsJSON() async throws {
        StubURLProtocol.stub(.post, path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        _ = try await sut.execute(task: PostPingTask(), type: RestObjectResponse<Ping>.self)

        let request = try XCTUnwrap(StubURLProtocol.recordedRequests(.post, path: "/integration/ping").first)
        let body = try XCTUnwrap(request.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["name"] as? String, "armony")
        XCTAssertEqual(json["count"] as? Int, 3)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    // MARK: - Success

    func test_execute_whenResponseHasData_returnsDecodedResponse() async throws {
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        let response = try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)

        XCTAssertEqual(response.data, Ping(message: "pong"))
        XCTAssertEqual(response.metadata?.page, 2)
        XCTAssertEqual(response.metadata?.hasNext, true)
        XCTAssertTrue(response.isSuccess)
        XCTAssertFalse(mockLogger.invokedLogError)
    }

    func test_upload_whenResponseHasData_sendsMultipartAndReturnsDecodedResponse() async throws {
        StubURLProtocol.stub(.post, path: "/integration/upload", body: IntegrationFixtures.data(named: "rest_ping_success"))

        let response = try await sut.upload(task: UploadPingTask(), type: RestObjectResponse<Ping>.self)

        XCTAssertEqual(response.data, Ping(message: "pong"))
        let request = try XCTUnwrap(StubURLProtocol.recordedRequests(.post, path: "/integration/upload").first)
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type").emptyIfNil.hasPrefix("multipart/form-data"))
    }

    // MARK: - Connectivity

    func test_execute_whenOffline_throwsWithoutSendingRequestAndLogsException() async {
        mockConnection.stubbedIsConnected = false
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_ping_success"))

        await assertThrowsAPIError(try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self))

        XCTAssertTrue(StubURLProtocol.recordedRequests.isEmpty)
        XCTAssertEqual(mockLogger.invokedLogExceptionCount, 1)
        XCTAssertEqual(mockLogger.invokedLogExceptionParameters?.exception.reason, "internet is not connected")
    }

    func test_upload_whenOffline_throwsWithoutSendingRequestAndLogsException() async {
        mockConnection.stubbedIsConnected = false

        await assertThrowsAPIError(try await sut.upload(task: UploadPingTask(), type: RestObjectResponse<Ping>.self))

        XCTAssertTrue(StubURLProtocol.recordedRequests.isEmpty)
        XCTAssertEqual(mockLogger.invokedLogExceptionCount, 1)
    }

    // MARK: - API errors

    func test_execute_whenSuccessStatusHasErrorBody_throwsServerAPIError() async {
        StubURLProtocol.stub(path: "/integration/ping", body: IntegrationFixtures.data(named: "rest_api_error"))

        let error = await assertThrowsAPIError(try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self))

        XCTAssertEqual(error?.code, 1001)
        XCTAssertEqual(error?.description, "Advert not found")
    }

    func test_execute_whenClientErrorStatusHasErrorBody_throwsServerAPIError() async {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 404, body: IntegrationFixtures.data(named: "rest_api_error"))

        let error = await assertThrowsAPIError(try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self))

        XCTAssertEqual(error?.code, 1001)
        XCTAssertFalse(mockLogger.invokedLogError)
    }

    func test_execute_whenServerErrorStatus_throwsValidationErrorAndLogsIt() async {
        StubURLProtocol.stub(path: "/integration/ping", statusCode: 500, body: Data("{}".utf8))

        do {
            _ = try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
            XCTFail("Expected 500 to throw")
        }
        catch {
            XCTAssertTrue((error as? AFError)?.isResponseValidationError == true, "Unexpected error: \(error)")
        }
        XCTAssertEqual(mockLogger.invokedLogErrorCount, 1)
        XCTAssertEqual(StubURLProtocol.recordedRequests.count, 1, "Non-401 errors must not be retried")
    }

    // MARK: - Malformed responses

    func test_execute_whenBodyIsEmpty_throwsAPIError() async {
        StubURLProtocol.stub(path: "/integration/ping", body: nil)

        await assertThrowsAPIError(try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self))

        XCTAssertEqual(StubURLProtocol.recordedRequests.count, 1)
        XCTAssertFalse(mockLogger.invokedLogError)
    }

    func test_execute_whenBodyIsNotJSON_throwsDecodingError() async {
        StubURLProtocol.stub(path: "/integration/ping", body: Data("<html>gateway</html>".utf8))

        await assertThrowsDecodingError(try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self))
    }

    func test_execute_whenDataDoesNotMatchModel_throwsDecodingError() async {
        StubURLProtocol.stub(path: "/integration/ping", body: Data(#"{"data": {"unexpected": 1}}"#.utf8))

        await assertThrowsDecodingError(try await sut.execute(task: PingTask(), type: RestObjectResponse<Ping>.self))
    }

    // MARK: - Transport errors

    func test_execute_whenRequestTimesOut_finishesWithAPIErrorWithoutRetrying() async {
        StubURLProtocol.stub(path: "/integration/ping", error: URLError(.timedOut))

        await assertFinishesWithAPIError(within: 2.0) { [sut] in
            _ = try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }

        XCTAssertEqual(StubURLProtocol.recordedRequests.count, 1)
    }

    func test_execute_whenConnectionIsLost_finishesWithAPIError() async {
        StubURLProtocol.stub(path: "/integration/ping", error: URLError(.networkConnectionLost))

        await assertFinishesWithAPIError(within: 2.0) { [sut] in
            _ = try await sut!.execute(task: PingTask(), type: RestObjectResponse<Ping>.self)
        }
    }

    func test_upload_whenRequestTimesOut_finishesWithAPIError() async {
        StubURLProtocol.stub(.post, path: "/integration/upload", error: URLError(.timedOut))

        await assertFinishesWithAPIError(within: 2.0) { [sut] in
            _ = try await sut!.upload(task: UploadPingTask(), type: RestObjectResponse<Ping>.self)
        }
    }
}

// MARK: - Assertions
private extension RestServiceIntegrationTests {

    @discardableResult
    func assertThrowsAPIError<T>(_ expression: @autoclosure () async throws -> T,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) async -> APIError? {
        do {
            _ = try await expression()
            XCTFail("Expected APIError to be thrown", file: file, line: line)
            return nil
        }
        catch let error as APIError {
            return error
        }
        catch {
            XCTFail("Expected APIError, got \(error)", file: file, line: line)
            return nil
        }
    }

    /// Runs `work` in a separate task so a request that never completes fails the test instead of hanging the suite.
    func assertFinishesWithAPIError(within timeout: TimeInterval,
                                    file: StaticString = #filePath,
                                    line: UInt = #line,
                                    _ work: @escaping () async throws -> Void) async {
        let finished = expectation(description: "request finished")
        var thrownError: Error?

        Task {
            do {
                try await work()
            }
            catch {
                thrownError = error
            }
            finished.fulfill()
        }

        await fulfillment(of: [finished], timeout: timeout)
        XCTAssertTrue(thrownError is APIError, "Expected APIError, got \(String(describing: thrownError))", file: file, line: line)
    }

    func assertThrowsDecodingError<T>(_ expression: @autoclosure () async throws -> T,
                                      file: StaticString = #filePath,
                                      line: UInt = #line) async {
        do {
            _ = try await expression()
            XCTFail("Expected DecodingError to be thrown", file: file, line: line)
        }
        catch is DecodingError { }
        catch {
            XCTFail("Expected DecodingError, got \(error)", file: file, line: line)
        }
    }
}

// MARK: - Test tasks
private struct Ping: Decodable, Equatable {
    let message: String
}

private struct PingTask: HTTPTask {
    var method: HTTPMethod = .get
    var path: String = "/integration/ping"
    var urlQueryItems: [URLQueryItem]? = [URLQueryItem(name: "page", value: "2")]
    var additionalHeader: [String: String] = ["Custom-Header": "custom"]
}

private struct PostPingTask: HTTPTask {
    var method: HTTPMethod = .post
    var path: String = "/integration/ping"
    var body: Parameters? = ["name": "armony", "count": 3]
}

private struct UploadPingTask: HTTPUploadTask {
    var method: HTTPMethod = .post
    var path: String = "/integration/upload"
    var files: [FormData] = [FormData(data: Data([0xFF, 0xD8, 0xFF]), key: "avatar", type: .jpg)]
}
