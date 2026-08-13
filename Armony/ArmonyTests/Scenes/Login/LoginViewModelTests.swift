//
//  LoginViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 13.08.26.
//

import XCTest
@testable import Armony

final class LoginViewModelTests: XCTestCase {

    var mockView: MockLoginView!
    var mockCoordinator: MockLoginCoordinatorProtocol!
    var mockService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockNotifier: MockNotificationCenter!
    var sut: LoginViewModel!

    override func setUpWithError() throws {
        mockView = MockLoginView()
        mockCoordinator = MockLoginCoordinatorProtocol()
        mockService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockNotifier = MockNotificationCenter()

        sut = LoginViewModel(
            view: mockView,
            loginCompletion: nil,
            registrationCompletion: nil,
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

    // MARK: - Helpers

    private func makeValidCredential() -> LoginCredential {
        return LoginCredential(email: "koray@test.com", password: "123456")
    }

    private func makeTokenResponse() -> RestObjectResponse<Token> {
        return mockService.load(fromJSONFile: "Login-Token-Sample",
                                type: RestObjectResponse<Token>.self)
    }

    private func makeEmptyResponse() -> RestObjectResponse<EmptyResponse> {
        return RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_callsConfigureUI() {
        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedConfigureUI)
    }

    func test_viewDidLoad_callsConfigureUIOnce() {
        sut.viewDidLoad()

        XCTAssertEqual(mockView.invokedConfigureUICount, 1)
    }

    func test_viewDidLoad_calledTwice_callsConfigureUITwice() {
        sut.viewDidLoad()
        sut.viewDidLoad()

        XCTAssertEqual(mockView.invokedConfigureUICount, 2)
    }

    // MARK: - login — validation

    func test_login_whenEmailIsEmpty_doesNotStartActivityIndicator() {
        let credential = LoginCredential(email: "", password: "123456")

        sut.login(with: credential)

        XCTAssertFalse(mockView.invokedStartLoginButtonActivityIndicator)
    }

    func test_login_whenPasswordIsEmpty_doesNotStartActivityIndicator() {
        let credential = LoginCredential(email: "koray@test.com", password: "")

        sut.login(with: credential)

        XCTAssertFalse(mockView.invokedStartLoginButtonActivityIndicator)
    }

    func test_login_whenBothEmpty_doesNotStartActivityIndicator() {
        let credential = LoginCredential(email: "", password: "")

        sut.login(with: credential)

        XCTAssertFalse(mockView.invokedStartLoginButtonActivityIndicator)
    }

    func test_login_whenValidCredential_startsActivityIndicator() {
        mockService.stubbedResults = [makeTokenResponse(), makeEmptyResponse()]

        sut.login(with: makeValidCredential())

        XCTAssertTrue(mockView.invokedStartLoginButtonActivityIndicator)
    }

    // MARK: - login — success

    func test_login_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.stubbedResults = [makeTokenResponse(), makeEmptyResponse()]

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopLoginButtonActivityIndicator)
    }

    func test_login_onSuccess_authenticatesUser() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.stubbedResults = [makeTokenResponse(), makeEmptyResponse()]

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockAuthenticator.invokedAuthenticate)
        XCTAssertEqual(mockAuthenticator.invokedAuthenticateParameters?.accessToken, "access-token-123")
        XCTAssertEqual(mockAuthenticator.invokedAuthenticateParameters?.refreshToken, "refresh-token-456")
        XCTAssertEqual(mockAuthenticator.invokedAuthenticateParameters?.userID, "user-789")
    }

    func test_login_onSuccess_postsUserLoggedInNotification() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.stubbedResults = [makeTokenResponse(), makeEmptyResponse()]

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockNotifier.invokedPost)
        XCTAssertEqual(mockNotifier.invokedPostParameters?.notification, .userLoggedIn)
    }

    func test_login_onSuccess_dismissesCoordinator() async throws {
        let expectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { expectation.fulfill() }
        mockService.stubbedResults = [makeTokenResponse(), makeEmptyResponse()]

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
        XCTAssertEqual(mockCoordinator.invokedDismissParameters?.animated, true)
    }

    func test_login_onSuccess_callsLoginCompletion() async throws {
        var completionCalled = false
        let expectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { expectation.fulfill() }
        mockService.stubbedResults = [makeTokenResponse(), makeEmptyResponse()]

        sut = LoginViewModel(
            view: mockView,
            loginCompletion: { completionCalled = true },
            registrationCompletion: nil,
            authenticator: mockAuthenticator,
            notifier: mockNotifier,
            service: mockService
        )
        sut.coordinator = mockCoordinator

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(completionCalled)
    }

    // MARK: - login — error

    func test_login_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopLoginButtonActivityIndicator)
    }

    func test_login_onError_doesNotAuthenticate() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockAuthenticator.invokedAuthenticate)
    }

    func test_login_onError_doesNotPostNotification() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockNotifier.invokedPost)
    }

    func test_login_onError_doesNotDismissCoordinator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopLoginButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.login(with: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedDismiss)
    }

    // MARK: - forgetPasswordButtonTapped

    func test_forgetPasswordButtonTapped_callsCoordinatorShowForgotPasswordView() {
        sut.forgetPasswordButtonTapped(email: "koray@test.com")

        XCTAssertTrue(mockCoordinator.invokedShowForgotPasswordView)
    }

    func test_forgetPasswordButtonTapped_passesEmailToCoordinator() {
        sut.forgetPasswordButtonTapped(email: "koray@test.com")

        XCTAssertEqual(mockCoordinator.invokedShowForgotPasswordViewParameters?.email, "koray@test.com")
    }

    // MARK: - init — completions

    func test_init_storesLoginCompletion() {
        var called = false
        let sut = LoginViewModel(
            view: mockView,
            loginCompletion: { called = true },
            registrationCompletion: nil,
            authenticator: mockAuthenticator,
            notifier: mockNotifier,
            service: mockService
        )

        sut.loginCompletion?()

        XCTAssertTrue(called)
    }

    func test_init_storesRegistrationCompletion() {
        var called = false
        let sut = LoginViewModel(
            view: mockView,
            loginCompletion: nil,
            registrationCompletion: { called = true },
            authenticator: mockAuthenticator,
            notifier: mockNotifier,
            service: mockService
        )

        sut.registrationCompletion?()

        XCTAssertTrue(called)
    }

    func test_init_nilLoginCompletion_isNil() {
        let sut = LoginViewModel(
            view: mockView,
            loginCompletion: nil,
            registrationCompletion: nil,
            authenticator: mockAuthenticator,
            notifier: mockNotifier,
            service: mockService
        )

        XCTAssertNil(sut.loginCompletion)
    }
}
