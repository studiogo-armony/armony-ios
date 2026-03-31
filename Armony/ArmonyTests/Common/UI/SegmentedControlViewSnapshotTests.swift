import XCTest
@testable import Armony
import SnapshotTesting

final class SegmentedControlViewSnapshotTests: XCTestCase {
    var sut: SegmentedControlView!

    override func setUp() {
        super.setUp()
        sut = SegmentedControlView(frame: .init(origin: .zero, size: .init(width: 375, height: 40)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testSegmentedControlTwoItems() {
        let presentation = SegmentedControlPresentation(
            items: ["Tab 1", "Tab 2"],
            selectedIndex: 0
        )
        sut.configure(presentation: presentation)
        sut.layoutIfNeeded()

        let expectation = expectation(description: "wait for selection")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        assertSnapshot(of: sut, as: .image)
    }

    func testSegmentedControlThreeItems() {
        let presentation = SegmentedControlPresentation(
            items: ["First", "Second", "Third"],
            selectedIndex: 1
        )
        sut.configure(presentation: presentation)
        sut.layoutIfNeeded()

        let expectation = expectation(description: "wait for selection")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        assertSnapshot(of: sut, as: .image)
    }
}
