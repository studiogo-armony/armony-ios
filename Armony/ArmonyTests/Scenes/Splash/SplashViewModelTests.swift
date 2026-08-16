//
//  SplashViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import XCTest
@testable import Armony

final class SplashViewModelTests: XCTestCase {

    var mockCoordinator: MockSplashCoordinator!
    var mockRemoteConfig: MockRemoteConfigService!
    var mockForceUpdateHandler: MockForceUpdateHandler!
    var sut: SplashViewModel!

    override func setUpWithError() throws {
        mockCoordinator = MockSplashCoordinator()
        mockRemoteConfig = MockRemoteConfigService()
        mockForceUpdateHandler = MockForceUpdateHandler()

        sut = SplashViewModel(
            remoteConfigService: mockRemoteConfig,
            forceUpdateHandler: mockForceUpdateHandler
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockCoordinator = nil
        mockRemoteConfig = nil
        mockForceUpdateHandler = nil
        sut = nil
    }

    // MARK: - viewDidLoad — force update disabled

    func test_viewDidLoad_whenForceUpdateDisabled_navigatesToArmony() async throws {
        let expectation = expectation(description: "armony() called")
        mockCoordinator.onArmony = { expectation.fulfill() }
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = false

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedArmony)
        XCTAssertFalse(mockForceUpdateHandler.invokedShouldUpdate)
    }

    func test_viewDidLoad_whenForceUpdateDisabled_doesNotCheckAppStore() async throws {
        let expectation = expectation(description: "armony() called")
        mockCoordinator.onArmony = { expectation.fulfill() }
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = false

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockForceUpdateHandler.invokedShouldUpdate)
    }

    // MARK: - viewDidLoad — force update enabled, no update needed

    func test_viewDidLoad_whenForceUpdateEnabled_andNoUpdateNeeded_navigatesToArmony() async throws {
        let expectation = expectation(description: "armony() called")
        mockCoordinator.onArmony = { expectation.fulfill() }
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = true
        mockForceUpdateHandler.stubbedShouldUpdateResult = false

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedArmony)
    }

    func test_viewDidLoad_whenForceUpdateEnabled_andNoUpdateNeeded_checksShouldUpdate() async throws {
        let expectation = expectation(description: "armony() called")
        mockCoordinator.onArmony = { expectation.fulfill() }
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = true
        mockForceUpdateHandler.stubbedShouldUpdateResult = false

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockForceUpdateHandler.invokedShouldUpdate)
    }

    // MARK: - viewDidLoad — force update enabled, update required

    func test_viewDidLoad_whenForceUpdateEnabled_andUpdateRequired_doesNotNavigateToArmony() async throws {
        let expectation = expectation(description: "shouldUpdate() called")
        mockForceUpdateHandler.onShouldUpdate = { expectation.fulfill() }
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = true
        mockForceUpdateHandler.stubbedShouldUpdateResult = true

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedArmony)
    }

    // MARK: - viewDidLoad — remote config error

    func test_viewDidLoad_whenRemoteConfigFails_doesNotNavigateToArmony() async throws {
        mockRemoteConfig.stubbedStartError = APIError.network

        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(mockCoordinator.invokedArmony)
    }

    func test_viewDidLoad_whenRemoteConfigFails_doesNotCheckForceUpdate() async throws {
        mockRemoteConfig.stubbedStartError = APIError.network

        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(mockForceUpdateHandler.invokedShouldUpdate)
    }

    // MARK: - viewDidLoad — force update shouldUpdate error

    func test_viewDidLoad_whenShouldUpdateFails_doesNotNavigateToArmony() async throws {
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = true
        mockForceUpdateHandler.stubbedShouldUpdateError = APIError.network

        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(mockCoordinator.invokedArmony)
    }

    // MARK: - viewDidLoad — startsRemoteConfig

    func test_viewDidLoad_startsRemoteConfig() async throws {
        let expectation = expectation(description: "armony() called")
        mockCoordinator.onArmony = { expectation.fulfill() }
        mockRemoteConfig.stubbedBoolValues["FORCE_UPDATE"] = false

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockRemoteConfig.invokedStart)
    }
}
