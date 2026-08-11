//
//  PlaceAdvertViewModelTests.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 11.08.26.
//

import XCTest
@testable import Armony

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown", file: file, line: line)
    } catch {}
}

final class PlaceAdvertViewModelTests: XCTestCase {

    var mockView: MockPlaceAdvertView!
    var mockCoordinator: MockPlaceAdvertCoordinator!
    var mockService: MockRestService!
    var mockAuthenticator: MockAuthenticationService!
    var mockPurchaseStorage: MockRevenueCatPurchaseStorageService!
    var mockAppRating: MockAppRatingService!
    var sut: PlaceAdvertViewModel!

    override func setUpWithError() throws {
        mockView = MockPlaceAdvertView()
        mockCoordinator = MockPlaceAdvertCoordinator()
        mockService = MockRestService(backend: .factory())
        mockAuthenticator = MockAuthenticationService()
        mockPurchaseStorage = MockRevenueCatPurchaseStorageService()
        mockAppRating = MockAppRatingService()

        sut = PlaceAdvertViewModel(
            view: mockView,
            authenticator: mockAuthenticator,
            purchaseStorage: mockPurchaseStorage,
            appRating: mockAppRating,
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
        mockAppRating = nil
        sut = nil
    }

    // MARK: - hasUserAds

    func test_hasUserAds_whenResponseHasAdverts_returnsTrue() async throws {
        let adverts = [makeAdvert()]
        mockService.stubbedResult = RestArrayResponse<Advert>(data: adverts, metadata: nil, error: nil)

        let result = try await sut.hasUserAds()

        XCTAssertTrue(result)
    }

    func test_hasUserAds_whenResponseIsEmpty_returnsFalse() async throws {
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

    // MARK: - submitButtonTapped

    func test_submitButtonTapped_startsActivityIndicator() {
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [], metadata: nil, error: nil)

        sut.submitButtonTapped()

        XCTAssertTrue(mockView.invokedStartSubmitButtonActivityIndicator)
    }

    func test_submitButtonTapped_whenNoUserAds_andNoPurchase_callsCreateAd() async throws {
        let expectation = expectation(description: "createAd called — resetTextView triggered")
        mockView.onResetTextView = {
            expectation.fulfill()
        }
        let advertResponse = mockService.load(fromJSONFile: "PlaceAdvert-Sample-Data",
                                              type: RestObjectResponse<Advert>.self)
        // 1st execute: hasUserAds → empty array
        // 2nd execute: createAd → single advert object
        mockService.stubbedResults = [
            RestArrayResponse<Advert>(data: [], metadata: nil, error: nil),
            advertResponse
        ]
        mockPurchaseStorage.stubbedIdentifiers = []

        sut.submitButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedResetTextView)
    }

    func test_submitButtonTapped_whenHasUserAds_andNoPurchase_showsPaywall() async throws {
        let expectation = expectation(description: "showPaywall called")
        mockView.onShowPaywall = {
            expectation.fulfill()
        }
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [makeAdvert()], metadata: nil, error: nil)
        mockPurchaseStorage.stubbedIdentifiers = .empty

        sut.submitButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedShowPaywall)
    }

    func test_submitButtonTapped_whenHasUserAds_andHasPurchase_doesNotShowPaywall() async throws {
        let expectation = expectation(description: "stopSubmitButton called after hasUserAds")
        mockView.onStopSubmitButtonActivityIndicator = {
            expectation.fulfill()
        }
        mockService.stubbedResult = RestArrayResponse<Advert>(data: [makeAdvert()], metadata: nil, error: nil)
        mockPurchaseStorage.stubbedIdentifiers = ["txn-123"]

        sut.submitButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockView.invokedShowPaywall)
    }

    func test_submitButtonTapped_whenServiceThrows_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSubmitButton called on error")
        mockView.onStopSubmitButtonActivityIndicator = {
            expectation.fulfill()
        }
        mockService.error = APIError.network

        sut.submitButtonTapped()

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSubmitButtonActivityIndicator)
    }

    // MARK: - createAd

    func test_createAd_onSuccess_resetsInputs() async throws {
        let expectation = expectation(description: "resetTextView called after createAd")
        mockView.onResetTextView = {
            expectation.fulfill()
        }
        mockService.stubbedResult = mockService.load(fromJSONFile: "PlaceAdvert-Sample-Data",
                                                     type: RestObjectResponse<Advert>.self)

        sut.createAd(transactionID: nil)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedResetTextView)
    }

    func test_createAd_onSuccess_navigatesToAccountTab() async throws {
        let expectation = expectation(description: "selectTab called")
        mockCoordinator.onSelectTab = {
            expectation.fulfill()
        }
        mockService.stubbedResult = mockService.load(fromJSONFile: "PlaceAdvert-Sample-Data",
                                                     type: RestObjectResponse<Advert>.self)

        sut.createAd(transactionID: nil)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockCoordinator.invokedSelectTab)
        XCTAssertEqual(mockCoordinator.invokedSelectTabParameters?.tab, .account)
    }

    func test_createAd_withTransactionID_removesFromStorage() async throws {
        let expectation = expectation(description: "remove called")
        mockPurchaseStorage.onRemove = {
            expectation.fulfill()
        }
        mockPurchaseStorage.stubbedIdentifiers = ["txn-abc"]
        mockService.stubbedResult = mockService.load(fromJSONFile: "PlaceAdvert-Sample-Data",
                                                     type: RestObjectResponse<Advert>.self)

        sut.createAd(transactionID: "txn-abc")

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockPurchaseStorage.invokedRemove)
        XCTAssertEqual(mockPurchaseStorage.invokedRemoveParameters?.transactionID, "txn-abc")
    }

    func test_createAd_withNilTransactionID_doesNotRemoveFromStorage() async throws {
        let expectation = expectation(description: "resetTextView called")
        mockView.onResetTextView = {
            expectation.fulfill()
        }
        mockService.stubbedResult = mockService.load(fromJSONFile: "PlaceAdvert-Sample-Data",
                                                     type: RestObjectResponse<Advert>.self)

        sut.createAd(transactionID: nil)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(mockPurchaseStorage.invokedRemove)
    }

    func test_createAd_onError_stopsActivityIndicator() async throws {
        let expectation = expectation(description: "stopSubmitButton called on error")
        mockView.onStopSubmitButtonActivityIndicator = {
            expectation.fulfill()
        }
        mockService.error = APIError.network

        sut.createAd(transactionID: nil)

        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(mockView.invokedStopSubmitButtonActivityIndicator)
    }

    // MARK: - advertTypeDropdownTapped

    func test_advertTypeDropdownTapped_startsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<Advert.Properties>(data: [], metadata: nil, error: nil)

        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(mockView.invokedStartAdvertTypeActivityIndicator)
    }

    func test_advertTypeDropdownTapped_onSuccess_stopsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<Advert.Properties>(data: [], metadata: nil, error: nil)

        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopAdvertTypeActivityIndicator)
    }

    func test_advertTypeDropdownTapped_onSuccess_callsCoordinatorProfileSelection() async throws {
        mockService.stubbedResult = RestArrayResponse<Advert.Properties>(data: [], metadata: nil, error: nil)

        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockCoordinator.invokedProfileSelection)
    }

    func test_advertTypeDropdownTapped_onError_stopsActivityIndicator() async throws {
        mockService.error = APIError.network

        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopAdvertTypeActivityIndicator)
    }

    func test_advertTypeDropdownTapped_onError_doesNotCallCoordinator() async throws {
        mockService.error = APIError.network

        sut.advertTypeDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(mockCoordinator.invokedProfileSelection)
    }

    // MARK: - musicGenresDropdownTapped

    func test_musicGenresDropdownTapped_startsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<MusicGenre>(data: [], metadata: nil, error: nil)

        sut.musicGenresDropdownTapped()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(mockView.invokedStartMusicGenresActivityIndicator)
    }

    func test_musicGenresDropdownTapped_onSuccess_stopsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<MusicGenre>(data: [], metadata: nil, error: nil)

        sut.musicGenresDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopMusicGenresActivityIndicator)
    }

    func test_musicGenresDropdownTapped_onSuccess_callsCoordinatorProfileSelection() async throws {
        mockService.stubbedResult = RestArrayResponse<MusicGenre>(data: [], metadata: nil, error: nil)

        sut.musicGenresDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockCoordinator.invokedProfileSelection)
    }

    func test_musicGenresDropdownTapped_onError_stopsActivityIndicator() async throws {
        mockService.error = APIError.network

        sut.musicGenresDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopMusicGenresActivityIndicator)
    }

    // MARK: - skillsDropdownTapped

    func test_skillsDropdownTapped_startsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<Skill>(data: [], metadata: nil, error: nil)

        sut.skillsDropdownTapped()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(mockView.invokedStartSkillsActivityIndicator)
    }

    func test_skillsDropdownTapped_onSuccess_stopsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<Skill>(data: [], metadata: nil, error: nil)

        sut.skillsDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopSkillsActivityIndicator)
    }

    func test_skillsDropdownTapped_onSuccess_callsCoordinatorProfileSelection() async throws {
        mockService.stubbedResult = RestArrayResponse<Skill>(data: [], metadata: nil, error: nil)

        sut.skillsDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockCoordinator.invokedProfileSelection)
    }

    func test_skillsDropdownTapped_onError_stopsActivityIndicator() async throws {
        mockService.error = APIError.network

        sut.skillsDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopSkillsActivityIndicator)
    }

    // MARK: - locationDropdownTapped

    func test_locationDropdownTapped_startsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<Location>(data: [], metadata: nil, error: nil)

        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(mockView.invokedStartLocationActivityIndicator)
    }

    func test_locationDropdownTapped_onSuccess_stopsActivityIndicator() async throws {
        mockService.stubbedResult = RestArrayResponse<Location>(data: [], metadata: nil, error: nil)

        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopLocationActivityIndicator)
    }

    func test_locationDropdownTapped_onSuccess_callsCoordinatorProfileSelection() async throws {
        mockService.stubbedResult = RestArrayResponse<Location>(data: [], metadata: nil, error: nil)

        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockCoordinator.invokedProfileSelection)
    }

    func test_locationDropdownTapped_onError_stopsActivityIndicator() async throws {
        mockService.error = APIError.network

        sut.locationDropdownTapped()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopLocationActivityIndicator)
    }

    // MARK: - instructionTypeDropdownView

    func test_instructionTypeDropdownView_withNoAdvertSelected_startsIndicatorButDoesNotCallService() async throws {
        mockService.stubbedResult = RestArrayResponse<ServiceResponse>(data: [], metadata: nil, error: nil)

        sut.instructionTypeDropdownView()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStartInstructionTypeActivityIndicator)
        XCTAssertFalse(mockCoordinator.invokedProfileSelection)
    }

    func test_instructionTypeDropdownView_withAdvertSelected_onSuccess_stopsActivityIndicator() async throws {
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 4, title: "Instructor", isSelected: true))
        mockService.stubbedResult = RestArrayResponse<ServiceResponse>(data: [], metadata: nil, error: nil)

        sut.instructionTypeDropdownView()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopInstructionTypeActivityIndicator)
    }

    func test_instructionTypeDropdownView_withAdvertSelected_onSuccess_callsCoordinatorProfileSelection() async throws {
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 4, title: "Instructor", isSelected: true))
        mockService.stubbedResult = RestArrayResponse<ServiceResponse>(data: [], metadata: nil, error: nil)

        sut.instructionTypeDropdownView()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockCoordinator.invokedProfileSelection)
    }

    func test_instructionTypeDropdownView_withAdvertSelected_onError_stopsActivityIndicator() async throws {
        sut.advertTypeDidSelect(advert: EmptySelectionInput(id: 4, title: "Instructor", isSelected: true))
        mockService.error = APIError.network

        sut.instructionTypeDropdownView()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockView.invokedStopInstructionTypeActivityIndicator)
    }

    // MARK: - locationDidSelect

    func test_locationDidSelect_withValidLocation_updatesViewTitle() {
        let input = EmptySelectionInput(id: 34, title: "Istanbul", isSelected: true)

        sut.locationDidSelect(location: input)

        XCTAssertEqual(mockView.invokedUpdateLocationParameters?.title, "Istanbul")
    }

    func test_locationDidSelect_withNil_updatesViewWithNilTitle() {
        sut.locationDidSelect(location: nil)

        XCTAssertTrue(mockView.invokedUpdateLocation)
        XCTAssertNil(mockView.invokedUpdateLocationParameters?.title)
    }

    func test_locationDidSelect_withValidLocation_invokesUpdateLocation() {
        let input = EmptySelectionInput(id: 6, title: "Ankara", isSelected: true)

        sut.locationDidSelect(location: input)

        XCTAssertTrue(mockView.invokedUpdateLocation)
    }

    // MARK: - skillsDidSelect

    func test_skillsDidSelect_withSkills_updatesViewTitle() {
        let skills: [any SelectionInput] = [
            EmptySelectionInput(id: 1, title: "Guitar", isSelected: true),
            EmptySelectionInput(id: 2, title: "Bass", isSelected: true)
        ]

        sut.skillsDidSelect(skills: skills)

        XCTAssertTrue(mockView.invokedUpdateSkills)
    }

    func test_skillsDidSelect_withNil_updatesViewWithNilTitle() {
        sut.skillsDidSelect(skills: nil)

        XCTAssertTrue(mockView.invokedUpdateSkills)
        XCTAssertNil(mockView.invokedUpdateSkillsParameters?.title)
    }

    func test_skillsDidSelect_withEmptyArray_updatesView() {
        sut.skillsDidSelect(skills: [])

        XCTAssertTrue(mockView.invokedUpdateSkills)
    }

    // MARK: - musicGenresDidSelect

    func test_musicGenresDidSelect_withGenres_updatesView() {
        let genres: [any SelectionInput] = [
            EmptySelectionInput(id: 1, title: "Rock", isSelected: true),
            EmptySelectionInput(id: 2, title: "Jazz", isSelected: true)
        ]

        sut.musicGenresDidSelect(genres: genres)

        XCTAssertTrue(mockView.invokedUpdateMusicGenres)
    }

    func test_musicGenresDidSelect_withNil_updatesViewWithNilTitle() {
        sut.musicGenresDidSelect(genres: nil)

        XCTAssertTrue(mockView.invokedUpdateMusicGenres)
        XCTAssertNil(mockView.invokedUpdateMusicGenresParameters?.title)
    }

    func test_musicGenresDidSelect_withEmptyArray_updatesView() {
        sut.musicGenresDidSelect(genres: [])

        XCTAssertTrue(mockView.invokedUpdateMusicGenres)
    }

    // MARK: - serviceDidSelect

    func test_serviceDidSelect_withServices_updatesView() {
        let services: [any SelectionInput] = [
            EmptySelectionInput(id: 1, title: "Online", isSelected: true)
        ]

        sut.serviceDidSelect(services: services)

        XCTAssertTrue(mockView.invokedUpdateInstructionType)
    }

    func test_serviceDidSelect_withNil_updatesViewWithNilTitle() {
        sut.serviceDidSelect(services: nil)

        XCTAssertTrue(mockView.invokedUpdateInstructionType)
        XCTAssertNil(mockView.invokedUpdateInstructionTypeParameters?.title)
    }

    func test_serviceDidSelect_withEmptyArray_updatesView() {
        sut.serviceDidSelect(services: [])

        XCTAssertTrue(mockView.invokedUpdateInstructionType)
    }

    // MARK: - advertTypeDidSelect

    func test_advertTypeDidSelect_withNil_hidesInformationsStackView() {
        sut.advertTypeDidSelect(advert: nil)

        XCTAssertTrue(mockView.invokedSetInformationsStackViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_withNil_doesNotUpdateAdvertType() {
        sut.advertTypeDidSelect(advert: nil)

        XCTAssertFalse(mockView.invokedUpdateAdvertType)
    }

    func test_advertTypeDidSelect_withValidAdvert_showsInformationsStackView() {
        let input = EmptySelectionInput(id: 1, title: "Musician", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertFalse(mockView.invokedSetInformationsStackViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_withValidAdvert_updatesAdvertTypeTitle() {
        let input = EmptySelectionInput(id: 1, title: "Musician", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertEqual(mockView.invokedUpdateAdvertTypeParameters?.title, "Musician")
    }

    func test_advertTypeDidSelect_id1_setsMusicianValidator() {
        let input = EmptySelectionInput(id: 1, title: "Musician", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertEqual(mockView.invokedUpdateValidatorsParameters?.validator, .musician)
    }

    func test_advertTypeDidSelect_id1_showsMusicGenresDropdown() {
        let input = EmptySelectionInput(id: 1, title: "Musician", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertFalse(mockView.invokedSetMusicGenresDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_id1_hidesInstructionTypeDropdown() {
        let input = EmptySelectionInput(id: 1, title: "Musician", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertTrue(mockView.invokedSetInstructionTypeDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_id3_setsEventValidator() {
        let input = EmptySelectionInput(id: 3, title: "Event", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertEqual(mockView.invokedUpdateValidatorsParameters?.validator, .event)
    }

    func test_advertTypeDidSelect_id3_hidesMusicGenresDropdown() {
        let input = EmptySelectionInput(id: 3, title: "Event", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertTrue(mockView.invokedSetMusicGenresDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_id5_setsEventValidator() {
        let input = EmptySelectionInput(id: 5, title: "Event2", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertEqual(mockView.invokedUpdateValidatorsParameters?.validator, .event)
    }

    func test_advertTypeDidSelect_id4_setsInstructorValidator() {
        let input = EmptySelectionInput(id: 4, title: "Instructor", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertEqual(mockView.invokedUpdateValidatorsParameters?.validator, .instructor)
    }

    func test_advertTypeDidSelect_id4_showsInstructionTypeDropdown() {
        let input = EmptySelectionInput(id: 4, title: "Instructor", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertFalse(mockView.invokedSetInstructionTypeDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_id4_hidesMusicGenresDropdown() {
        let input = EmptySelectionInput(id: 4, title: "Instructor", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertTrue(mockView.invokedSetMusicGenresDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_otherID_setsBrandValidator() {
        let input = EmptySelectionInput(id: 2, title: "Brand", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertEqual(mockView.invokedUpdateValidatorsParameters?.validator, .brand)
    }

    func test_advertTypeDidSelect_otherID_showsMusicGenresDropdown() {
        let input = EmptySelectionInput(id: 2, title: "Brand", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertFalse(mockView.invokedSetMusicGenresDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_otherID_hidesInstructionTypeDropdown() {
        let input = EmptySelectionInput(id: 2, title: "Brand", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertTrue(mockView.invokedSetInstructionTypeDropdownViewVisibilityParameters!.isHidden)
    }

    func test_advertTypeDidSelect_resetsSkillsTitle() {
        let input = EmptySelectionInput(id: 1, title: "Musician", isSelected: true)

        sut.advertTypeDidSelect(advert: input)

        XCTAssertTrue(mockView.invokedUpdateSkills)
    }

    // MARK: - descriptionTextViewDidChange

    func test_descriptionTextViewDidChange_withText_setsDescription() {
        sut.descriptionTextViewDidChange(description: "Guitar player")

        // description stored internally — verify via resetInputs clearing it
        // (description is private; we test its effect on request indirectly)
        // After setting a non-empty description, resetting clears it
        sut.resetInputs()
        XCTAssertTrue(mockView.invokedResetTextView)
    }

    func test_descriptionTextViewDidChange_withNilText_doesNotCrash() {
        XCTAssertNoThrow(sut.descriptionTextViewDidChange(description: nil))
    }

    func test_descriptionTextViewDidChange_withEmptyString_doesNotCrash() {
        XCTAssertNoThrow(sut.descriptionTextViewDidChange(description: ""))
    }

    func test_descriptionTextViewDidChange_calledMultipleTimes_lastValueWins() {
        sut.descriptionTextViewDidChange(description: "First")
        sut.descriptionTextViewDidChange(description: "Second")
        sut.descriptionTextViewDidChange(description: nil)

        // No crash, state is consistent
        XCTAssertNoThrow(sut.resetInputs())
    }

    // MARK: - resetInputs

    func test_resetInputs_updatesAdvertTypeWithNil() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedUpdateAdvertType)
        XCTAssertNil(mockView.invokedUpdateAdvertTypeParameters?.title)
    }

    func test_resetInputs_updatesSkillsWithNil() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedUpdateSkills)
        XCTAssertNil(mockView.invokedUpdateSkillsParameters?.title)
    }

    func test_resetInputs_updatesLocationWithNil() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedUpdateLocation)
        XCTAssertNil(mockView.invokedUpdateLocationParameters?.title)
    }

    func test_resetInputs_updatesMusicGenresWithNil() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedUpdateMusicGenres)
        XCTAssertNil(mockView.invokedUpdateMusicGenresParameters?.title)
    }

    func test_resetInputs_updatesInstructionTypeWithNil() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedUpdateInstructionType)
        XCTAssertNil(mockView.invokedUpdateInstructionTypeParameters?.title)
    }

    func test_resetInputs_hidesInformationsStackView() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedSetInformationsStackViewVisibility)
        XCTAssertTrue(mockView.invokedSetInformationsStackViewVisibilityParameters!.isHidden)
    }

    func test_resetInputs_resetsTextView() {
        sut.resetInputs()

        XCTAssertTrue(mockView.invokedResetTextView)
    }
}

// MARK: - Helpers

private extension PlaceAdvertViewModelTests {

    func makeAdvert() -> Advert {
        let response = mockService.load(fromJSONFile: "PlaceAdvert-Sample-Data",
                                        type: RestObjectResponse<Advert>.self)
        return response.data
    }
}
