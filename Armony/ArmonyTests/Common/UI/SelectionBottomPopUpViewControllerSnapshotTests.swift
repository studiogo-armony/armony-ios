//
//  SelectionBottomPopUpViewControllerSnapshotTests.swift
//  ArmonyTests
//

import XCTest
@testable import Armony
import SnapshotTesting

final class SelectionBottomPopUpViewControllerSnapshotTests: XCTestCase {

    private let width: CGFloat = 375

    func testSingleSelectionWithNoPreselection() {
        let presentation = TestSelectionPresentation(
            headerTitle: "Select Instrument",
            isMultipleSelectionAllowed: false,
            items: makeItems(count: 5, selectedIndices: [])
        )
        let sut = makeSUT(presentation: presentation)
        assertSnapshot(of: sut, as: .image(size: snapshotSize(for: sut)))
    }

    func testSingleSelectionWithPreselectedItem() {
        let presentation = TestSelectionPresentation(
            headerTitle: "Select Instrument",
            isMultipleSelectionAllowed: false,
            items: makeItems(count: 5, selectedIndices: [1])
        )
        let sut = makeSUT(presentation: presentation)
        assertSnapshot(of: sut, as: .image(size: snapshotSize(for: sut)))
    }

    func testMultipleSelectionWithNoPreselection() {
        let presentation = TestSelectionPresentation(
            headerTitle: "Select Genres",
            isMultipleSelectionAllowed: true,
            items: makeItems(count: 5, selectedIndices: [])
        )
        let sut = makeSUT(presentation: presentation)
        assertSnapshot(of: sut, as: .image(size: snapshotSize(for: sut)))
    }

    func testMultipleSelectionWithPreselectedItems() {
        let presentation = TestSelectionPresentation(
            headerTitle: "Select Genres",
            isMultipleSelectionAllowed: true,
            items: makeItems(count: 5, selectedIndices: [0, 2, 4])
        )
        let sut = makeSUT(presentation: presentation)
        assertSnapshot(of: sut, as: .image(size: snapshotSize(for: sut)))
    }

    // MARK: - Helpers

    private func makeSUT(presentation: TestSelectionPresentation) -> SelectionBottomPopUpViewController {
        let viewController = SelectionBottomPopUpViewController.controller()
        let viewModel = SelectionBottomPopUpViewModel(view: viewController, presentation: presentation)
        let coordinator = SelectionBottomPopUpCoordinator(navigator: nil)
        viewModel.coordinator = coordinator
        viewController.viewModel = viewModel
        viewController.loadViewIfNeeded()
        viewModel.viewDidLoad()
        viewController.view.layoutIfNeeded()
        return viewController
    }

    private func snapshotSize(for viewController: UIViewController) -> CGSize {
        return CGSize(width: width, height: 500)
    }

    private func makeItems(count: Int, selectedIndices: Set<Int>) -> [EmptySelectionInput] {
        let titles = ["Guitar", "Piano", "Drums", "Bass", "Violin", "Saxophone", "Flute", "Cello"]
        return (0..<count).map { index in
            EmptySelectionInput(
                id: index,
                title: titles[index % titles.count],
                isSelected: selectedIndices.contains(index)
            )
        }
    }
}

// MARK: - Test Presentation

private struct TestSelectionPresentation: SelectionPresentation {
    typealias Input = EmptySelectionInput
    typealias Output = SingleSelectionOutput<EmptySelectionInput>

    var headerTitle: String
    var isMultipleSelectionAllowed: Bool
    var items: [EmptySelectionInput]

    var output: SingleSelectionOutput<EmptySelectionInput> {
        return .init(output: items.first { $0.isSelected })
    }

    func continueButtonTapped() {}
}
