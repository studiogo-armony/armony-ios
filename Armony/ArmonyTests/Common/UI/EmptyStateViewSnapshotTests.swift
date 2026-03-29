import XCTest
@testable import Armony
import SnapshotTesting

final class EmptyStateViewSnapshotTests: XCTestCase {
    var sut: EmptyStateView!

    override func setUp() {
        super.setUp()
        sut = EmptyStateView(frame: .init(origin: .zero, size: .init(width: 375, height: 300)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testEmptyStateWithTitleOnly() {
        let presentation = EmptyStatePresentation(title: "No results found")
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testEmptyStateWithTitleAndSubtitle() {
        let presentation = EmptyStatePresentation(
            title: "No results found",
            subtitle: "Try adjusting your search filters"
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testEmptyStateWithAllElements() {
        let presentation = EmptyStatePresentation(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No results found",
            subtitle: "Try adjusting your search filters",
            buttonTitle: "Clear Filters"
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }
}
