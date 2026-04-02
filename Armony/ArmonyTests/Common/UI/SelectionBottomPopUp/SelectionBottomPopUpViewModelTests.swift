//
//  SelectionBottomPopUpViewModelTests.swift
//  ArmonyTests
//

import XCTest
@testable import Armony

final class SelectionBottomPopUpViewModelTests: XCTestCase {

    var mockView: MockSelectionBottomPopUpView!
    var mockCoordinator: MockSelectionBottomPopUpCoordinator!
    var sut: SelectionBottomPopUpViewModel!

    override func setUp() {
        super.setUp()
        mockView = MockSelectionBottomPopUpView()
        mockCoordinator = MockSelectionBottomPopUpCoordinator()
    }

    override func tearDown() {
        super.tearDown()
        mockView = nil
        mockCoordinator = nil
        sut = nil
    }

    // MARK: - viewDidLoad

    func test_viewDidLoad_callsConfigureUI() {
        // Given
        makeSUT(items: makeItems(count: 3))

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(mockView.invokedConfigureUI)
        XCTAssertEqual(mockView.invokedConfigureUICount, 1)
    }

    func test_viewDidLoad_callsConfigureTableViewWithCorrectSelectionMode() {
        // Given
        makeSUT(items: makeItems(count: 3), isMultipleSelectionAllowed: true)

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(mockView.invokedConfigureTableView)
        XCTAssertEqual(mockView.invokedConfigureTableViewParameters?.isMultipleSelectionAllowed, true)
    }

    func test_viewDidLoad_singleSelectionMode_configuresTableViewCorrectly() {
        // Given
        makeSUT(items: makeItems(count: 3), isMultipleSelectionAllowed: false)

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(mockView.invokedConfigureTableViewParameters?.isMultipleSelectionAllowed, false)
    }

    func test_viewDidLoad_callsReloadData() {
        // Given
        makeSUT(items: makeItems(count: 3))

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(mockView.invokedReloadData)
    }

    func test_viewDidLoad_withPreselectedItems_callsSelectRowForEachSelectedItem() {
        // Given
        let items = makeItems(count: 5, selectedIndices: [1, 3])
        makeSUT(items: items)

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(mockView.invokedSelectRow)
        XCTAssertEqual(mockView.invokedSelectRowCount, 2)
        XCTAssertEqual(mockView.invokedSelectRowParametersList[0].indexPath, IndexPath(row: 1, section: 0))
        XCTAssertEqual(mockView.invokedSelectRowParametersList[1].indexPath, IndexPath(row: 3, section: 0))
    }

    func test_viewDidLoad_withNoPreselectedItems_doesNotCallSelectRow() {
        // Given
        makeSUT(items: makeItems(count: 3))

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertFalse(mockView.invokedSelectRow)
    }

    // MARK: - headerTitle

    func test_headerTitle_returnsCorrectTitle() {
        // Given
        makeSUT(items: makeItems(count: 1), headerTitle: "Select Genre")

        // Then
        XCTAssertEqual(sut.headerTitle, "Select Genre")
    }

    // MARK: - numberOfRowsInSection

    func test_numberOfRowsInSection_returnsItemCount() {
        // Given
        makeSUT(items: makeItems(count: 5))

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 5)
    }

    func test_numberOfRowsInSection_withEmptyItems_returnsZero() {
        // Given
        makeSUT(items: [])

        // Then
        XCTAssertEqual(sut.numberOfRowsInSection, 0)
    }

    // MARK: - items(at:)

    func test_itemsAtIndexPath_returnsCorrectItem() {
        // Given
        let items = makeItems(count: 3)
        makeSUT(items: items)

        // When
        let item = sut.items(at: IndexPath(row: 1, section: 0))

        // Then
        XCTAssertEqual(item.id, 1)
        XCTAssertEqual(item.title, "Piano")
    }

    // MARK: - imageName(for:)

    func test_imageName_whenSingleSelectionAndItemSelected_returnsRadioButtonSelected() {
        // Given
        makeSUT(items: makeItems(count: 1, selectedIndices: [0]), isMultipleSelectionAllowed: false)
        var item = sut.items(at: IndexPath(row: 0, section: 0))
        item.isSelected = true

        // When
        let imageName = sut.imageName(for: item)

        // Then
        XCTAssertEqual(imageName, "radio-button-selected-icon")
    }

    func test_imageName_whenSingleSelectionAndItemNotSelected_returnsRadioButtonDefault() {
        // Given
        makeSUT(items: makeItems(count: 1), isMultipleSelectionAllowed: false)
        let item = sut.items(at: IndexPath(row: 0, section: 0))

        // When
        let imageName = sut.imageName(for: item)

        // Then
        XCTAssertEqual(imageName, "radio-button-default-icon")
    }

    func test_imageName_whenMultipleSelectionAndItemSelected_returnsCheckboxSelected() {
        // Given
        makeSUT(items: makeItems(count: 1, selectedIndices: [0]), isMultipleSelectionAllowed: true)
        var item = sut.items(at: IndexPath(row: 0, section: 0))
        item.isSelected = true

        // When
        let imageName = sut.imageName(for: item)

        // Then
        XCTAssertEqual(imageName, "checkbox-selected-icon")
    }

    func test_imageName_whenMultipleSelectionAndItemNotSelected_returnsCheckboxDefault() {
        // Given
        makeSUT(items: makeItems(count: 1), isMultipleSelectionAllowed: true)
        let item = sut.items(at: IndexPath(row: 0, section: 0))

        // When
        let imageName = sut.imageName(for: item)

        // Then
        XCTAssertEqual(imageName, "checkbox-default-icon")
    }

    // MARK: - continueButtonDidTap

    func test_continueButtonDidTap_dismissesCoordinator() {
        // Given
        makeSUT(items: makeItems(count: 1))

        // When
        sut.continueButtonDidTap()

        // Then
        XCTAssertTrue(mockCoordinator.invokedDismiss)
        XCTAssertEqual(mockCoordinator.invokedDismissParameters?.animated, true)
    }

    func test_continueButtonDidTap_callsContinueButtonTappedOnPresentation() {
        // Given
        var continueButtonTappedCalled = false
        let presentation = TestSelectionPresentation(
            headerTitle: "Test",
            isMultipleSelectionAllowed: false,
            items: makeItems(count: 1),
            onContinueButtonTapped: { continueButtonTappedCalled = true }
        )
        sut = SelectionBottomPopUpViewModel(view: mockView, presentation: presentation)
        sut.coordinator = mockCoordinator

        // When
        sut.continueButtonDidTap()

        // Then
        XCTAssertTrue(continueButtonTappedCalled)
    }

    // MARK: - willSelectItem

    func test_willSelectItem_whenUnderLimit_returnsIndexPath() {
        // Given
        makeSUT(items: makeItems(count: 3))
        let indexPath = IndexPath(row: 0, section: 0)

        // When
        let result = sut.willSelectItem(at: indexPath, indexPathsForSelectedRows: nil)

        // Then
        XCTAssertEqual(result, indexPath)
    }

    func test_willSelectItem_whenNineSelected_returnsIndexPath() {
        // Given
        makeSUT(items: makeItems(count: 11))
        let indexPath = IndexPath(row: 9, section: 0)
        let selectedRows = (0..<9).map { IndexPath(row: $0, section: 0) }

        // When
        let result = sut.willSelectItem(at: indexPath, indexPathsForSelectedRows: selectedRows)

        // Then
        XCTAssertEqual(result, indexPath)
    }

    func test_willSelectItem_whenTenSelected_returnsNil() {
        // Given
        makeSUT(items: makeItems(count: 11))
        let indexPath = IndexPath(row: 10, section: 0)
        let selectedRows = (0..<10).map { IndexPath(row: $0, section: 0) }

        // When
        let result = sut.willSelectItem(at: indexPath, indexPathsForSelectedRows: selectedRows)

        // Then
        XCTAssertNil(result)
    }

    // MARK: - footerViewActionButtonTitle

    func test_footerViewActionButtonTitle_returnsDefaultContinueTitle() {
        // Given
        makeSUT(items: makeItems(count: 1))

        // Then
        XCTAssertFalse(sut.footerViewActionButtonTitle.isEmpty)
    }

    // MARK: - Helpers

    @discardableResult
    private func makeSUT(
        items: [EmptySelectionInput],
        isMultipleSelectionAllowed: Bool = false,
        headerTitle: String = "Test Header"
    ) -> SelectionBottomPopUpViewModel {
        let presentation = TestSelectionPresentation(
            headerTitle: headerTitle,
            isMultipleSelectionAllowed: isMultipleSelectionAllowed,
            items: items
        )
        sut = SelectionBottomPopUpViewModel(view: mockView, presentation: presentation)
        sut.coordinator = mockCoordinator
        return sut
    }

    private func makeItems(count: Int, selectedIndices: Set<Int> = []) -> [EmptySelectionInput] {
        let titles = ["Guitar", "Piano", "Drums", "Bass", "Violin", "Saxophone", "Flute", "Cello", "Trumpet", "Harp", "Tuba"]
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
    var onContinueButtonTapped: (() -> Void)?

    var output: SingleSelectionOutput<EmptySelectionInput> {
        return .init(output: items.first { $0.isSelected })
    }

    func continueButtonTapped() {
        onContinueButtonTapped?()
    }
}
