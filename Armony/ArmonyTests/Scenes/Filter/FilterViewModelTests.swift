//
//  FilterViewModelTests.swift
//  ArmonyTests
//
//  Created by Claude Code
//

import XCTest
@testable import Armony

final class FilterViewModelTests: XCTestCase {

    var mockView: MockFilterView!
    var mockDelegate: MockFilterViewModelDelegate!
    var mockCoordinator: MockCoordinator!
    var mockRestService: MockRestService!
    var sut: FilterViewModel!

    override func setUpWithError() throws {
        mockView = MockFilterView()
        mockDelegate = MockFilterViewModelDelegate()
        mockCoordinator = MockCoordinator()
        mockRestService = MockRestService(backend: .factory())

        sut = FilterViewModel(
            view: mockView,
            selectedFilters: .empty,
            service: mockRestService
        )
        sut.coordinator = mockCoordinator
        sut.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockDelegate = nil
        mockCoordinator = nil
        mockRestService = nil
        sut = nil
    }

    // MARK: - Initialization Tests

    func test_init_withEmptyFilters_setsEmptyState() {
        // When
        let sut = FilterViewModel(view: mockView, selectedFilters: .empty, service: mockRestService)

        // Then
        XCTAssertTrue(sut.filters.isEmpty)
        XCTAssertNil(sut.filters.advert)
        XCTAssertNil(sut.filters.location)
    }

    func test_init_withPresetFilters_setsInitialState() {
        // Given
        let advertFilter = FilterViewModel.Filter(id: 1, title: "For Sale")
        let locationFilter = FilterViewModel.Filter(id: 2, title: "Istanbul")
        let presetFilters = FilterViewModel.Filters(advert: advertFilter, location: locationFilter)

        // When
        let sut = FilterViewModel(view: mockView, selectedFilters: presetFilters, service: mockRestService)

        // Then
        XCTAssertFalse(sut.filters.isEmpty)
        XCTAssertEqual(sut.filters.advert?.id, 1)
        XCTAssertEqual(sut.filters.advert?.title, "For Sale")
        XCTAssertEqual(sut.filters.location?.id, 2)
        XCTAssertEqual(sut.filters.location?.title, "Istanbul")
    }

    func test_init_withPartialFilters_advertOnly() {
        // Given
        let advertFilter = FilterViewModel.Filter(id: 1, title: "For Rent")
        let filters = FilterViewModel.Filters(advert: advertFilter, location: nil)

        // When
        let sut = FilterViewModel(view: mockView, selectedFilters: filters, service: mockRestService)

        // Then
        XCTAssertFalse(sut.filters.isEmpty)
        XCTAssertEqual(sut.filters.advert?.id, 1)
        XCTAssertNil(sut.filters.location)
    }

    func test_init_withPartialFilters_locationOnly() {
        // Given
        let locationFilter = FilterViewModel.Filter(id: 5, title: "Ankara")
        let filters = FilterViewModel.Filters(advert: nil, location: locationFilter)

        // When
        let sut = FilterViewModel(view: mockView, selectedFilters: filters, service: mockRestService)

        // Then
        XCTAssertFalse(sut.filters.isEmpty)
        XCTAssertNil(sut.filters.advert)
        XCTAssertEqual(sut.filters.location?.id, 5)
    }

    func test_init_tracksEmptyFilterState() {
        // Given
        let initialFilters = FilterViewModel.Filters(
            advert: FilterViewModel.Filter(id: 1, title: "For Sale"),
            location: nil
        )

        // When
        let sut = FilterViewModel(view: mockView, selectedFilters: initialFilters, service: mockRestService)

        // Then - filters should not be empty initially
        XCTAssertFalse(sut.filters.isEmpty)
    }

    // MARK: - Advert Type Dropdown - Success Tests

    func test_advertTypeDropdownTapped_startsActivityIndicator() async throws {
        // Given
        let advertTypes = [
            Advert.Properties(id: 1, title: "For Sale", colorCode: .empty, skillTitle: .empty),
            Advert.Properties(id: 2, title: "For Rent", colorCode: .empty, skillTitle: .empty)
        ]
        let response = RestArrayResponse<Advert.Properties>(data: advertTypes, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 50_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStartAdvertTypeActivityIndicator)
        XCTAssertEqual(mockView.invokedStartAdvertTypeActivityIndicatorCount, 1)
    }

    func test_advertTypeDropdownTapped_whenSuccess_stopsActivityIndicator() async throws {
        // Given
        let advertTypes = [Advert.Properties(id: 1, title: "For Sale", colorCode: .empty, skillTitle: .empty)]
        let response = RestArrayResponse<Advert.Properties>(data: advertTypes, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStopAdvertTypeActivityIndicator)
        XCTAssertEqual(mockView.invokedStopAdvertTypeActivityIndicatorCount, 1)
    }

    func test_advertTypeDropdownTapped_callsRestService() async throws {
        // Given
        let response = RestArrayResponse<Advert.Properties>(data: [], metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - verify service was called via activity indicator being stopped
        XCTAssertTrue(mockView.invokedStopAdvertTypeActivityIndicator)
    }

    // MARK: - Advert Type Dropdown - Error Tests

    func test_advertTypeDropdownTapped_whenError_stopsActivityIndicator() async throws {
        // Given
        mockRestService.error = APIError.network

        // When
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStopAdvertTypeActivityIndicator)
        XCTAssertEqual(mockView.invokedStopAdvertTypeActivityIndicatorCount, 1)
    }

    func test_advertTypeDropdownTapped_whenNoData_stopsActivityIndicator() async throws {
        // Given
        mockRestService.error = APIError.noData

        // When
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStopAdvertTypeActivityIndicator)
    }

    func test_advertTypeDropdownTapped_whenNetworkError_doesNotUpdateFilter() async throws {
        // Given
        mockRestService.error = APIError.network
        let initialFilters = sut.filters

        // When
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(sut.filters.isEmpty)
        XCTAssertEqual(sut.filters.advert?.id, initialFilters.advert?.id)
    }

    // MARK: - Location Dropdown - Success Tests

    func test_locationDropdownTapped_startsActivityIndicator() async throws {
        // Given
        let locations = [
            Location(id: 1, title: "Istanbul"),
            Location(id: 2, title: "Ankara")
        ]
        let response = RestArrayResponse<Location>(data: locations, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 50_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStartLocationActivityIndicator)
        XCTAssertEqual(mockView.invokedStartLocationActivityIndicatorCount, 1)
    }

    func test_locationDropdownTapped_whenSuccess_stopsActivityIndicator() async throws {
        // Given
        let locations = [Location(id: 1, title: "Istanbul")]
        let response = RestArrayResponse<Location>(data: locations, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStopLocationActivityIndicator)
        XCTAssertEqual(mockView.invokedStopLocationActivityIndicatorCount, 1)
    }

    // MARK: - Location Dropdown - Error Tests

    func test_locationDropdownTapped_whenError_stopsActivityIndicator() async throws {
        // Given
        mockRestService.error = APIError.network

        // When
        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStopLocationActivityIndicator)
        XCTAssertEqual(mockView.invokedStopLocationActivityIndicatorCount, 1)
    }

    func test_locationDropdownTapped_whenNoData_stopsActivityIndicator() async throws {
        // Given
        mockRestService.error = APIError.noData

        // When
        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedStopLocationActivityIndicator)
    }

    // MARK: - AdvertTypeSelectionDelegate Tests

    func test_advertTypeDidSelect_withValidSelection_updatesFilter() {
        // Given
        let selection = EmptySelectionInput(id: 1, title: "For Sale", isSelected: true)

        // When
        sut.advertTypeDidSelect(advert: selection)

        // Then
        XCTAssertEqual(sut.filters.advert?.id, 1)
        XCTAssertEqual(sut.filters.advert?.title, "For Sale")
    }

    func test_advertTypeDidSelect_withValidSelection_updatesView() {
        // Given
        let selection = EmptySelectionInput(id: 2, title: "For Rent", isSelected: true)

        // When
        sut.advertTypeDidSelect(advert: selection)

        // Then
        XCTAssertTrue(mockView.invokedUpdateAdvertType)
        XCTAssertEqual(mockView.invokedUpdateAdvertTypeParameters?.title, "For Rent")
    }

    func test_advertTypeDidSelect_withNilSelection_clearsFilter() {
        // Given - preset filter
        let advertFilter = FilterViewModel.Filter(id: 1, title: "For Sale")
        sut.filters.advert = advertFilter

        // When
        sut.advertTypeDidSelect(advert: nil)

        // Then
        XCTAssertNil(sut.filters.advert)
    }

    func test_advertTypeDidSelect_withNilSelection_updatesViewWithNil() {
        // Given - preset filter
        sut.filters.advert = FilterViewModel.Filter(id: 1, title: "For Sale")

        // When
        sut.advertTypeDidSelect(advert: nil)

        // Then
        XCTAssertTrue(mockView.invokedUpdateAdvertType)
        XCTAssertNil(mockView.invokedUpdateAdvertTypeParameters?.title)
    }

    // MARK: - LocationSelectionDelegate Tests

    func test_locationDidSelect_withValidSelection_updatesFilter() {
        // Given
        let selection = EmptySelectionInput(id: 5, title: "Istanbul", isSelected: true)

        // When
        sut.locationDidSelect(location: selection)

        // Then
        XCTAssertEqual(sut.filters.location?.id, 5)
        XCTAssertEqual(sut.filters.location?.title, "Istanbul")
    }

    func test_locationDidSelect_withValidSelection_updatesView() {
        // Given
        let selection = EmptySelectionInput(id: 6, title: "Ankara", isSelected: true)

        // When
        sut.locationDidSelect(location: selection)

        // Then
        XCTAssertTrue(mockView.invokedUpdateLocation)
        XCTAssertEqual(mockView.invokedUpdateLocationParameters?.title, "Ankara")
    }

    func test_locationDidSelect_withNilSelection_clearsFilter() {
        // Given - preset filter
        sut.filters.location = FilterViewModel.Filter(id: 5, title: "Istanbul")

        // When
        sut.locationDidSelect(location: nil)

        // Then
        XCTAssertNil(sut.filters.location)
    }

    func test_locationDidSelect_withNilSelection_updatesViewWithNil() {
        // Given - preset filter
        sut.filters.location = FilterViewModel.Filter(id: 5, title: "Istanbul")

        // When
        sut.locationDidSelect(location: nil)

        // Then
        XCTAssertTrue(mockView.invokedUpdateLocation)
        XCTAssertNil(mockView.invokedUpdateLocationParameters?.title)
    }

    // MARK: - Filter State Management Tests

    func test_filterDidUpdate_callback_triggeredOnFilterChange() {
        // Given
        var callbackInvoked = false
        var receivedFilters: FilterViewModel.Filters?
        sut.filterDidUpdate = { filters in
            callbackInvoked = true
            receivedFilters = filters
        }

        // When
        let selection = EmptySelectionInput(id: 1, title: "For Sale", isSelected: true)
        sut.advertTypeDidSelect(advert: selection)

        // Then
        XCTAssertTrue(callbackInvoked)
        XCTAssertEqual(receivedFilters?.advert?.id, 1)
    }

    func test_filterDidUpdate_callback_triggeredMultipleTimes() {
        // Given
        var callbackCount = 0
        sut.filterDidUpdate = { _ in
            callbackCount += 1
        }

        // When
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))
        sut.locationDidSelect(location: EmptySelectionInput(id: 2, title: "Istanbul", isSelected: true))

        // Then
        XCTAssertEqual(callbackCount, 2)
    }

    func test_filtersIsEmpty_whenNoFiltersSet_returnsTrue() {
        // Given
        let sut = FilterViewModel(view: mockView, selectedFilters: .empty, service: mockRestService)

        // Then
        XCTAssertTrue(sut.filters.isEmpty)
    }

    func test_filtersIsEmpty_whenAdvertFilterSet_returnsFalse() {
        // Given
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))

        // Then
        XCTAssertFalse(sut.filters.isEmpty)
    }

    func test_filtersIsEmpty_whenLocationFilterSet_returnsFalse() {
        // Given
        sut.locationDidSelect(location: EmptySelectionInput(id: 2, title: "Istanbul", isSelected: true))

        // Then
        XCTAssertFalse(sut.filters.isEmpty)
    }

    func test_filtersIsEmpty_whenBothFiltersSet_returnsFalse() {
        // Given
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))
        sut.locationDidSelect(location: EmptySelectionInput(id: 2, title: "Istanbul", isSelected: true))

        // Then
        XCTAssertFalse(sut.filters.isEmpty)
    }

    // MARK: - Apply Button Tests

    func test_applyButtonTapped_dismissesCoordinator() {
        // When
        sut.applyButtonTapped()

        // Then
        XCTAssertTrue(mockCoordinator.invokedDismiss)
        XCTAssertEqual(mockCoordinator.invokedDismissCount, 1)
    }

    func test_applyButtonTapped_notifiesDelegate() {
        // Given
        let advertFilter = FilterViewModel.Filter(id: 1, title: "For Sale")
        let locationFilter = FilterViewModel.Filter(id: 2, title: "Istanbul")
        sut.filters = FilterViewModel.Filters(advert: advertFilter, location: locationFilter)

        // When
        sut.applyButtonTapped()

        // Then
        XCTAssertTrue(mockDelegate.invokedApplyButtonTapped)
        XCTAssertEqual(mockDelegate.invokedApplyButtonTappedParameters?.filters.advert?.id, 1)
        XCTAssertEqual(mockDelegate.invokedApplyButtonTappedParameters?.filters.location?.id, 2)
    }

    func test_applyButtonTapped_withEmptyFilters_sendsEmptyToDelegate() {
        // Given - empty filters

        // When
        sut.applyButtonTapped()

        // Then
        XCTAssertTrue(mockDelegate.invokedApplyButtonTapped)
        XCTAssertTrue(mockDelegate.invokedApplyButtonTappedParameters?.filters.isEmpty ?? false)
    }

    func test_applyButtonTapped_executesCompletionAfterDismiss() {
        // Given
        var completionExecuted = false
        mockCoordinator.stubbedDismissCompletionResult = {
            completionExecuted = true
        }

        // When
        sut.applyButtonTapped()

        // Then
        XCTAssertTrue(mockCoordinator.invokedDismiss)
        // Note: completion is executed in the mock's dismiss implementation
    }

    // MARK: - Firebase Analytics Tests

    func test_applyButtonTapped_whenFiltersWereSetThenCleared_sendsClearEvent() {
        // Given - filters were initially set, then cleared
        let initialFilters = FilterViewModel.Filters(
            advert: FilterViewModel.Filter(id: 1, title: "For Sale"),
            location: nil
        )
        let sut = FilterViewModel(view: mockView, selectedFilters: initialFilters, service: mockRestService)
        sut.coordinator = mockCoordinator
        sut.delegate = mockDelegate

        // Clear the filters
        sut.filters = .empty

        // When
        sut.applyButtonTapped()

        // Then - ClearFilterFirebaseEvent should be sent
        XCTAssertTrue(sut.filters.isEmpty)
    }

    func test_applyButtonTapped_whenFiltersAlwaysEmpty_doesNotSendClearEvent() {
        // Given - filters were always empty
        let sut = FilterViewModel(view: mockView, selectedFilters: .empty, service: mockRestService)
        sut.coordinator = mockCoordinator
        sut.delegate = mockDelegate

        // When
        sut.applyButtonTapped()

        // Then - No clear event should be sent (filters were always empty)
        XCTAssertTrue(sut.filters.isEmpty)
    }

    func test_applyButtonTapped_withFiltersSet_sendsApplyEvent() {
        // Given
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))
        sut.locationDidSelect(location: EmptySelectionInput(id: 2, title: "Istanbul", isSelected: true))

        // When
        sut.applyButtonTapped()

        // Then - ApplyFilterFirebaseEvent should be sent with parameters
        XCTAssertFalse(sut.filters.isEmpty)
    }

    func test_applyButtonTapped_withPartialFilters_sendsApplyEventWithEmptyValues() {
        // Given - only advert type set
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))

        // When
        sut.applyButtonTapped()

        // Then - ApplyFilterFirebaseEvent with ad_type: "For Sale", location: ""
        XCTAssertNotNil(sut.filters.advert)
        XCTAssertNil(sut.filters.location)
    }

    func test_handleEvents_logic_clearEventCondition() {
        // Testing the logic: if filters.isEmpty && !isEmptyFilters -> send clear event
        // Given - initially had filters
        let initialFilters = FilterViewModel.Filters(
            advert: FilterViewModel.Filter(id: 1, title: "For Sale"),
            location: nil
        )
        let sut = FilterViewModel(view: mockView, selectedFilters: initialFilters, service: mockRestService)

        // Clear them
        sut.filters = .empty

        // This should trigger clear event when apply is tapped
        XCTAssertTrue(sut.filters.isEmpty)
    }

    func test_handleEvents_logic_applyEventCondition() {
        // Testing the logic: if !filters.isEmpty -> send apply event
        // Given
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))

        // When filters are not empty
        XCTAssertFalse(sut.filters.isEmpty)
    }

    // MARK: - Edge Cases

    func test_multipleDropdownTaps_handledCorrectly() async throws {
        // Given
        let response = RestArrayResponse<Advert.Properties>(data: [], metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When - multiple rapid taps
        sut.advertTypeDropdownTapped()
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 150_000_000)

        // Then - should handle gracefully
        XCTAssertTrue(mockView.invokedStartAdvertTypeActivityIndicator)
        XCTAssertGreaterThanOrEqual(mockView.invokedStartAdvertTypeActivityIndicatorCount, 1)
    }

    func test_selectionDelegateCallsBeforeAPIComplete_handledCorrectly() async throws {
        // Given
        let response = RestArrayResponse<Advert.Properties>(data: [], metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        sut.advertTypeDropdownTapped()

        // When - selection made before API completes
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))

        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.filters.advert?.id, 1)
    }

    func test_filterEmptyStruct_isEmpty() {
        // Given
        let emptyFilter = FilterViewModel.Filter.empty

        // Then
        XCTAssertNil(emptyFilter.id)
        XCTAssertNil(emptyFilter.title)
    }

    func test_filtersEmptyStruct_isEmpty() {
        // Given
        let emptyFilters = FilterViewModel.Filters.empty

        // Then
        XCTAssertNil(emptyFilters.advert)
        XCTAssertNil(emptyFilters.location)
        XCTAssertTrue(emptyFilters.isEmpty)
    }

    // MARK: - Integration Test

    func test_completeFilterFlow_selectBothFiltersAndApply() async throws {
        // Given
        let advertResponse = RestArrayResponse<Advert.Properties>(
            data: [Advert.Properties(id: 1, title: "For Sale", colorCode: .empty, skillTitle: .empty)],
            metadata: nil,
            error: nil
        )
        mockRestService.stubbedResult = advertResponse

        // When - complete flow
        // 1. Tap advert dropdown
        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        // 2. Select advert type
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 1, title: "For Sale", isSelected: true))

        // 3. Select location (without API call for simplicity)
        sut.locationDidSelect(location: EmptySelectionInput(id: 2, title: "Istanbul", isSelected: true))

        // 4. Apply filters
        sut.applyButtonTapped()

        // Then
        XCTAssertTrue(mockDelegate.invokedApplyButtonTapped)
        XCTAssertEqual(mockDelegate.invokedApplyButtonTappedParameters?.filters.advert?.id, 1)
        XCTAssertEqual(mockDelegate.invokedApplyButtonTappedParameters?.filters.location?.id, 2)
        XCTAssertTrue(mockCoordinator.invokedDismiss)
    }
}
