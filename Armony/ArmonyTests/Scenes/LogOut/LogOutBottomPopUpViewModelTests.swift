//
//  LogOutBottomPopUpViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import XCTest
@testable import Armony

final class LogOutBottomPopUpViewModelTests: XCTestCase {

    var mockView: MockLogOutBottomPopUpView!
    var mockCoordinator: MockLogOutBottomPopUpCoordinator!
    var mockService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockNotifier: MockNotificationCenter!
    var sut: LogOutBottomPopUpViewModel!

    override func setUpWithError() throws {
        mockView = MockLogOutBottomPopUpView()
        mockCoordinator = MockLogOutBottomPopUpCoordinator()
        mockService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockNotifier = MockNotificationCenter()

        sut = LogOutBottomPopUpViewModel(
            view: mockView,
            authenticator: mockAuthenticator,
            notifier: mockNotifier,
            service: mockService
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockCoordinator = nil
        mockService = nil
        mockAuthenticator = nil
        mockNotifier = nil
        sut = nil
    }

    // MARK: - logOut — synchronous

    func test_logOut_startsActivityIndicator() {
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        XCTAssertTrue(mockView.invokedStartLogoutButtonActivityIndicatorView)
    }

    // MARK: - logOut — async success

    func test_logOut_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopLogoutButton called")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopLogoutButtonActivityIndicatorView)
    }

    func test_logOut_onSuccess_callsUnauthenticate() async throws {
        let expectation = expectation(description: "stopLogoutButton called")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockAuthenticator.invokedUnauthenticate)
    }

    func test_logOut_onSuccess_postsUserLoggedOutNotification() async throws {
        let expectation = expectation(description: "stopLogoutButton called")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockNotifier.invokedPost)
        XCTAssertEqual(mockNotifier.invokedPostParameters?.notification, .userLoggedOut)
    }

    func test_logOut_onSuccess_dismissesCoordinator() async throws {
        let expectation = expectation(description: "stopLogoutButton called")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    func test_logOut_onSuccess_popsToRoot() async throws {
        let expectation = expectation(description: "stopLogoutButton called")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedPopToRootViewController)
    }

    func test_logOut_onSuccess_selectsHomeTab() async throws {
        let expectation = expectation(description: "stopLogoutButton called")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectTab)
        XCTAssertEqual(mockCoordinator.invokedSelectTabParameters?.tab, .home)
        XCTAssertTrue(mockCoordinator.invokedSelectTabParameters?.shouldPopToRoot ?? false)
    }

    // MARK: - logOut — async error

    func test_logOut_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopLogoutButton called on error")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopLogoutButtonActivityIndicatorView)
    }

    func test_logOut_onError_doesNotUnauthenticate() async throws {
        let expectation = expectation(description: "stopLogoutButton called on error")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockAuthenticator.invokedUnauthenticate)
    }

    func test_logOut_onError_doesNotPostNotification() async throws {
        let expectation = expectation(description: "stopLogoutButton called on error")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockNotifier.invokedPost)
    }

    func test_logOut_onError_doesNotDismiss() async throws {
        let expectation = expectation(description: "stopLogoutButton called on error")
        mockView.onStopLogoutButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.logOut()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedDismiss)
    }
}
