import XCTest
@testable import Armony
import SnapshotTesting

final class NavigationHeaderViewSnapshotTests: XCTestCase {
    var sut: NavigationHeaderView!

    override func setUp() {
        super.setUp()
        sut = NavigationHeaderView(frame: .init(origin: .zero, size: .init(width: 375, height: 150)))
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
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testNavigationHeaderWithTitleAndSubtitle() {
        let presentation = NavigationHeaderPresentation(
            title: "Heading".attributed(.armonyWhite, font: .semiboldHeading),
            subtitle: "Subheading text".attributed(.armonyWhite, font: .lightBody)
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testNavigationHeaderWithCustomInsets() {
        let presentation = NavigationHeaderPresentation(
            title: "Heading".attributed(.armonyWhite, font: .semiboldHeading),
            subtitle: "Subheading text".attributed(.armonyWhite, font: .lightBody),
            insets: UIEdgeInsets(horizontal: 32, vertical: 8)
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }
}
