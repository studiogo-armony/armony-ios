import XCTest
@testable import Armony
import SnapshotTesting

final class MusicGenresViewSnapshotTests: XCTestCase {
    var sut: MusicGenresView!

    private let width: CGFloat = 375

    override func setUp() {
        super.setUp()
        sut = MusicGenresView(frame: .init(origin: .zero, size: .init(width: width, height: 0)))
        sut.backgroundColor = .armonyBlack
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testMusicGenresView() {
        let genres = makeGenres()
        let items = genres.map {
            MusicGenreItemPresentation(
                genre: $0,
                titleStyle: TextAppearancePresentation(color: .white, font: .regularBody)
            )
        }
        let presentation = MusicGenresPresentation(
            cellBorderColor: .armonyWhite,
            items: items
        )
        sut.configure(with: presentation)
        let size = fittingSize()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testMusicGenresViewSingleItem() {
        let items = [
            MusicGenreItemPresentation(
                genre: MusicGenre(id: 1, name: "Rock"),
                titleStyle: TextAppearancePresentation(color: .white, font: .regularBody)
            )
        ]
        let presentation = MusicGenresPresentation(
            cellBorderColor: .armonyWhite,
            items: items
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

    private func makeGenres() -> [MusicGenre] {
        return [
            MusicGenre(id: 1, name: "Rock"),
            MusicGenre(id: 2, name: "Jazz"),
            MusicGenre(id: 3, name: "Classical"),
            MusicGenre(id: 4, name: "Pop"),
        ]
    }
}
