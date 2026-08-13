import XCTest
@testable import Armony
import SnapshotTesting

final class TitleAccessoryViewSnapshotTests: XCTestCase {
    var sut: TitleAccessoryView!

    override func setUp() {
        super.setUp()
        sut = TitleAccessoryView(frame: .init(origin: .zero, size: .init(width: 300, height: 40)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testTitleAccessoryWithTitleAndImage() {
        let presentation = TitleAccessoryPresentation(
            title: "Skills".attributed(.armonyWhite, font: .regularBody),
            accessoryImage: .static(UIImage(systemName: "chevron.right"))
        )
        sut.configure(with: presentation)
        assertSnapshot(of: sut, as: .image)
    }

    func testTitleAccessoryWithEmptyPresentation() {
        sut.configure(with: .empty)
        assertSnapshot(of: sut, as: .image)
    }
}
