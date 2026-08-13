import XCTest
@testable import Armony
import SnapshotTesting

final class GradientViewSnapshotTests: XCTestCase {
    var sut: GradientView!

    override func setUp() {
        super.setUp()
        sut = GradientView(frame: .init(origin: .zero, size: .init(width: 300, height: 120)))
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testGradientAdvertVertical() {
        sut.configure(with: .init(orientation: .vertical, color: .advert))
        assertSnapshot(of: sut, as: .image)
    }

    func testGradientLoginVertical() {
        sut.configure(with: .init(orientation: .vertical, color: .login))
        assertSnapshot(of: sut, as: .image)
    }

    func testGradientSeparatorHorizontal() {
        sut.configure(with: .separator)
        assertSnapshot(of: sut, as: .image)
    }

    func testGradientAdvertHorizontal() {
        sut.configure(with: .init(orientation: .horizontal, color: .advert))
        assertSnapshot(of: sut, as: .image)
    }

    func testGradientAdvertLeftAcross() {
        sut.configure(with: .init(orientation: .leftAcross, color: .advert))
        assertSnapshot(of: sut, as: .image)
    }

    func testGradientAdvertRightAcross() {
        sut.configure(with: .init(orientation: .rightAcross, color: .advert))
        assertSnapshot(of: sut, as: .image)
    }
}
