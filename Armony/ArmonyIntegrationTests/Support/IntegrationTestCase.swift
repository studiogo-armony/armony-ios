//
//  IntegrationTestCase.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import XCTest

/// Base class for integration tests: every test starts with no stubs, no recorded requests, an empty test keychain,
/// empty test defaults and `TestAPIEnvironment` as the API environment.
class IntegrationTestCase: XCTestCase {

    private var originalEnvironment: APIEnvironment!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        TestKeychain.clear()
        TestDefaults.clear()
        originalEnvironment = APIEnvironmentProvider.current
        APIEnvironmentProvider.current = TestAPIEnvironment()
    }

    override func tearDown() {
        APIEnvironmentProvider.current = originalEnvironment
        StubURLProtocol.reset()
        TestKeychain.clear()
        TestDefaults.clear()
        super.tearDown()
    }

    /// Awaits `work` in a separate task, so a request that never completes fails the test after `timeout`
    /// instead of hanging the whole suite.
    /// - Returns: `nil` when `work` didn't finish in time (the test has already failed).
    func result<T>(within timeout: TimeInterval = 2.0,
                   _ work: @escaping () async throws -> T) async -> Result<T, Error>? {
        let finished = expectation(description: "work finished")
        var result: Result<T, Error>?

        Task {
            do {
                result = .success(try await work())
            }
            catch {
                result = .failure(error)
            }
            finished.fulfill()
        }

        await fulfillment(of: [finished], timeout: timeout)
        return result
    }
}
