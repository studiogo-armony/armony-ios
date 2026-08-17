//
//  AdvertsViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 17.08.26.
//

import XCTest
@testable import Armony

final class AdvertsViewModelTests: XCTestCase {

    var mockView: MockAdvertsView!
    var mockCoordinator: MockAdvertsCoordinator!
    var mockService: MockRestService!
    var mockBannerService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockSocketHandler: MockMessageCountSocketHandler!
    var mockDefaults: MockDefaults!
    var mockAppLaunchService: MockAppLaunchService!
    var sut: AdvertsViewModel!

    override func setUpWithError() throws {
        mockView = MockAdvertsView()
        mockCoordinator = MockAdvertsCoordinator()
        mockService = MockRestService(backend: .factory())
        mockBannerService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockAuthenticator.stubbedUserID = "user123"
        mockSocketHandler = MockMessageCountSocketHandler()
        mockDefaults = MockDefaults()
        mockAppLaunchService = MockAppLaunchService()

        sut = AdvertsViewModel(
            view: mockView,
            messageCountSocketHandler: mockSocketHandler,
            authenticator: mockAuthenticator,
            defaults: mockDefaults,
            appLaunchService: mockAppLaunchService,
            bannerService: mockBannerService,
            service: mockService
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockCoordinator = nil
        mockService = nil
        mockBannerService = nil
        mockAuthenticator = nil
        mockSocketHandler = nil
        mockDefaults = nil
        mockAppLaunchService = nil
        sut = nil
    }

    // MARK: - viewDidLoad — synchronous

    func test_viewDidLoad_configuresCollectionView() {
        stubHomeData()
        sut.viewDidLoad()
        XCTAssertTrue(mockView.invokedConfigureCollectionView)
    }

    func test_viewDidLoad_configuresNavigationBar() {
        stubHomeData()
        sut.viewDidLoad()
        XCTAssertTrue(mockView.invokedConfigureNavigationBar)
    }

    func test_viewDidLoad_configuresUI() {
        stubHomeData()
        sut.viewDidLoad()
        XCTAssertTrue(mockView.invokedConfigureUI)
    }

    func test_viewDidLoad_startsActivityIndicator() {
        stubHomeData()
        sut.viewDidLoad()
        XCTAssertTrue(mockView.invokedStartActivityIndicatorView)
    }

    func test_viewDidLoad_hidesCollectionViewInitially() {
        stubHomeData()
        sut.viewDidLoad()
        XCTAssertTrue(mockView.invokedSetCollectionViewVisibilityParameters?.isHidden ?? false)
    }

    func test_viewDidLoad_startsSocketHandler() {
        stubHomeData()
        sut.viewDidLoad()
        XCTAssertTrue(mockSocketHandler.invokedStart)
    }

    // MARK: - viewDidLoad — async success

    func test_viewDidLoad_onSuccess_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivityIndicatorView)
    }

    func test_viewDidLoad_onSuccess_showsCollectionView() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockView.invokedSetCollectionViewVisibilityParameters?.isHidden ?? true)
    }

    func test_viewDidLoad_onSuccess_reloadsCollectionView() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedReloadCollectionView)
    }

    // MARK: - viewDidLoad — error

    func test_viewDidLoad_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopActivityIndicator called on error")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        mockBannerService.error = APIError.network

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivityIndicatorView)
    }

    // MARK: - numberOfItemsInSection

    func test_numberOfItemsInSection_initiallyZero() {
        XCTAssertEqual(sut.numberOfItemsInSection, 0)
    }

    func test_numberOfItemsInSection_afterSuccess_returnsCardCount() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.fetchAdverts()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(sut.numberOfItemsInSection, 1)
    }

    // MARK: - card(at:)

    func test_cardAt_returnsCorrectCard() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.fetchAdverts()

        await fulfillment(of: [expectation], timeout: 2.0)
        let card = sut.card(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(card.id, 1)
    }

    // MARK: - chatsRightButtonTapped

    func test_chatsRightButtonTapped_opensChatsDeeplink() {
        sut.chatsRightButtonTapped()
        XCTAssertTrue(mockCoordinator.invokedOpen)
        XCTAssertEqual(mockCoordinator.invokedOpenParameters?.deeplink, .chats)
    }

    // MARK: - filter

    func test_filter_hidesCollectionView() {
        stubHomeData()
        sut.filter(by: .empty)
        XCTAssertTrue(mockView.invokedSetCollectionViewVisibilityParameters?.isHidden ?? false)
    }

    func test_filter_startsActivityIndicator() {
        stubHomeData()
        sut.filter(by: .empty)
        XCTAssertTrue(mockView.invokedStartActivityIndicatorView)
    }

    // MARK: - toggleEmptyStateView

    func test_toggleEmptyStateView_whenCardsEmpty_showsEmptyState() {
        sut.presentation = .empty
        XCTAssertTrue(mockView.invokedShowEmptyStateView)
    }

    // MARK: - viewDidAppear — onboarding

    func test_viewDidAppear_whenOnboardingNotSeen_callsOnboarding() async throws {
        let expectation = expectation(description: "onboarding called")
        mockCoordinator.invokedOnboarding = false
        mockDefaults.stubbedBoolValues[.onboardingHasSeen] = false

        sut.viewDidAppear()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { expectation.fulfill() }
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedOnboarding)
    }

    func test_viewDidAppear_whenOnboardingAlreadySeen_doesNotCallOnboarding() async throws {
        mockDefaults.stubbedBoolValues[.onboardingHasSeen] = true

        sut.viewDidAppear()

        try await Task.sleep(nanoseconds: 1_200_000_000)
        XCTAssertFalse(mockCoordinator.invokedOnboarding)
    }

    // MARK: - viewDidAppear — deeplink

    func test_viewDidAppear_whenLaunchedWithDeeplink_opensDeeplink() {
        mockAppLaunchService.isLaunchedClosedStateWithNotification = true
        mockAppLaunchService.deeplink = .adverts

        sut.viewDidAppear()

        XCTAssertTrue(mockCoordinator.invokedOpen)
        XCTAssertEqual(mockCoordinator.invokedOpenParameters?.deeplink, .adverts)
    }

    func test_viewDidAppear_whenLaunchedWithDeeplink_resetsAppLaunchService() {
        mockAppLaunchService.isLaunchedClosedStateWithNotification = true
        mockAppLaunchService.deeplink = .adverts

        sut.viewDidAppear()

        XCTAssertTrue(mockAppLaunchService.invokedReset)
    }

    func test_viewDidAppear_whenNotLaunchedWithDeeplink_doesNotOpenDeeplink() {
        mockAppLaunchService.isLaunchedClosedStateWithNotification = false

        sut.viewDidAppear()

        XCTAssertFalse(mockCoordinator.invokedOpen)
    }

    // MARK: - willDisplayItem

    func test_willDisplayItem_whenNotNearEnd_doesNotFetch() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()
        sut.fetchAdverts()
        await fulfillment(of: [expectation], timeout: 2.0)

        // 1 card total, row 0 is not near end (needs count - 2 == row)
        mockView.invokedReloadCollectionViewCount = 0
        sut.willDisplayItem(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(mockView.invokedReloadCollectionViewCount, 0)
    }

    // MARK: - refresh

    func test_refresh_fetchesAdverts() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.refresh()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopActivityIndicatorView)
    }

    // MARK: - toggleEmptyStateView — hides when cards present

    func test_toggleEmptyStateView_whenCardsNotEmpty_hidesEmptyState() async throws {
        let expectation = expectation(description: "stopActivityIndicator called")
        mockView.onStopActivityIndicatorView = { expectation.fulfill() }
        stubHomeData()

        sut.fetchAdverts()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedHideEmptyStateView)
    }
}

// MARK: - Helpers

private extension AdvertsViewModelTests {

    func stubHomeData() {
        mockBannerService.stubbedResult = mockBannerService.load(
            fromJSONFile: "Banners-Sample-Data",
            type: RestObjectResponse<BannerSliderResponse>.self
        )
        mockService.stubbedResult = mockService.load(
            fromJSONFile: "Adverts-Sample-Data",
            type: RestArrayResponse<Advert>.self
        )
    }
}
