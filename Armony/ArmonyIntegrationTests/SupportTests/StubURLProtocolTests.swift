//
//  StubURLProtocolTests.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import XCTest

final class StubURLProtocolTests: IntegrationTestCase {

    private var session: URLSession!
    private let baseURL = URL(string: "https://test.armony.local/v1")!

    override func setUp() {
        super.setUp()
        session = URLSession(configuration: .stubbed())
    }

    override func tearDown() {
        session.invalidateAndCancel()
        session = nil
        super.tearDown()
    }

    func test_request_whenPathIsStubbed_returnsStubbedResponseAndRecordsBody() async throws {
        StubURLProtocol.stub(.post, path: "/auth/signin", statusCode: 201, body: IntegrationFixtures.data(named: "stub_smoke"))
        var request = URLRequest(url: baseURL.appendingPathComponent("auth/signin"))
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"email":"test@armony.app"}"#.utf8)

        let (data, response) = try await session.data(for: request)

        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 201)
        XCTAssertEqual(data, IntegrationFixtures.data(named: "stub_smoke"))
        let recorded = StubURLProtocol.recordedRequests(.post, path: "/auth/signin")
        XCTAssertEqual(recorded.count, 1)
        XCTAssertEqual(recorded.first?.body, Data(#"{"email":"test@armony.app"}"#.utf8))
    }

    func test_request_whenStubbedMultipleTimes_returnsInOrderAndRepeatsLast() async throws {
        StubURLProtocol.stub(path: "/adverts", statusCode: 401, body: nil)
        StubURLProtocol.stub(path: "/adverts", statusCode: 200, body: nil)
        let url = baseURL.appendingPathComponent("adverts")

        let (_, first) = try await session.data(from: url)
        let (_, second) = try await session.data(from: url)
        let (_, third) = try await session.data(from: url)

        XCTAssertEqual((first as? HTTPURLResponse)?.statusCode, 401)
        XCTAssertEqual((second as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual((third as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual(StubURLProtocol.recordedRequests.count, 3)
    }

    func test_request_whenPathIsNotStubbed_failsAndIsRecorded() async {
        do {
            _ = try await session.data(from: baseURL.appendingPathComponent("unknown"))
            XCTFail("Expected unstubbed request to fail")
        }
        catch {
            XCTAssertEqual((error as? URLError)?.code, .resourceUnavailable)
        }
        XCTAssertEqual(StubURLProtocol.recordedRequests.count, 1)
    }

    func test_request_whenErrorIsStubbed_failsWithThatError() async {
        StubURLProtocol.stub(path: "/adverts", error: URLError(.timedOut))

        do {
            _ = try await session.data(from: baseURL.appendingPathComponent("adverts"))
            XCTFail("Expected stubbed error")
        }
        catch {
            XCTAssertEqual((error as? URLError)?.code, .timedOut)
        }
    }
}
