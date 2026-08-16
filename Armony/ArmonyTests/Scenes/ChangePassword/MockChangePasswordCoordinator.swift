//
//  MockChangePasswordCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import UIKit
@testable import Armony

final class MockChangePasswordCoordinator: ChangePasswordCoordinating {

    // MARK: - pop
    var invokedPop = false
    var invokedPopCount = 0
    var onPop: VoidCallback?

    func pop(animated: Bool) {
        invokedPop = true
        invokedPopCount += 1
        onPop?()
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

    func popToRootViewController(animated: Bool) {}

    var invokedOpen = false
    var invokedOpenParameters: (deeplink: Deeplink, Void)?

    func open(deeplink: Deeplink) {
        invokedOpen = true
        invokedOpenParameters = (deeplink, ())
    }

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        return nil
    }
}
