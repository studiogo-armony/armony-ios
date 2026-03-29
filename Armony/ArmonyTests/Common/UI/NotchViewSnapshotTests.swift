import XCTest
@testable import Armony
import SnapshotTesting

final class NotchViewSnapshotTests: XCTestCase {
    var sut: NotchView!

    override func setUp() {
        super.setUp()
        sut = NotchView(frame: .init(origin: .zero, size: .init(width: 300, height: 34)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testNotchViewDefaultAppearance() {
        assertSnapshot(of: sut, as: .image)
    }
}
