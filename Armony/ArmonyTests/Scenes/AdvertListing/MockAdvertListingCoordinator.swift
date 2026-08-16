//
//  MockAdvertListingCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

import UIKit
@testable import Armony

final class MockAdvertListingCoordinator: AdvertListingCoordinating {

    // MARK: - advert
    var invokedAdvert = false
    var invokedAdvertCount = 0
    var invokedAdvertParameters: (id: Int, colorCode: String)?
    var onAdvert: VoidCallback?

    func advert(id: Int, colorCode: String) {
        invokedAdvert = true
        invokedAdvertCount += 1
        invokedAdvertParameters = (id, colorCode)
        onAdvert?()
    }

    // MARK: - pop
    var invokedPop = false

    func pop(animated: Bool) {
        invokedPop = true
    }

    // MARK: - dismiss
    var invokedDismiss = false

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        completion?()
    }

    func popToRootViewController(animated: Bool) {}

    func open(deeplink: Deeplink) {}

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        return nil
    }
}
