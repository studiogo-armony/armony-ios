//
//  MockPlaceAdvertCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 11.08.26.
//

import UIKit
@testable import Armony

final class MockPlaceAdvertCoordinator: PlaceAdvertCoordinating {

    // MARK: - profileSelection
    var invokedProfileSelection = false
    var invokedProfileSelectionCount = 0
    var invokedProfileSelectionParameters: (presentation: any SelectionPresentation, Void)?

    func profileSelection(presentation: any SelectionPresentation) {
        invokedProfileSelection = true
        invokedProfileSelectionCount += 1
        invokedProfileSelectionParameters = (presentation, ())
    }

    // MARK: - dismiss
    var invokedDismiss = false
    var invokedDismissCount = 0
    var invokedDismissParameters: (animated: Bool, completion: VoidCallback?)?

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        invokedDismissCount += 1
        invokedDismissParameters = (animated, completion)
        completion?()
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
    var onSelectTab: VoidCallback?

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        invokedSelectTab = true
        invokedSelectTabCount += 1
        invokedSelectTabParameters = (tab, shouldPopToRoot)
        onSelectTab?()
        return stubbedSelectTabResult
    }
}
