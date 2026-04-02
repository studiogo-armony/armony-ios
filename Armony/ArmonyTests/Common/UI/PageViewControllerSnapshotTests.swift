//
//  PageViewControllerSnapshotTests.swift
//  ArmonyTests
//

import XCTest
@testable import Armony
import SnapshotTesting

final class PageViewControllerSnapshotTests: XCTestCase {

    private let size = CGSize(width: 375, height: 300)

    func testPageViewControllerFirstPage() {
        let sut = makeSUT(childCount: 3)
        sut.setViewControllers(sut.children)
        sut.view.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testPageViewControllerMiddlePage() {
        let sut = makeSUT(childCount: 3)
        sut.setViewControllers(sut.children, initialIndex: 1)
        sut.view.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    func testPageViewControllerMoveForward() {
        let sut = makeSUT(childCount: 3)
        sut.setViewControllers(sut.children)
        sut.move(at: 2)
        sut.view.layoutIfNeeded()
        assertSnapshot(of: sut, as: .image(size: size))
    }

    // MARK: - Helpers

    private func makeSUT(childCount: Int) -> PageViewController {
        let sut = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        sut.view.frame = CGRect(origin: .zero, size: size)

        let colors: [UIColor] = [.armonyPurple, .armonyPink, .armonyBlue]
        let titles = ["Page 1", "Page 2", "Page 3"]

        let children = (0..<childCount).map { index in
            let vc = UIViewController()
            vc.view.backgroundColor = colors[index % colors.count]
            let label = UILabel()
            label.text = titles[index % titles.count]
            label.textColor = .armonyWhite
            label.font = .semiboldHeading
            label.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
            ])
            return vc
        }

        children.forEach { sut.addChild($0) }

        sut.loadViewIfNeeded()
        return sut
    }
}
