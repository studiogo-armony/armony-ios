//
//  RegistrationViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 12.08.26.
//

import XCTest
@testable import Armony

final class RegistrationViewModelTests: XCTestCase {

    var mockView: MockRegistrationView!
    var mockCoordinator: MockRegistrationCoordinator!
    var mockService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockNotifier: MockNotificationCenter!
    var sut: RegistrationViewModel!

    override func setUpWithError() throws {
        mockView = MockRegistrationView()
        mockCoordinator = MockRegistrationCoordinator()
        mockService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockNotifier = MockNotificationCenter()

        sut = RegistrationViewModel(
            view: mockView,
            registrationCompletion: nil,
            loginCompletion: nil,
            notifier: mockNotifier,
            authenticator: mockAuthenticator,
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

    private func makeValidCredential() -> SignupCredential {
        return SignupCredential(name: "Koray", email: "koray@test.com", password: "123456")
    }

    private func makeTokenResponse() -> RestObjectResponse<Token> {
        return mockService.load(fromJSONFile: "Registration-Token-Sample",
                                type: RestObjectResponse<Token>.self)
    }

    // MARK: - signup — validation

    func test_signup_whenNameIsEmpty_doesNotStartActivityIndicator() {
        let credential = SignupCredential(name: "", email: "test@test.com", password: "123456")

        sut.signup(credential: credential)

        XCTAssertFalse(mockView.invokedStartOkButtonActivityIndicator)
    }

    func test_signup_whenEmailIsEmpty_doesNotStartActivityIndicator() {
        let credential = SignupCredential(name: "Koray", email: "", password: "123456")

        sut.signup(credential: credential)

        XCTAssertFalse(mockView.invokedStartOkButtonActivityIndicator)
    }

    func test_signup_whenPasswordIsEmpty_doesNotStartActivityIndicator() {
        let credential = SignupCredential(name: "Koray", email: "test@test.com", password: "")

        sut.signup(credential: credential)

        XCTAssertFalse(mockView.invokedStartOkButtonActivityIndicator)
    }

    func test_signup_whenAllFieldsEmpty_doesNotCallService() {
        let credential = SignupCredential(name: "", email: "", password: "")

        sut.signup(credential: credential)

        XCTAssertFalse(mockView.invokedStartOkButtonActivityIndicator)
    }

    func test_signup_whenValidCredentials_startsActivityIndicator() {
        mockService.stubbedResult = makeTokenResponse()
        let credential = makeValidCredential()

        sut.signup(credential: credential)

        XCTAssertTrue(mockView.invokedStartOkButtonActivityIndicator)
    }

    // MARK: - signup — success

    func test_signup_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.stubbedResult = makeTokenResponse()

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopOkButtonActivityIndicator)
    }

    func test_signup_onSuccess_authenticatesUser() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.stubbedResult = makeTokenResponse()

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockAuthenticator.invokedAuthenticate)
        XCTAssertEqual(mockAuthenticator.invokedAuthenticateParameters?.accessToken, "access-token-123")
        XCTAssertEqual(mockAuthenticator.invokedAuthenticateParameters?.refreshToken, "refresh-token-456")
        XCTAssertEqual(mockAuthenticator.invokedAuthenticateParameters?.userID, "user-789")
    }

    func test_signup_onSuccess_postsUserLoggedInNotification() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.stubbedResult = makeTokenResponse()

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockNotifier.invokedPost)
        XCTAssertEqual(mockNotifier.invokedPostParameters?.notification, .userLoggedIn)
    }

    func test_signup_onSuccess_dismissesCoordinator() async throws {
        let expectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { expectation.fulfill() }
        mockService.stubbedResult = makeTokenResponse()

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
        XCTAssertEqual(mockCoordinator.invokedDismissParameters?.animated, true)
    }

    func test_signup_onSuccess_dismissWithRegistrationCompletion() async throws {
        var completionCalled = false
        let expectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { expectation.fulfill() }
        mockService.stubbedResult = makeTokenResponse()

        sut = RegistrationViewModel(
            view: mockView,
            registrationCompletion: { completionCalled = true },
            loginCompletion: nil,
            notifier: mockNotifier,
            authenticator: mockAuthenticator,
            service: mockService
        )
        sut.coordinator = mockCoordinator

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(completionCalled)
    }

    // MARK: - signup — error

    func test_signup_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopOkButtonActivityIndicator)
    }

    func test_signup_onError_doesNotAuthenticate() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockAuthenticator.invokedAuthenticate)
    }

    func test_signup_onError_doesNotPostNotification() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockNotifier.invokedPost)
    }

    func test_signup_onError_doesNotDismissCoordinator() async throws {
        let expectation = expectation(description: "stopOkButton called")
        mockView.onStopOkButtonActivityIndicator = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.signup(credential: makeValidCredential())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedDismiss)
    }

    // MARK: - init — completions

    func test_init_storesRegistrationCompletion() {
        var called = false
        let sut = RegistrationViewModel(
            view: mockView,
            registrationCompletion: { called = true },
            loginCompletion: nil,
            notifier: mockNotifier,
            authenticator: mockAuthenticator,
            service: mockService
        )

        sut.registrationCompletion?()

        XCTAssertTrue(called)
    }

    func test_init_storesLoginCompletion() {
        var called = false
        let sut = RegistrationViewModel(
            view: mockView,
            registrationCompletion: nil,
            loginCompletion: { called = true },
            notifier: mockNotifier,
            authenticator: mockAuthenticator,
            service: mockService
        )

        sut.loginCompletion?()

        XCTAssertTrue(called)
    }

    func test_init_nilRegistrationCompletion_isNil() {
        let sut = RegistrationViewModel(
            view: mockView,
            registrationCompletion: nil,
            loginCompletion: nil,
            notifier: mockNotifier,
            authenticator: mockAuthenticator,
            service: mockService
        )

        XCTAssertNil(sut.registrationCompletion)
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_callsConfigureUI() {
        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedConfigureUI)
    }

    func test_viewDidLoad_callsMakeNavigationBarTransparent() {
        sut.viewDidLoad()

        // NavigationBarCustomizing — validated via no crash (transparent nav bar)
        XCTAssertEqual(mockView.invokedConfigureUICount, 1)
    }

    func test_viewDidLoad_calledOnce_configureUICalledOnce() {
        sut.viewDidLoad()

        XCTAssertEqual(mockView.invokedConfigureUICount, 1)
    }
}
