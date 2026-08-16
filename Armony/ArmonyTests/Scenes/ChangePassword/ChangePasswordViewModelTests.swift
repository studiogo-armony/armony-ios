//
//  ChangePasswordViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import XCTest
@testable import Armony

final class ChangePasswordViewModelTests: XCTestCase {

    var mockView: MockChangePasswordView!
    var mockCoordinator: MockChangePasswordCoordinator!
    var mockService: MockRestService!
    var sut: ChangePasswordViewModel!

    override func setUpWithError() throws {
        mockView = MockChangePasswordView()
        mockCoordinator = MockChangePasswordCoordinator()
        mockService = MockRestService(backend: .factory())

        sut = ChangePasswordViewModel(view: mockView, service: mockService)
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockCoordinator = nil
        mockService = nil
        sut = nil
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_configuresUI() {
        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedConfigureUI)
    }

    // MARK: - saveButtonTapped — guard

    func test_saveButtonTapped_withNilCurrentPassword_doesNothing() {
        sut.saveButtonTapped(currentPassword: nil, newPassword: "new123")

        XCTAssertFalse(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_withNilNewPassword_doesNothing() {
        sut.saveButtonTapped(currentPassword: "current123", newPassword: nil)

        XCTAssertFalse(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_withBothNil_doesNothing() {
        sut.saveButtonTapped(currentPassword: nil, newPassword: nil)

        XCTAssertFalse(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    // MARK: - saveButtonTapped — synchronous

    func test_saveButtonTapped_withValidInputs_startsActivityIndicator() {
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.saveButtonTapped(currentPassword: "current123", newPassword: "new123")

        XCTAssertTrue(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    // MARK: - saveButtonTapped — async success

    func test_saveButtonTapped_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSaveButton called")
        mockView.onStopSaveButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.saveButtonTapped(currentPassword: "current123", newPassword: "new123")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_onSuccess_doesNotPopSynchronously() {
        // pop() is called inside AlertService okay action — not synchronously testable.
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.saveButtonTapped(currentPassword: "current123", newPassword: "new123")

        XCTAssertFalse(mockCoordinator.invokedPop)
    }

    // MARK: - saveButtonTapped — async error

    func test_saveButtonTapped_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSaveButton called on error")
        mockView.onStopSaveButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.saveButtonTapped(currentPassword: "current123", newPassword: "new123")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_onError_doesNotPop() async throws {
        let expectation = expectation(description: "stopSaveButton called on error")
        mockView.onStopSaveButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.saveButtonTapped(currentPassword: "current123", newPassword: "new123")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedPop)
    }
}
