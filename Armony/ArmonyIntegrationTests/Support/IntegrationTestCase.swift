//
//  IntegrationTestCase.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import XCTest

/// Base class for integration tests: every test starts with no stubs, no recorded requests and an empty test keychain.
class IntegrationTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
        TestKeychain.clear()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        TestKeychain.clear()
        super.tearDown()
    }
}
