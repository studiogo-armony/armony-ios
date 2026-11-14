//
//  IntegrationTestCase.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import XCTest

/// Base class for integration tests: every test starts with no stubs, no recorded requests, an empty test keychain
/// and `TestAPIEnvironment` as the API environment.
class IntegrationTestCase: XCTestCase {

    private var originalEnvironment: APIEnvironment!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        TestKeychain.clear()
        originalEnvironment = APIEnvironmentProvider.current
        APIEnvironmentProvider.current = TestAPIEnvironment()
    }

    override func tearDown() {
        APIEnvironmentProvider.current = originalEnvironment
        StubURLProtocol.reset()
        TestKeychain.clear()
        super.tearDown()
    }
}
