import XCTest
@testable import Armony
import SnapshotTesting

final class ExpandableLabelSnapshotTests: XCTestCase {
    var sut: ExpandableLabel!

    override func setUp() {
        super.setUp()
        sut = ExpandableLabel(frame: .init(origin: .zero, size: .init(width: 300, height: 100)))
        sut.backgroundColor = .armonyBlack
        sut.textColor = .armonyWhite
        sut.font = .regularBody
        sut.numberOfLines = 2
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testExpandableLabelCollapsed() {
        sut.collapsedAttributedLink = NSAttributedString(
            string: "More",
            attributes: [.foregroundColor: UIColor.armonyPurple, .font: UIFont.boldSystemFont(ofSize: 14)]
        )
        sut.text = "This is a long text that should be truncated after two lines. It contains enough content to demonstrate the collapse behavior of the expandable label component."
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testExpandableLabelExpanded() {
        sut.collapsedAttributedLink = NSAttributedString(
            string: "More",
            attributes: [.foregroundColor: UIColor.armonyPurple, .font: UIFont.boldSystemFont(ofSize: 14)]
        )
        sut.text = "This is a long text that should be truncated after two lines. It contains enough content to demonstrate the collapse behavior of the expandable label component."
        sut.collapsed = false
        sut.frame.size.height = 200
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testExpandableLabelShortText() {
        sut.text = "Short text"
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }
}
