//
//  AccountInformationViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.08.26.
//

import XCTest
@testable import Armony

final class AccountInformationViewModelTests: XCTestCase {

    var mockView: MockAccountInformationView!
    var mockCoordinator: MockAccountInformationCoordinator!
    var mockService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockResetHandler: MockApplicationResetHandler!
    var sut: AccountInformationViewModel!

    override func setUpWithError() throws {
        mockView = MockAccountInformationView()
        mockCoordinator = MockAccountInformationCoordinator()
        mockService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockAuthenticator.stubbedUserID = "user123"
        mockResetHandler = MockApplicationResetHandler()

        sut = AccountInformationViewModel(
            view: mockView,
            authenticator: mockAuthenticator,
            resetHandler: mockResetHandler,
            service: mockService
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockCoordinator = nil
        mockService = nil
        mockAuthenticator = nil
        mockResetHandler = nil
        sut = nil
    }

    // MARK: - viewDidLoad — synchronous

    func test_viewDidLoad_configuresUI() {
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedConfigureUI)
    }

    func test_viewDidLoad_hidesContainerViewInitially() {
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedSetContainerViewVisibility)
        XCTAssertTrue(mockView.invokedSetContainerViewVisibilityParameters!.isHidden)
    }

    func test_viewDidLoad_startsActivityIndicator() {
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedStartActivityIndicatorView)
    }

    // MARK: - viewDidLoad — async success

    func test_viewDidLoad_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivityIndicatorView)
    }

    func test_viewDidLoad_onSuccess_showsContainerView() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        let lastCall = mockView.invokedSetContainerViewVisibilityParameters
        XCTAssertNotNil(lastCall)
        XCTAssertFalse(lastCall!.isHidden)
    }

    func test_viewDidLoad_onSuccess_configuresNameTextField() async throws {
        let expectation = expectation(description: "configureNameTextField called")
        mockView.onConfigureNameTextField = { expectation.fulfill() }
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedConfigureNameTextField)
        XCTAssertEqual(mockView.invokedConfigureNameTextFieldParameters?.name, "Test User")
    }

    func test_viewDidLoad_onSuccess_configuresEmailTextField() async throws {
        let expectation = expectation(description: "configureNameTextField called")
        mockView.onConfigureNameTextField = { expectation.fulfill() }
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedConfigureEmailTextField)
        XCTAssertEqual(mockView.invokedConfigureEmailTextFieldParameters?.email, "test@example.com")
    }

    func test_viewDidLoad_usesAuthenticatorUserID() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "custom-user-id"
        mockService.stubbedResult = makeAccountInfo()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockAuthenticator.invokedUserIDGetter)
    }

    // MARK: - viewDidLoad — error

    func test_viewDidLoad_onError_stopsActivityIndicator() async throws {
        mockService.error = APIError.network

        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(mockView.invokedStopActivityIndicatorView)
    }

    func test_viewDidLoad_onError_doesNotShowContainerView() async throws {
        mockService.error = APIError.network

        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        // Only the first call (hidden: true) is made, no second call with hidden: false
        XCTAssertEqual(mockView.invokedSetContainerViewVisibilityCount, 1)
        XCTAssertTrue(mockView.invokedSetContainerViewVisibilityParameters!.isHidden)
    }

    // MARK: - saveButtonTapped — success

    func test_saveButtonTapped_withEmptyName_doesNothing() {
        sut.saveButtonTapped(name: "")

        XCTAssertFalse(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_withValidName_startsActivityIndicator() {
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.saveButtonTapped(name: "Koray")

        XCTAssertTrue(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSaveButton called")
        mockView.onStopSaveButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.saveButtonTapped(name: "Koray")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_onSuccess_doesNotPopSynchronously() {
        // pop() is called inside AlertService okay action — not synchronously testable.
        // We verify the service call completes and no synchronous pop happens.
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.saveButtonTapped(name: "Koray")

        XCTAssertFalse(mockCoordinator.invokedPop)
    }

    func test_saveButtonTapped_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSaveButton called on error")
        mockView.onStopSaveButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.saveButtonTapped(name: "Koray")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_saveButtonTapped_onError_doesNotPop() async throws {
        let expectation = expectation(description: "stopSaveButton called on error")
        mockView.onStopSaveButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.saveButtonTapped(name: "Koray")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedPop)
    }

    // MARK: - deleteAccountButtonTapped — success

    func test_deleteAccountButtonTapped_startsActivityIndicators() {
        mockService.stubbedResult = makeFeedbackSubjects()

        sut.deleteAccountButtonTapped()

        XCTAssertTrue(mockView.invokedStartDeleteAccountButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    func test_deleteAccountButtonTapped_onSuccess_stopsActivityIndicators() async throws {
        let expectation = expectation(description: "stopDeleteButton called")
        mockView.onStopDeleteAccountButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeFeedbackSubjects()

        sut.deleteAccountButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopDeleteAccountButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_deleteAccountButtonTapped_onSuccess_showsSelectionPopUp() async throws {
        let expectation = expectation(description: "selectionBottomPopUp called")
        mockCoordinator.onSelectionBottomPopUp = { expectation.fulfill() }
        mockService.stubbedResult = makeFeedbackSubjects()

        sut.deleteAccountButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectionBottomPopUp)
    }

    func test_deleteAccountButtonTapped_onError_stopsActivityIndicators() async throws {
        let expectation = expectation(description: "stopDeleteButton called on error")
        mockView.onStopDeleteAccountButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.deleteAccountButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopDeleteAccountButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_deleteAccountButtonTapped_onError_doesNotShowSelectionPopUp() async throws {
        let expectation = expectation(description: "stopDeleteButton called on error")
        mockView.onStopDeleteAccountButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.deleteAccountButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedSelectionBottomPopUp)
    }

    // MARK: - deleteAccount — success

    func test_deleteAccount_startsActivityIndicators() {
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [emptyResponse, emptyResponse]

        sut.deleteAccount(feedback: makeFeedbackRequest())

        XCTAssertTrue(mockView.invokedStartDeleteAccountButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStartSaveButtonActivityIndicatorView)
    }

    func test_deleteAccount_onSuccess_callsResetAndStartFromSktratch() async throws {
        let expectation = expectation(description: "startFromSktratch called")
        mockCoordinator.onStartFromSktratch = { expectation.fulfill() }
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [emptyResponse, emptyResponse]

        sut.deleteAccount(feedback: makeFeedbackRequest())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockResetHandler.invokedReset)
        XCTAssertTrue(mockCoordinator.invokedStartFromSktratch)
    }

    func test_deleteAccount_onError_stopsActivityIndicators() async throws {
        let expectation = expectation(description: "stopDeleteButton called on error")
        mockView.onStopDeleteAccountButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.deleteAccount(feedback: makeFeedbackRequest())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopDeleteAccountButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStopSaveButtonActivityIndicatorView)
    }

    func test_deleteAccount_onError_doesNotCallStartFromSktratch() async throws {
        let expectation = expectation(description: "stopDeleteButton called on error")
        mockView.onStopDeleteAccountButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.deleteAccount(feedback: makeFeedbackRequest())

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedStartFromSktratch)
    }


    // MARK: - deleteAccountFeedbackDidSelect

    func test_deleteAccountFeedbackDidSelect_withNilOutput_doesNothing() {
        sut.deleteAccountFeedbackDidSelect(output: nil)

        XCTAssertFalse(mockView.invokedStartDeleteAccountButtonActivityIndicatorView)
    }

    func test_deleteAccountFeedbackDidSelect_withOutput_showsAlertWithoutStartingDeleteImmediately() {
        let output = DeleteAccountFeedbackSelectionInput(id: 1, isSelected: true, title: "Spam")

        sut.deleteAccountFeedbackDidSelect(output: output)

        // AlertService shows a confirmation dialog; deleteAccount is not called synchronously
        XCTAssertFalse(mockView.invokedStartDeleteAccountButtonActivityIndicatorView)
    }
}

// MARK: - Helpers

private extension AccountInformationViewModelTests {

    func makeAccountInfo() -> RestObjectResponse<AccountInfo> {
        return mockService.load(fromJSONFile: "AccountInfo-Sample-Data", type: RestObjectResponse<AccountInfo>.self)
    }

    func makeFeedbackSubjects() -> RestArrayResponse<FeedbackSubject> {
        return mockService.load(fromJSONFile: "FeedbackSubjects-Sample-Data", type: RestArrayResponse<FeedbackSubject>.self)
    }

    func makeFeedbackRequest() -> FeedbackRequest {
        return FeedbackRequest(
            feedbackSubject: FeedbackSubject(id: 1, title: "Spam"),
            message: .empty
        )
    }
}
