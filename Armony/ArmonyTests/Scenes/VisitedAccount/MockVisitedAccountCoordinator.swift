//
//  MockVisitedAccountCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.08.26.
//

import UIKit
@testable import Armony

final class MockVisitedAccountCoordinator: VisitedAccountCoordinating {

    // MARK: - avatar
    var invokedAvatar = false
    var invokedAvatarCount = 0
    var invokedAvatarParameters: (imageSource: ImageSource, Void)?

    func avatar(with imageSource: ImageSource) {
        invokedAvatar = true
        invokedAvatarCount += 1
        invokedAvatarParameters = (imageSource, ())
    }

    // MARK: - dismiss
    var invokedDismiss = false
    var invokedDismissCount = 0
    var onDismiss: VoidCallback?

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        invokedDismissCount += 1
        completion?()
        onDismiss?()
    }

    // MARK: - pop
    var invokedPop = false
    var invokedPopCount = 0

    func pop(animated: Bool) {
        invokedPop = true
        invokedPopCount += 1
    }

    // MARK: - popToRootViewController
    var invokedPopToRootViewController = false
    var invokedPopToRootViewControllerCount = 0

    func popToRootViewController(animated: Bool) {
        invokedPopToRootViewController = true
        invokedPopToRootViewControllerCount += 1
    }

    // MARK: - open(deeplink:)
    var invokedOpen = false
    var invokedOpenCount = 0
    var invokedOpenParameters: (deeplink: Deeplink, Void)?

    func open(deeplink: Deeplink) {
        invokedOpen = true
        invokedOpenCount += 1
        invokedOpenParameters = (deeplink, ())
    }

    // MARK: - selectTab
    var invokedSelectTab = false
    var invokedSelectTabCount = 0
    var invokedSelectTabParameters: (tab: Common.Tab, shouldPopToRoot: Bool)?
    var stubbedSelectTabResult: UIViewController?

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        invokedSelectTab = true
        invokedSelectTabCount += 1
        invokedSelectTabParameters = (tab, shouldPopToRoot)
        return stubbedSelectTabResult
    }
}
