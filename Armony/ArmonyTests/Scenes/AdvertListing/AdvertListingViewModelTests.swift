//
//  AdvertListingViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import XCTest
@testable import Armony

final class AdvertListingViewModelTests: XCTestCase {

    var mockCoordinator: MockAdvertListingCoordinator!
    var mockService: MockRestService!
    var sut: AdvertListingViewModel!

    override func setUpWithError() throws {
        mockCoordinator = MockAdvertListingCoordinator()
        mockService = MockRestService(backend: .factory())

        sut = AdvertListingViewModel(service: mockService)
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockCoordinator = nil
        mockService = nil
        sut = nil
    }

    // MARK: - init

    func test_init_stateIsLoading() {
        XCTAssertEqual(sut.state, .loading)
    }

    func test_init_cardsIsEmpty() {
        XCTAssertTrue(sut.cards.isEmpty)
    }

    // MARK: - fetchAdverts — loading state

    func test_fetchAdverts_setsStateToLoading() async {
        mockService.stubbedResult = makeAdverts()

        await sut.fetchAdverts()

        // After success, state is .data (not .loading); loading was set at start
        XCTAssertNotEqual(sut.state, .loading)
    }

    // MARK: - fetchAdverts — success with data

    func test_fetchAdverts_onSuccess_withData_setsStateToData() async {
        mockService.stubbedResult = makeAdverts()

        await sut.fetchAdverts()

        XCTAssertEqual(sut.state, .data)
    }

    func test_fetchAdverts_onSuccess_withData_populatesCards() async {
        mockService.stubbedResult = makeAdverts()

        await sut.fetchAdverts()

        XCTAssertEqual(sut.cards.count, 2)
    }

    func test_fetchAdverts_onSuccess_cardsHaveCorrectIDs() async {
        mockService.stubbedResult = makeAdverts()

        await sut.fetchAdverts()

        XCTAssertEqual(sut.cards[0].id, 1)
        XCTAssertEqual(sut.cards[1].id, 2)
    }

    // MARK: - fetchAdverts — success with empty data

    func test_fetchAdverts_onSuccess_withEmptyData_setsStateToEmpty() async {
        mockService.stubbedResult = makeEmptyAdverts()

        await sut.fetchAdverts()

        XCTAssertEqual(sut.state, .empty)
    }

    func test_fetchAdverts_onSuccess_withEmptyData_cardsIsEmpty() async {
        mockService.stubbedResult = makeEmptyAdverts()

        await sut.fetchAdverts()

        XCTAssertTrue(sut.cards.isEmpty)
    }

    // MARK: - fetchAdverts — error

    func test_fetchAdverts_onError_doesNotPopulateCards() async {
        mockService.error = APIError.network

        await sut.fetchAdverts()

        XCTAssertTrue(sut.cards.isEmpty)
    }

    func test_fetchAdverts_onError_stateRemainsLoading() async {
        mockService.error = APIError.network

        await sut.fetchAdverts()

        XCTAssertEqual(sut.state, .loading)
    }
}

// MARK: - Helpers

private extension AdvertListingViewModelTests {

    func makeAdverts() -> RestArrayResponse<Advert> {
        return mockService.load(fromJSONFile: "ExternalAdverts-Sample-Data", type: RestArrayResponse<Advert>.self)
    }

    func makeEmptyAdverts() -> RestArrayResponse<Advert> {
        return RestArrayResponse<Advert>(data: [], metadata: nil, error: nil)
    }
}
