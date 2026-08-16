//
//  MockLogOutBottomPopUpCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import UIKit
@testable import Armony

final class MockLogOutBottomPopUpCoordinator: LogOutBottomPopUpCoordinating {

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

    func pop(animated: Bool) {
        invokedPop = true
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
    var invokedOpenParameters: (deeplink: Deeplink, Void)?

    func open(deeplink: Deeplink) {
        invokedOpen = true
        invokedOpenParameters = (deeplink, ())
    }

    // MARK: - selectTab
    var invokedSelectTab = false
    var invokedSelectTabParameters: (tab: Common.Tab, shouldPopToRoot: Bool)?

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        invokedSelectTab = true
        invokedSelectTabParameters = (tab, shouldPopToRoot)
        return nil
    }
}
