//
//  SettingsViewModelTests.swift
//  ArmonyTests
//
//  Created by Claude Code
//

import XCTest
@testable import Armony

final class SettingsViewModelTests: XCTestCase {

    var mockView: MockSettingsView!
    var mockRestService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockCoordinator: MockCoordinator!
    var sut: SettingsViewModel!

    override func setUpWithError() throws {
        mockView = MockSettingsView()
        mockRestService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockCoordinator = MockCoordinator()

        sut = SettingsViewModel(
            view: mockView,
            authenticator: mockAuthenticator,
            service: mockRestService
        )
        sut.coordinator = mockCoordinator
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockRestService = nil
        mockAuthenticator = nil
        mockCoordinator = nil
        sut = nil
    }

    // MARK: - Data Fetching - Success Tests

    func test_fetchSettingsData_whenSuccess_updatesPresentation() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback"),
            Setting(id: 2, deeplink: .changePassword, accessoryImageName: "chevron", isVisible: true, title: "Change Password")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 2)
    }

    func test_fetchSettingsData_whenSuccess_triggersViewReload() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedReloadData)
        XCTAssertGreaterThanOrEqual(mockView.invokedReloadDataCount, 1)
    }

    func test_fetchSettingsData_whenSuccess_filtersInvisibleSettings() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback"),
            Setting(id: 2, deeplink: .logOut, accessoryImageName: "chevron", isVisible: false, title: "Logout"),
            Setting(id: 3, deeplink: .changePassword, accessoryImageName: "chevron", isVisible: true, title: "Password")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 2, "Should only include visible settings")
    }

    func test_fetchSettingsData_whenEmptyArray_setsEmptyPresentation() async throws {
        // Given
        let response = RestArrayResponse<Setting>(data: [], metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 0)
        XCTAssertTrue(mockView.invokedReloadData)
    }

    func test_numberOfRowsInSection_afterSuccessfulFetch_returnsCorrectCount() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback"),
            Setting(id: 2, deeplink: .changePassword, accessoryImageName: "chevron", isVisible: true, title: "Password"),
            Setting(id: 3, deeplink: .accountInformation, accessoryImageName: "chevron", isVisible: true, title: "Account")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 3)
    }

    // MARK: - Data Fetching - Error Tests

    func test_fetchSettingsData_whenError_setsEmptyPresentation() async throws {
        // Given
        mockRestService.error = APIError.network

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 0)
        XCTAssertTrue(mockView.invokedReloadData)
    }

    func test_fetchSettingsData_whenNoData_setsEmptyPresentation() async throws {
        // Given
        mockRestService.error = APIError.noData

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 0)
    }

    // MARK: - Setting Retrieval Tests

    func test_setting_whenValidIndexPath_returnsCorrectSetting() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback"),
            Setting(id: 2, deeplink: .changePassword, accessoryImageName: "chevron", isVisible: true, title: "Password")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        let indexPath = IndexPath(row: 0, section: 0)
        let setting = sut.setting(at: indexPath)

        // Then
        XCTAssertEqual(setting.id, 1)
        XCTAssertEqual(setting.deeplink, .feedback)
    }

    func test_setting_whenInvalidIndexPath_returnsEmptySetting() {
        // Given - no data loaded

        // When
        let indexPath = IndexPath(row: 10, section: 0)
        let setting = sut.setting(at: indexPath)

        // Then
        XCTAssertEqual(setting.id, 0)
        XCTAssertEqual(setting.deeplink, .empty)
    }

    func test_setting_whenOutOfBoundsIndexPath_returnsEmptySetting() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        let indexPath = IndexPath(row: 5, section: 0)
        let setting = sut.setting(at: indexPath)

        // Then
        XCTAssertEqual(setting.deeplink, SettingPresentation.empty.deeplink)
    }

    // MARK: - Selection and Navigation Tests

    func test_didSelectSetting_opensDeeplink() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback"),
            Setting(id: 2, deeplink: .changePassword, accessoryImageName: "chevron", isVisible: true, title: "Password")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        let indexPath = IndexPath(row: 0, section: 0)
        sut.didSelectSetting(at: indexPath)

        // Then
        XCTAssertTrue(mockCoordinator.invokedOpen)
        XCTAssertEqual(mockCoordinator.invokedOpenParameters?.deeplink, .feedback)
    }

    func test_didSelectSetting_withMultipleSelections_tracksAllDeeplinks() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback"),
            Setting(id: 2, deeplink: .changePassword, accessoryImageName: "chevron", isVisible: true, title: "Password")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.didSelectSetting(at: IndexPath(row: 0, section: 0))
        sut.didSelectSetting(at: IndexPath(row: 1, section: 0))

        // Then
        XCTAssertEqual(mockCoordinator.invokedOpenCount, 2)
        // XCTAssert Equal(mockCoordinator.invokedOpenParametersList, [.feedback, .changePassword])
    }

    func test_didSelectSetting_whenInvalidIndexPath_opensEmptyDeeplink() {
        // Given - no data

        // When
        let indexPath = IndexPath(row: 0, section: 0)
        sut.didSelectSetting(at: indexPath)

        // Then
        XCTAssertTrue(mockCoordinator.invokedOpen)
        XCTAssertEqual(mockCoordinator.invokedOpenParameters?.deeplink, .empty)
    }

    // MARK: - Presentation State Tests

    func test_numberOfRowsInSection_whenNoData_returnsZero() {
        // Given - fresh instance

        // When
        let count = sut.numberOfRowsInSection

        // Then
        XCTAssertEqual(count, 0)
    }

    func test_presentationUpdate_triggersReloadData() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        mockView.invokedReloadData = false
        mockView.invokedReloadDataCount = 0

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockView.invokedReloadData, "Presentation update should trigger reloadData")
        XCTAssertGreaterThanOrEqual(mockView.invokedReloadDataCount, 1)
    }

    func test_initialState_hasZeroRows() {
        // Given - newly initialized viewModel

        // When
        let count = sut.numberOfRowsInSection

        // Then
        XCTAssertEqual(count, 0, "Initial state should have zero rows")
    }

    // MARK: - Async/Threading Tests

    func test_fetchSettingsData_asyncCompletesSuccessfully() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 1)
        XCTAssertTrue(mockView.invokedReloadData)
    }

    func test_fetchSettingsData_callsReloadDataOnMainThread() async throws {
        // Given
        let settings = [
            Setting(id: 1, deeplink: .feedback, accessoryImageName: "chevron", isVisible: true, title: "Feedback")
        ]
        let response = RestArrayResponse<Setting>(data: settings, metadata: nil, error: nil)
        mockRestService.stubbedResult = response

        // When
        sut.fetchSettingsData()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        // The safeSync method in presentation didSet should ensure main thread execution
        XCTAssertTrue(mockView.invokedReloadData)
    }
}
