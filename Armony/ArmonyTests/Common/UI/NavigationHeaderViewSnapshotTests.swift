import XCTest
@testable import Armony
import SnapshotTesting

final class NavigationHeaderViewSnapshotTests: XCTestCase {
    var sut: NavigationHeaderView!

    private let width: CGFloat = 375

    override func setUp() {
        super.setUp()
        sut = NavigationHeaderView(frame: .init(origin: .zero, size: .init(width: width, height: 0)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testNavigationHeaderWithTitleOnly() {
        let presentation = NavigationHeaderPresentation(
            title: "Heading".attributed(.armonyWhite, font: .semiboldHeading)
        )
        sut.configure(with: presentation)
        let size = fittingSize()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testNavigationHeaderWithTitleAndSubtitle() {
        let presentation = NavigationHeaderPresentation(
            title: "Heading".attributed(.armonyWhite, font: .semiboldHeading),
            subtitle: "Subheading text".attributed(.armonyWhite, font: .lightBody)
        )
        sut.configure(with: presentation)
        let size = fittingSize()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testNavigationHeaderWithCustomInsets() {
        let presentation = NavigationHeaderPresentation(
            title: "Heading".attributed(.armonyWhite, font: .semiboldHeading),
            subtitle: "Subheading text".attributed(.armonyWhite, font: .lightBody),
            insets: UIEdgeInsets(horizontal: 32, vertical: 8)
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
