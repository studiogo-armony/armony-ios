//
//  CreateAdvertCoordinator.swift
//  Armony
//
//  Created by Koray Yıldız on 05.10.22.
//

import UIKit

private struct Constant {
    static let defaultTabBarImage = "tab-create-advert-default-icon".image
    static let selectedTabBarImage = "tab-create-advert-selected-icon".image
}

final class CreateAdvertCoordinator: Coordinator {

    typealias Controller = CreateAdvertViewController

    weak var navigator: Navigator?

    func start() -> UIViewController {
        let view = createViewController()
        let navigator = Navigator(rootViewController: view)
        let viewModel = CreateAdvertViewModel(view: view)
        viewModel.coordinator = self

        defer {
            self.navigator = navigator
        }

        view.viewModel = viewModel

        navigator.tabBarItem = UITabBarItem(
            title: "İlan Ver".needLocalization,
            image: Constant.defaultTabBarImage,
            selectedImage: Constant.selectedTabBarImage
        )

        navigator.tabBarItem.imageInsets = .init(top: 2, left: .zero, bottom: .zero, right: .zero)

        return navigator
    }

    func profileSelection(presentation: any SelectionPresentation) {
        SelectionBottomPopUpCoordinator(navigator: navigator).start(presentation: presentation)
    }
}
