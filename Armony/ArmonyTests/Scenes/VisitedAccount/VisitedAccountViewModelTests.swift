//
//  VisitedAccountViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.08.26.
//

import XCTest
@testable import Armony

final class VisitedAccountViewModelTests: XCTestCase {

    var mockView: MockVisitedAccountView!
    var mockCoordinator: MockVisitedAccountCoordinator!
    var mockService: MockRestService!
    var sut: VisitedAccountViewModel!

    override func setUpWithError() throws {
        mockView = MockVisitedAccountView()
        mockCoordinator = MockVisitedAccountCoordinator()
        mockService = MockRestService(backend: .factory())

        sut = VisitedAccountViewModel(
            view: mockView,
            userID: "user123",
            service: mockService
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockCoordinator = nil
        mockService = nil
        sut = nil
    }

    // MARK: - viewDidLoad — synchronous side effects

    func test_viewDidLoad_makesNavigationBarTransparent() {
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        XCTAssertTrue(mockView.invokedMakeNavigationBarTransparent)
    }

    func test_viewDidLoad_resetsUserSummaryViewImmediately() {
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        // resetViews() is called synchronously before the async fetch
        XCTAssertTrue(mockView.invokedConfigureUserSummaryView)
    }

    func test_viewDidLoad_resetsBioLabelTextImmediately() {
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        // resetViews() calls setBioLabelText(.empty) synchronously
        XCTAssertTrue(mockView.invokedSetBioLabelText)
    }

    // MARK: - viewDidLoad — async success path

    func test_viewDidLoad_onSuccess_configuresPager() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedConfigurePager)
        XCTAssertEqual(mockView.invokedConfigurePagerParameters?.userID, "user123")
    }

    func test_viewDidLoad_onSuccess_configuresUserSummaryViewAfterFetch() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        // Called at least twice: once in resetViews(), once after async fetch
        XCTAssertGreaterThanOrEqual(mockView.invokedConfigureUserSummaryViewCount, 2)
    }

    func test_viewDidLoad_onSuccess_setsBioTextAfterFetch() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        // Last call should be from the async response, not from resetViews
        XCTAssertEqual(mockView.invokedSetBioLabelTextParameters?.bio, "Test bio text")
    }

    func test_viewDidLoad_onSuccess_whenUserHasNilBio_setsBioTextNil() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }
        mockService.stubbedResult = makeUserDetailWithNilBio()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNil(mockView.invokedSetBioLabelTextParameters?.bio)
    }

    func test_viewDidLoad_onSuccess_setBioLabelTextCalledMultipleTimes() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }
        mockService.stubbedResult = makeUserDetail()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        // Once from resetViews(), once from async fetch
        XCTAssertGreaterThanOrEqual(mockView.invokedSetBioLabelTextCount, 2)
    }

    func test_viewDidLoad_onSuccess_passesCorrectUserIDToPager() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }

        let customSUT = VisitedAccountViewModel(
            view: mockView,
            userID: "custom-id-456",
            service: mockService
        )
        customSUT.coordinator = mockCoordinator
        mockService.stubbedResult = makeUserDetail()

        customSUT.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(mockView.invokedConfigurePagerParameters?.userID, "custom-id-456")
    }

    // MARK: - viewDidLoad — error path

    func test_viewDidLoad_onError_doesNotConfigurePager() async throws {
        mockService.error = APIError.network
        // Wait briefly for the async task to complete
        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(mockView.invokedConfigurePager)
    }

    func test_viewDidLoad_onError_doesNotCallConfigureUserSummaryViewAfterReset() async throws {
        mockService.error = APIError.network

        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 500_000_000)

        // Only the initial reset call, no second call from a successful fetch
        XCTAssertEqual(mockView.invokedConfigureUserSummaryViewCount, 1)
    }

    func test_viewDidLoad_onSuccess_withGenres_configuresPagerWithGenreItems() async throws {
        let expectation = expectation(description: "configurePager called")
        mockView.onConfigurePager = { expectation.fulfill() }
        mockService.stubbedResult = makeUserDetailWithGenres()

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedConfigurePager)
        let genreItems = mockView.invokedConfigurePagerParameters?.musicGenres.items
        XCTAssertEqual(genreItems?.count, 2)
    }
}

// MARK: - Helpers

private extension VisitedAccountViewModelTests {

    func makeUserDetail() -> RestObjectResponse<UserDetail> {
        return mockService.load(fromJSONFile: "UserDetail-Sample-Data", type: RestObjectResponse<UserDetail>.self)
    }

    func makeUserDetailWithNilBio() -> RestObjectResponse<UserDetail> {
        return mockService.load(fromJSONFile: "UserDetail-Sample-Data-NilBio", type: RestObjectResponse<UserDetail>.self)
    }

    func makeUserDetailWithGenres() -> RestObjectResponse<UserDetail> {
        return mockService.load(fromJSONFile: "UserDetail-Sample-Data-WithGenres", type: RestObjectResponse<UserDetail>.self)
    }
}
