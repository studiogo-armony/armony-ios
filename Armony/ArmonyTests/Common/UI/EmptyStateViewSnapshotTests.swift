import XCTest
@testable import Armony
import SnapshotTesting

final class EmptyStateViewSnapshotTests: XCTestCase {
    var sut: EmptyStateView!

    private let width: CGFloat = 375

    override func setUp() {
        super.setUp()
        sut = EmptyStateView(frame: .init(origin: .zero, size: .init(width: width, height: 0)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testEmptyStateWithTitleOnly() {
        let presentation = EmptyStatePresentation(title: "No results found")
        sut.configure(with: presentation)
        let size = fittingSize()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testEmptyStateWithTitleAndSubtitle() {
        let presentation = EmptyStatePresentation(
            title: "No results found",
            subtitle: "Try adjusting your search filters"
        )
        sut.configure(with: presentation)
        let size = fittingSize()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testEmptyStateWithAllElements() {
        let presentation = EmptyStatePresentation(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No results found",
            subtitle: "Try adjusting your search filters",
            buttonTitle: "Clear Filters"
        )
        sut.configure(with: presentation)
        let size = fittingSize()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    // MARK: - Helpers

    private func fittingSize() -> CGSize {
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = sut.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: fittedSize.height)
    }
}
