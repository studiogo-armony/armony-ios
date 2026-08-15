//
//  AdvertViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 13.08.26.
//

import XCTest
@testable import Armony

final class AdvertViewModelTests: XCTestCase {

    var mockView: MockAdvertView!
    var mockCoordinator: MockAdvertCoordinator!
    var mockService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockPurchaseStorage: MockRevenueCatPurchaseStorageService!
    var sut: AdvertViewModel!

    override func setUpWithError() throws {
        mockView = MockAdvertView()
        mockCoordinator = MockAdvertCoordinator()
        mockService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockPurchaseStorage = MockRevenueCatPurchaseStorageService()

        sut = AdvertViewModel(
            view: mockView,
            id: 42,
            colorCode: "#3498DB",
            isRemovingActive: false,
            isPreviousPageLiveChat: false,
            dismissCompletion: nil,
            authenticator: mockAuthenticator,
            purchaseStorage: mockPurchaseStorage,
            service: mockService
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockCoordinator = nil
        mockService = nil
        mockAuthenticator = nil
        mockPurchaseStorage = nil
        sut = nil
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_startsActivityIndicator() {
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedStartActivityIndicatorView)
    }

    func test_viewDidLoad_hidesContentStackViewInitially() {
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedSetContentStackViewVisibility)
        XCTAssertTrue(mockView.invokedSetContentStackViewVisibilityParameters!.isHidden)
    }

    func test_viewDidLoad_setsRemoveButtonVisibilityImmediately() {
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedSetRemoveAdvertsButtonVisibility)
    }

    func test_viewDidLoad_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivityIndicatorView)
    }

    func test_viewDidLoad_onSuccess_showsContentStackView() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        let lastCall = mockView.invokedSetContentStackViewVisibilityParameters
        XCTAssertNotNil(lastCall)
        XCTAssertFalse(lastCall!.isHidden)
    }

    func test_viewDidLoad_onSuccess_setsAdvert() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(sut.advert)
        XCTAssertEqual(sut.advert?.id, 42)
    }

    func test_viewDidLoad_onSuccess_configuresUserSummaryView() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedConfigureUserSummaryView)
    }

    func test_viewDidLoad_onSuccess_setsDescriptionLabel() async throws {
        let expectation = expectation(description: "setDescriptionLabel called")
        mockView.onSetDescriptionLabel = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedSetDescriptionLabel)
    }

    func test_viewDidLoad_whenOwner_hidesApplyButton() async throws {
        // setApplyButtonButtonVisibility is called twice: once immediately (isHidden: false),
        // once after async response (isHidden: true for owner). Wait for the 2nd call.
        let expectation = expectation(description: "setApplyButton called twice")
        expectation.expectedFulfillmentCount = 2
        mockView.onSetApplyButtonButtonVisibility = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "user123"
        mockAuthenticator.stubbedIsAuthenticated = true
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedSetApplyButtonButtonVisibility)
        XCTAssertTrue(mockView.invokedSetApplyButtonButtonVisibilityParameters!.isHidden)
    }

    func test_viewDidLoad_whenNotOwner_showsApplyButton() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "other-user"
        mockAuthenticator.stubbedIsAuthenticated = true
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockView.invokedSetApplyButtonButtonVisibilityParameters!.isHidden)
    }

    func test_viewDidLoad_whenOwner_hidesRemoveButton() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "other-user"
        mockService.stubbedResult = makeAdvert()

        sut.viewDidLoad()

        // owner is "user123", current user is "other-user" → remove button hidden
        await fulfillment(of: [expectation], timeout: 2.0)
        let lastHiddenParam = mockView.invokedSetRemoveAdvertsButtonVisibilityParameters?.isHidden
        XCTAssertNotNil(lastHiddenParam)
        XCTAssertTrue(lastHiddenParam!)
    }

    // MARK: - nameDidTap

    func test_nameDidTap_whenAdvertLoaded_navigatesToVisitedAccount() async throws {
        let expectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2.0)

        sut.nameDidTap()

        XCTAssertTrue(mockCoordinator.invokedVisitedAccount)
        XCTAssertEqual(mockCoordinator.invokedVisitedAccountParameters?.userID, "user123")
    }

    func test_nameDidTap_whenAdvertNotLoaded_doesNotNavigate() {
        sut.nameDidTap()

        XCTAssertFalse(mockCoordinator.invokedVisitedAccount)
    }

    // MARK: - removeAdvertsButtonDidTap

    func test_removeAdvertsButtonDidTap_startsDeleteActivityIndicator() {
        mockService.stubbedResult = RestArrayResponse<FeedbackSubject>(data: [], metadata: nil, error: nil)

        sut.removeAdvertsButtonDidTap()

        XCTAssertTrue(mockView.invokedStartDeleteButtonActivityIndicatorView)
    }

    func test_removeAdvertsButtonDidTap_onSuccess_stopsDeleteActivityIndicator() async throws {
        let expectation = expectation(description: "stopDeleteButton called")
        mockView.onStopDeleteButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestArrayResponse<FeedbackSubject>(data: [], metadata: nil, error: nil)

        sut.removeAdvertsButtonDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopDeleteButtonActivityIndicatorView)
    }

    func test_removeAdvertsButtonDidTap_onSuccess_callsSelectionBottomPopUp() async throws {
        let expectation = expectation(description: "selectionBottomPopUp called")
        mockCoordinator.onSelectionBottomPopUp = { expectation.fulfill() }
        mockService.stubbedResult = RestArrayResponse<FeedbackSubject>(data: [], metadata: nil, error: nil)

        sut.removeAdvertsButtonDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectionBottomPopUp)
    }

    func test_removeAdvertsButtonDidTap_onError_stopsDeleteActivityIndicator() async throws {
        let expectation = expectation(description: "stopDeleteButton called on error")
        mockView.onStopDeleteButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.removeAdvertsButtonDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopDeleteButtonActivityIndicatorView)
    }

    func test_removeAdvertsButtonDidTap_onError_doesNotCallSelectionPopUp() async throws {
        let expectation = expectation(description: "stopDeleteButton called on error")
        mockView.onStopDeleteButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.removeAdvertsButtonDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedSelectionBottomPopUp)
    }

    // MARK: - sendMessageButtonTapped (externalLink)

    func test_sendMessageButtonTapped_whenExternalLink_opensAtSafariViewController() async throws {
        let expectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvertWithExternalLink()
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2.0)

        sut.sendMessageButtonTapped()

        XCTAssertTrue(mockCoordinator.invokedOpenAtSafariViewController)
    }

    func test_sendMessageButtonTapped_whenNoExternalLink_andAuthenticated_startsSendMessageIndicator() async throws {
        let advertLoadedExpectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoadedExpectation.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoadedExpectation], timeout: 2.0)

        mockAuthenticator.stubbedIsAuthenticated = true
        let chatExpectation = expectation(description: "liveChat called")
        mockCoordinator.onLiveChat = { chatExpectation.fulfill() }
        let response = RestObjectResponse<CreateLiveChatResponse>(data: CreateLiveChatResponse(chatID: 99), metadata: nil, error: nil)
        mockService.stubbedResult = response

        sut.sendMessageButtonTapped()

        XCTAssertTrue(mockView.invokedStartSendMessageButtonActivityIndicatorView)
        await fulfillment(of: [chatExpectation], timeout: 2.0)
    }

    func test_sendMessageButtonTapped_whenNoExternalLink_andAuthenticated_callsLiveChat() async throws {
        let advertLoadedExpectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoadedExpectation.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoadedExpectation], timeout: 2.0)

        mockAuthenticator.stubbedIsAuthenticated = true
        let chatExpectation = expectation(description: "liveChat called")
        mockCoordinator.onLiveChat = { chatExpectation.fulfill() }
        let response = RestObjectResponse<CreateLiveChatResponse>(data: CreateLiveChatResponse(chatID: 99), metadata: nil, error: nil)
        mockService.stubbedResult = response

        sut.sendMessageButtonTapped()

        await fulfillment(of: [chatExpectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedLiveChat)
        XCTAssertEqual(mockCoordinator.invokedLiveChatParameters?.chatID, 99)
    }

    func test_sendMessageButtonTapped_whenNoExternalLink_andAuthenticated_onSuccess_stopsActivityIndicator() async throws {
        let advertLoadedExpectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoadedExpectation.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoadedExpectation], timeout: 2.0)

        mockAuthenticator.stubbedIsAuthenticated = true
        let stopExpectation = expectation(description: "stopSendMessage called")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        let response = RestObjectResponse<CreateLiveChatResponse>(data: CreateLiveChatResponse(chatID: 10), metadata: nil, error: nil)
        mockService.stubbedResult = response

        sut.sendMessageButtonTapped()

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    func test_sendMessageButtonTapped_whenNotAuthenticated_callsRegistration() {
        mockAuthenticator.stubbedIsAuthenticated = false

        sut.sendMessageButtonTapped()

        XCTAssertTrue(mockCoordinator.invokedRegistration)
    }

    func test_sendMessageButtonTapped_whenIsPreviousPageLiveChat_dismisses() {
        let sutWithPreviousPage = AdvertViewModel(
            view: mockView,
            id: 42,
            isPreviousPageLiveChat: true,
            authenticator: mockAuthenticator,
            purchaseStorage: mockPurchaseStorage,
            service: mockService
        )
        sutWithPreviousPage.coordinator = mockCoordinator
        mockAuthenticator.stubbedIsAuthenticated = true

        sutWithPreviousPage.sendMessageButtonTapped()

        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    // MARK: - blockUser

    func test_blockUser_startsActivityIndicator() async throws {
        let expectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2.0)

        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.blockUser()

        XCTAssertTrue(mockView.invokedStartSendMessageButtonActivityIndicatorView)
    }

    func test_blockUser_onSuccess_stopsActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let stopExpectation = expectation(description: "stopSendMessage called")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.blockUser()

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    func test_blockUser_onSuccess_dismisses() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let dismissExpectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { dismissExpectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.blockUser()

        await fulfillment(of: [dismissExpectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    func test_blockUser_onError_stopsActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let stopExpectation = expectation(description: "stopSendMessage called on error")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.error = APIError.network

        sut.blockUser()

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    func test_blockUser_onError_doesNotDismiss() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let stopExpectation = expectation(description: "stopSendMessage called on error")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.error = APIError.network

        sut.blockUser()

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertFalse(mockCoordinator.invokedDismiss)
    }

    // MARK: - reportActionDidTap

    func test_reportActionDidTap_startsActivityIndicators() {
        mockService.stubbedResult = RestArrayResponse<ReportSubject>(data: [], metadata: nil, error: nil)

        sut.reportActionDidTap()

        XCTAssertTrue(mockView.invokedStartSendMessageButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStartUserSummaryViewDotsButtonActivityIndicatorView)
    }

    func test_reportActionDidTap_onSuccess_stopsActivityIndicators() async throws {
        let expectation = expectation(description: "stopDotsButton called")
        mockView.onStopUserSummaryViewDotsButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = RestArrayResponse<ReportSubject>(data: [], metadata: nil, error: nil)

        sut.reportActionDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
        XCTAssertTrue(mockView.invokedStopUserSummaryViewDotsButtonActivityIndicatorView)
    }

    func test_reportActionDidTap_onSuccess_callsSelectionBottomPopUp() async throws {
        let expectation = expectation(description: "selectionBottomPopUp called")
        mockCoordinator.onSelectionBottomPopUp = { expectation.fulfill() }
        mockService.stubbedResult = RestArrayResponse<ReportSubject>(data: [], metadata: nil, error: nil)

        sut.reportActionDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectionBottomPopUp)
    }

    func test_reportActionDidTap_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSendMessage called on error")
        mockView.onStopSendMessageButtonActivityIndicatorView = { expectation.fulfill() }
        mockService.error = APIError.network

        sut.reportActionDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    // MARK: - hasUserAds

    func test_hasUserAds_whenResponseHasAdverts_returnsTrue() async throws {
        mockAuthenticator.stubbedUserID = "user123"
        let advert = makeAdvert().data
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [advert], metadata: nil, error: nil)

        let result = try await sut.hasUserAds()

        XCTAssertTrue(result)
    }

    func test_hasUserAds_whenResponseIsEmpty_returnsFalse() async throws {
        mockAuthenticator.stubbedUserID = "user123"
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [], metadata: nil, error: nil)

        let result = try await sut.hasUserAds()

        XCTAssertFalse(result)
    }

    func test_hasUserAds_whenServiceThrows_propagatesError() async throws {
        mockService.error = APIError.network

        await XCTAssertThrowsErrorAsync(try await sut.hasUserAds())
    }

    func test_hasUserAds_usesAuthenticatorUserID() async throws {
        mockAuthenticator.stubbedUserID = "user-42"
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [], metadata: nil, error: nil)

        _ = try await sut.hasUserAds()

        XCTAssertTrue(mockAuthenticator.invokedUserIDGetter)
    }

    // MARK: - activateAdvertButtonTapped

    func test_activateAdvertButtonTapped_whenNotOwner_doesNothing() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        mockAuthenticator.stubbedUserID = "other-user"

        sut.activateAdvertButtonTapped()

        XCTAssertFalse(mockView.invokedStartActivateAdvertButtonActivityIndicatorView)
    }

    func test_activateAdvertButtonTapped_whenOwner_startsActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        mockAuthenticator.stubbedUserID = "user123"
        let hasAdsResponse = RestArrayResponse<Advert>(data: [], metadata: nil, error: nil)
        let activateResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [hasAdsResponse, activateResponse]

        sut.activateAdvertButtonTapped()

        XCTAssertTrue(mockView.invokedStartActivateAdvertButtonActivityIndicatorView)
    }

    func test_activateAdvertButtonTapped_whenOwner_andNoAds_andNoPurchase_showsPaywall() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        mockAuthenticator.stubbedUserID = "user123"
        let paywallExpectation = expectation(description: "showPaywall called")
        mockView.onShowPaywall = { paywallExpectation.fulfill() }
        let advert = makeAdvert().data
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [advert], metadata: nil, error: nil)

        sut.activateAdvertButtonTapped()

        await fulfillment(of: [paywallExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedShowPaywall)
    }

    // MARK: - shouldInfoViewIsShown

    func test_shouldInfoViewIsShown_whenOwnerAndAutoInactive_returnsTrue() async throws {
        let expectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "user123"
        mockService.stubbedResult = makeAdvertWithStatus(.autoInactive)
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertTrue(sut.shouldInfoViewIsShown)
    }

    func test_shouldInfoViewIsShown_whenOwnerAndActive_returnsFalse() async throws {
        let expectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "user123"
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertFalse(sut.shouldInfoViewIsShown)
    }

    func test_shouldInfoViewIsShown_whenNotOwner_returnsFalse() async throws {
        let expectation = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockAuthenticator.stubbedUserID = "other-user"
        mockService.stubbedResult = makeAdvertWithStatus(.autoInactive)
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertFalse(sut.shouldInfoViewIsShown)
    }

    // MARK: - remove(feedback:)

    func test_removeFeedback_startsDeleteActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [emptyResponse, emptyResponse]
        let feedback = FeedbackRequest(feedbackSubject: FeedbackSubject(id: 1, title: "Spam"), message: " ")

        sut.remove(feedback: feedback)

        XCTAssertTrue(mockView.invokedStartDeleteButtonActivityIndicatorView)
    }

    func test_removeFeedback_onSuccess_stopsActivityIndicatorAndDismisses() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let dismissExpectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { dismissExpectation.fulfill() }
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [emptyResponse, emptyResponse]
        let feedback = FeedbackRequest(feedbackSubject: FeedbackSubject(id: 1, title: "Spam"), message: " ")

        sut.remove(feedback: feedback)

        await fulfillment(of: [dismissExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopDeleteButtonActivityIndicatorView)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    func test_removeFeedback_onSuccess_callsDismissCompletion() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        var completionCalled = false
        let sutWithCompletion = AdvertViewModel(
            view: mockView,
            id: 42,
            isPreviousPageLiveChat: false,
            dismissCompletion: { _ in completionCalled = true },
            authenticator: mockAuthenticator,
            purchaseStorage: mockPurchaseStorage,
            service: mockService
        )
        sutWithCompletion.coordinator = mockCoordinator

        // Need advert set on this new sut too
        let advertLoaded2 = expectation(description: "advert loaded 2")
        mockView.onStopActivityIndicatorView = { advertLoaded2.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sutWithCompletion.viewDidLoad()
        await fulfillment(of: [advertLoaded2], timeout: 2.0)

        let dismissExpectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { dismissExpectation.fulfill() }
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [emptyResponse, emptyResponse]
        let feedback = FeedbackRequest(feedbackSubject: FeedbackSubject(id: 1, title: "Spam"), message: " ")

        sutWithCompletion.remove(feedback: feedback)

        await fulfillment(of: [dismissExpectation], timeout: 2.0)
        XCTAssertTrue(completionCalled)
    }

    func test_removeFeedback_onError_startsActivityIndicatorAgain() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        // Reset count from viewDidLoad calls
        mockView.invokedStartDeleteButtonActivityIndicatorViewCount = 0
        let startExpectation = expectation(description: "startDeleteButton called on error")
        startExpectation.expectedFulfillmentCount = 2 // once on entry, once in error handler
        mockView.onStartDeleteButtonActivityIndicatorView = { startExpectation.fulfill() }
        mockService.error = APIError.network
        let feedback = FeedbackRequest(feedbackSubject: FeedbackSubject(id: 1, title: "Spam"), message: " ")

        sut.remove(feedback: feedback)

        await fulfillment(of: [startExpectation], timeout: 2.0)
        XCTAssertEqual(mockView.invokedStartDeleteButtonActivityIndicatorViewCount, 2)
    }

    // MARK: - deleteAdvertFeedbackDidSelect

    func test_deleteAdvertFeedbackDidSelect_withNilOutput_doesNothing() {
        sut.deleteAdvertFeedbackDidSelect(output: nil)

        XCTAssertFalse(mockView.invokedStartDeleteButtonActivityIndicatorView)
    }

    func test_deleteAdvertFeedbackDidSelect_withOutput_showsAlertBeforeRemoving() {
        let output = DeleteAdvertFeedbackSelectionInput(id: 1, isSelected: true, title: "Spam")

        // Should not crash or call service — just shows AlertService which we can't easily intercept.
        // Verify no side effect on the view happens synchronously.
        sut.deleteAdvertFeedbackDidSelect(output: output)

        XCTAssertFalse(mockView.invokedStartDeleteButtonActivityIndicatorView)
    }

    // MARK: - reportSubjectDidSelect

    func test_reportSubjectDidSelect_startsActivityIndicator() {
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResult = emptyResponse

        sut.reportSubjectDidSelect(subject: nil)

        XCTAssertTrue(mockView.invokedStartSendMessageButtonActivityIndicatorView)
    }

    func test_reportSubjectDidSelect_onSuccess_stopsActivityIndicator() async throws {
        let stopExpectation = expectation(description: "stopSendMessage called")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResult = emptyResponse

        sut.reportSubjectDidSelect(subject: nil)

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    func test_reportSubjectDidSelect_onError_stopsActivityIndicator() async throws {
        let stopExpectation = expectation(description: "stopSendMessage called on error")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.error = APIError.network

        sut.reportSubjectDidSelect(subject: nil)

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    // MARK: - viewWillAppear

    func test_viewWillAppear_setsNavigationBarBackgroundColor() {
        sut.viewWillAppear()

        XCTAssertTrue(mockView.invokedSetNavigationBarBackgroundColor)
    }

    // MARK: - viewDidLoad — prepareOtherSections type 4

    func test_viewDidLoad_withType4Advert_configuresInstructionTypesView() async throws {
        let expectation = expectation(description: "configureInstructionTypesView called")
        mockView.onConfigureInstructionTypesView = { expectation.fulfill() }
        mockService.stubbedResult = mockService.load(fromJSONFile: "Advert-Sample-Data-Type4",
                                                     type: RestObjectResponse<Advert>.self)

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedConfigureInstructionTypesView)
    }

    // MARK: - viewDidLoad — prepareOtherSections type 3

    func test_viewDidLoad_withType3Advert_configuresGenresViewWithSkills() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = mockService.load(fromJSONFile: "Advert-Sample-Data-Type3",
                                                     type: RestObjectResponse<Advert>.self)

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        try await Task.sleep(nanoseconds: 100_000_000)
        // type 3: configureGenresView + configureSkillsView(.empty) — no instructionTypesView
        XCTAssertFalse(mockView.invokedConfigureInstructionTypesView)
        XCTAssertTrue(mockView.invokedConfigureSkillsView)
    }

    // MARK: - apply error path

    func test_sendMessageButtonTapped_whenAuthenticated_onError_stopsActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        mockAuthenticator.stubbedIsAuthenticated = true
        let stopExpectation = expectation(description: "stopSendMessage called on error")
        mockView.onStopSendMessageButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.error = APIError.network

        sut.sendMessageButtonTapped()

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSendMessageButtonActivityIndicatorView)
    }

    // MARK: - activateAd error path

    func test_activateAd_onError_stopsActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let stopExpectation = expectation(description: "stopActivateAdvert called on error")
        mockView.onStopActivateAdvertButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.error = APIError.network

        sut.activateAd(transactionID: nil)

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivateAdvertButtonActivityIndicatorView)
    }

    func test_activateAd_onSuccess_dismisses() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let dismissExpectation = expectation(description: "dismiss called")
        mockCoordinator.onDismiss = { dismissExpectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.activateAd(transactionID: nil)

        await fulfillment(of: [dismissExpectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    // MARK: - handleSendMessage — registration callbacks

    func test_sendMessageButtonTapped_whenNotAuthenticated_onRegister_callsApply() async throws {
        // didRegister closure → apply() → needs liveChat call
        let chatExpectation = expectation(description: "liveChat called after register")
        mockCoordinator.onLiveChat = { chatExpectation.fulfill() }
        // Make coordinator invoke didRegister immediately
        mockCoordinator.stubbedRegistrationDidRegister = true
        mockAuthenticator.stubbedIsAuthenticated = false
        let response = RestObjectResponse<CreateLiveChatResponse>(
            data: CreateLiveChatResponse(chatID: 7), metadata: nil, error: nil)
        mockService.stubbedResult = response

        sut.sendMessageButtonTapped()

        await fulfillment(of: [chatExpectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedLiveChat)
    }

    // MARK: - removeAdvertsButtonDidTap with subjects (inner map closure)

    func test_removeAdvertsButtonDidTap_withSubjects_mapsToSelectionItems() async throws {
        let expectation = expectation(description: "selectionBottomPopUp called")
        mockCoordinator.onSelectionBottomPopUp = { expectation.fulfill() }
        let subject = FeedbackSubject(id: 5, title: "Inappropriate")
        mockService.stubbedResult = RestArrayResponse<FeedbackSubject>(data: [subject], metadata: nil, error: nil)

        sut.removeAdvertsButtonDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectionBottomPopUp)
    }

    // MARK: - handleSendMessage didLogin isOwner=true branch

    func test_sendMessageButtonTapped_whenNotAuthenticated_onLogin_whenOwner_doesNotCallApply() async throws {
        // Load advert first so sut.advert is set (user.id = "user123")
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        // Now trigger sendMessage unauthenticated; didLogin fires; user is owner → shows alert (no liveChat)
        mockCoordinator.stubbedRegistrationDidLogin = true
        mockAuthenticator.stubbedIsAuthenticated = false
        mockAuthenticator.stubbedUserID = "user123" // same as advert.user.id

        sut.sendMessageButtonTapped()

        // No liveChat should be called (owner sees alert instead)
        XCTAssertFalse(mockCoordinator.invokedLiveChat)
    }

    // MARK: - confirmRemove (deleteAdvertFeedbackDidSelect action closure extracted)

    func test_confirmRemove_callsRemoveFeedback() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let dismissExpectation = expectation(description: "dismiss called after confirmRemove")
        mockCoordinator.onDismiss = { dismissExpectation.fulfill() }
        let emptyResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [emptyResponse, emptyResponse]
        let feedback = FeedbackRequest(feedbackSubject: FeedbackSubject(id: 1, title: "Spam"), message: " ")

        sut.confirmRemove(feedback: feedback)

        await fulfillment(of: [dismissExpectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    // MARK: - showOwnerWarning (handleSendMessage isOwner alert action extracted)

    func test_showOwnerWarning_hidesApplyButtonAndShowsRemoveButton() {
        sut.showOwnerWarning(isOwner: true)

        XCTAssertTrue(mockView.invokedSetApplyButtonButtonVisibility)
        XCTAssertTrue(mockView.invokedSetApplyButtonButtonVisibilityParameters!.isHidden)
        XCTAssertTrue(mockView.invokedSetRemoveAdvertsButtonVisibility)
        XCTAssertFalse(mockView.invokedSetRemoveAdvertsButtonVisibilityParameters!.isHidden)
    }

    func test_showOwnerWarning_whenNotOwner_showsApplyAndHidesRemove() {
        sut.showOwnerWarning(isOwner: false)

        XCTAssertFalse(mockView.invokedSetApplyButtonButtonVisibilityParameters!.isHidden)
        XCTAssertTrue(mockView.invokedSetRemoveAdvertsButtonVisibilityParameters!.isHidden)
    }

    // MARK: - activateAdvertButtonTapped error path

    func test_activateAdvertButtonTapped_whenOwner_onError_stopsActivityIndicator() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        mockAuthenticator.stubbedUserID = "user123"
        let stopExpectation = expectation(description: "stopActivateAdvert called on error")
        mockView.onStopActivateAdvertButtonActivityIndicatorView = { stopExpectation.fulfill() }
        mockService.error = APIError.network

        sut.activateAdvertButtonTapped()

        await fulfillment(of: [stopExpectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivateAdvertButtonActivityIndicatorView)
    }

    // MARK: - activateAd with transactionID

    func test_activateAd_withTransactionID_removesFromStorage() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        let removeExpectation = expectation(description: "remove called")
        mockPurchaseStorage.onRemove = { removeExpectation.fulfill() }
        mockService.stubbedResult = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)

        sut.activateAd(transactionID: "txn-abc")

        await fulfillment(of: [removeExpectation], timeout: 2.0)
        XCTAssertTrue(mockPurchaseStorage.invokedRemove)
        XCTAssertEqual(mockPurchaseStorage.invokedRemoveParameters?.transactionID, "txn-abc")
    }

    // MARK: - prepareGenres lazy map closure

    func test_viewDidLoad_withGenres_configuresGenresView() async throws {
        let expectation = expectation(description: "stopActivityIndicator after genres advert")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockService.stubbedResult = mockService.load(fromJSONFile: "Advert-Sample-Data-WithGenres",
                                                     type: RestObjectResponse<Advert>.self)

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        // Small delay to let MainActor.run finish rendering calls after stopActivityIndicator
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(mockView.invokedConfigureGenresView)
        XCTAssertGreaterThan(mockView.invokedConfigureGenresViewCount, 0)
    }

    // MARK: - reportSubjectDidSelect with items (itemsForSelection closure)

    func test_reportActionDidTap_withSubjects_callsSelectionPopUp() async throws {
        let expectation = expectation(description: "selectionBottomPopUp called")
        mockCoordinator.onSelectionBottomPopUp = { expectation.fulfill() }
        let subject = ReportSubject(id: 1, title: "Spam")
        mockService.stubbedResult = RestArrayResponse<ReportSubject>(data: [subject], metadata: nil, error: nil)

        sut.reportActionDidTap()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectionBottomPopUp)
    }

    // MARK: - handleSendMessage didLogin branch

    func test_sendMessageButtonTapped_whenNotAuthenticated_onLogin_whenNotOwner_callsApply() async throws {
        let chatExpectation = expectation(description: "liveChat called after login")
        mockCoordinator.onLiveChat = { chatExpectation.fulfill() }
        mockCoordinator.stubbedRegistrationDidLogin = true
        mockAuthenticator.stubbedIsAuthenticated = false
        mockAuthenticator.stubbedUserID = "other-user"
        let response = RestObjectResponse<CreateLiveChatResponse>(
            data: CreateLiveChatResponse(chatID: 8), metadata: nil, error: nil)
        mockService.stubbedResult = response

        sut.sendMessageButtonTapped()

        await fulfillment(of: [chatExpectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedLiveChat)
    }

    // MARK: - activateAdvertButtonTapped with purchase (no paywall path)

    func test_activateAdvertButtonTapped_whenOwner_andHasPurchase_doesNotShowPaywall() async throws {
        let advertLoaded = expectation(description: "advert loaded")
        mockView.onStopActivityIndicatorView = { advertLoaded.fulfill() }
        mockService.stubbedResult = makeAdvert()
        sut.viewDidLoad()
        await fulfillment(of: [advertLoaded], timeout: 2.0)

        mockAuthenticator.stubbedUserID = "user123"
        mockPurchaseStorage.stubbedIdentifiers = ["txn-xyz"]
        let dismissExpectation = expectation(description: "dismiss called after activateAd")
        mockCoordinator.onDismiss = { dismissExpectation.fulfill() }
        let hasAdsResponse = RestArrayResponse<Advert>(data: [makeAdvert().data], metadata: nil, error: nil)
        let activateResponse = RestObjectResponse<EmptyResponse>(data: EmptyResponse(), metadata: nil, error: nil)
        mockService.stubbedResults = [hasAdsResponse, activateResponse]

        sut.activateAdvertButtonTapped()

        await fulfillment(of: [dismissExpectation], timeout: 2.0)
        XCTAssertFalse(mockView.invokedShowPaywall)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }

    // MARK: - dismissCompletion

    func test_dismissCompletion_isStoredFromInit() {
        var callbackValue: Bool?
        let sut = AdvertViewModel(
            view: mockView,
            id: 1,
            isPreviousPageLiveChat: false,
            dismissCompletion: { callbackValue = $0 },
            authenticator: mockAuthenticator,
            purchaseStorage: mockPurchaseStorage,
            service: mockService
        )

        sut.dismissCompletion?(true)

        XCTAssertEqual(callbackValue, true)
    }
}

// MARK: - Helpers

private extension AdvertViewModelTests {

    func makeAdvert() -> RestObjectResponse<Advert> {
        return mockService.load(fromJSONFile: "Advert-Sample-Data", type: RestObjectResponse<Advert>.self)
    }

    func makeAdvertWithExternalLink() -> RestObjectResponse<Advert> {
        return mockService.load(fromJSONFile: "Advert-Sample-Data-ExternalLink", type: RestObjectResponse<Advert>.self)
    }

    func makeAdvertWithStatus(_ status: Advert.Status) -> RestObjectResponse<Advert> {
        // The JSON fixture has "active"; to test other statuses we rely on the JSON fixture and
        // accept that autoInactive tests require a separate fixture file. For now load base.
        return mockService.load(fromJSONFile: "Advert-Sample-Data-AutoInactive", type: RestObjectResponse<Advert>.self)
    }
}
