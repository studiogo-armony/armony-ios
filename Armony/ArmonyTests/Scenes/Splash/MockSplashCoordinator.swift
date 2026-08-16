//
//  MockSplashCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import UIKit
@testable import Armony

final class MockSplashCoordinator: SplashCoordinating {

    // MARK: - armony
    var invokedArmony = false
    var invokedArmonyCount = 0
    var onArmony: VoidCallback?

    func armony() {
        invokedArmony = true
        invokedArmonyCount += 1
        onArmony?()
    }

    // MARK: - open(urlString:)
    var invokedOpenURLString = false
    var invokedOpenURLStringCount = 0
    var invokedOpenURLStringParameters: (urlString: String, Void)?
    var onOpenURLString: VoidCallback?

    func open(urlString: String) {
        invokedOpenURLString = true
        invokedOpenURLStringCount += 1
        invokedOpenURLStringParameters = (urlString, ())
        onOpenURLString?()
    }

    // MARK: - CoordinatorInterface
    var invokedDismiss = false
    var invokedDismissCount = 0
    var onDismiss: VoidCallback?

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        invokedDismissCount += 1
        completion?()
        onDismiss?()
    }

    func pop(animated: Bool) {}
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
