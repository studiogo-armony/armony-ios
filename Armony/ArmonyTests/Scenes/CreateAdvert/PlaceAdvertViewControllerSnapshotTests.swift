//
//  PlaceAdvertViewControllerSnapshotTests.swift
//  ArmonyTests
//

import XCTest
@testable import Armony
import SnapshotTesting

final class PlaceAdvertViewControllerSnapshotTests: SnapshotTestCase {

    private var sut: PlaceAdvertViewController!
    private var viewModel: PlaceAdvertViewModel!

    override func setUp() {
        super.setUp()
        sut = PlaceAdvertViewController.controller()
        viewModel = PlaceAdvertViewModel(
            view: sut,
            authenticator: MockAuthenticationService(),
            purchaseStorage: MockRevenueCatPurchaseStorageService(),
            appRating: MockAppRatingService(),
            service: MockRestService(backend: .factory())
        )
        viewModel.coordinator = MockPlaceAdvertCoordinator()
        sut.viewModel = viewModel

        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
    }

    override func tearDown() {
        sut = nil
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    // MARK: - Advert type selection

    func testMusicianAdvertTypeSelected() {
        selectAdvertType(id: 1, title: "Band")

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testBrandAdvertTypeSelected() {
        selectAdvertType(id: 2, title: "Musician")

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testEventAdvertTypeSelected() {
        selectAdvertType(id: 3, title: "Rental")

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testInstructorAdvertTypeSelected() {
        selectAdvertType(id: 4, title: "Lessons")

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    // MARK: - Filled forms

    func testMusicianFormFilled() {
        selectAdvertType(id: 1, title: "Band")
        viewModel.musicGenresDidSelect(genres: [makeInput(id: 2, title: "Rock")])
        viewModel.skillsDidSelect(skills: [makeInput(id: 7, title: "Guitar")])
        viewModel.locationDidSelect(location: makeInput(id: 34, title: "Istanbul"))

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testEventFormFilled() {
        selectAdvertType(id: 3, title: "Rental")
        viewModel.skillsDidSelect(skills: [makeInput(id: 7, title: "Studio")])
        viewModel.locationDidSelect(location: makeInput(id: 34, title: "Istanbul"))

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testInstructorFormFilled() {
        selectAdvertType(id: 4, title: "Lessons")
        viewModel.skillsDidSelect(skills: [makeInput(id: 8, title: "Piano")])
        viewModel.locationDidSelect(location: makeInput(id: 6, title: "Ankara"))
        viewModel.serviceDidSelect(services: [makeInput(id: 10, title: "Online")])

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testFilledFormAfterAdvertTypeChange() {
        selectAdvertType(id: 1, title: "Band")
        viewModel.musicGenresDidSelect(genres: [makeInput(id: 2, title: "Rock")])
        viewModel.skillsDidSelect(skills: [makeInput(id: 7, title: "Guitar")])
        viewModel.locationDidSelect(location: makeInput(id: 34, title: "Istanbul"))

        selectAdvertType(id: 4, title: "Lessons")

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    func testFilledFormAfterResetInputs() {
        selectAdvertType(id: 1, title: "Band")
        viewModel.musicGenresDidSelect(genres: [makeInput(id: 2, title: "Rock")])
        viewModel.skillsDidSelect(skills: [makeInput(id: 7, title: "Guitar")])
        viewModel.locationDidSelect(location: makeInput(id: 34, title: "Istanbul"))

        viewModel.resetInputs()

        assertSnapshot(of: sut, as: .image(on: .iPhone13))
    }

    // MARK: - Helpers

    private func selectAdvertType(id: Int, title: String) {
        viewModel.advertTypeDidSelect(advert: makeInput(id: id, title: title))
    }

    private func makeInput(id: Int, title: String) -> EmptySelectionInput {
        return EmptySelectionInput(id: id, title: title, isSelected: true)
    }
}
