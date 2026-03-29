import XCTest
@testable import Armony
import SnapshotTesting

final class AvatarViewSnapshotTests: XCTestCase {
    var sut: AvatarView!

    override func setUp() {
        super.setUp()
        sut = AvatarView(frame: .init(origin: .zero, size: .init(width: 80, height: 80)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testAvatarCircledSmall() {
        sut.frame.size = .init(width: 52, height: 52)
        let presentation = AvatarPresentation(
            kind: .circled(.init(size: .small)),
            source: .static(.avatarPlaceholder)
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testAvatarCircledMedium() {
        let presentation = AvatarPresentation(
            kind: .circled(.init(size: .medium)),
            source: .static(.avatarPlaceholder)
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }

    func testAvatarCustomRadius() {
        let presentation = AvatarPresentation(
            kind: .custom(.init(size: .medium, radius: .high)),
            source: .static(.avatarPlaceholder)
        )
        sut.configure(with: presentation)
        sut.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image)
    }
}
