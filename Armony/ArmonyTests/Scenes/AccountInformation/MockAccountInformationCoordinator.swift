//
//  MockAccountInformationCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.08.26.
//

import UIKit
@testable import Armony

final class MockAccountInformationCoordinator: AccountInformationCoordinating {

    // MARK: - selectionBottomPopUp
    var invokedSelectionBottomPopUp = false
    var invokedSelectionBottomPopUpCount = 0
    var invokedSelectionBottomPopUpParameters: (presentation: any SelectionPresentation, Void)?
    var onSelectionBottomPopUp: VoidCallback?

    func selectionBottomPopUp(presentation: any SelectionPresentation) {
        invokedSelectionBottomPopUp = true
        invokedSelectionBottomPopUpCount += 1
        invokedSelectionBottomPopUpParameters = (presentation, ())
        onSelectionBottomPopUp?()
    }

    // MARK: - startFromSktratch
    var invokedStartFromSktratch = false
    var invokedStartFromSktratchCount = 0
    var onStartFromSktratch: VoidCallback?

    func startFromSktratch() {
        invokedStartFromSktratch = true
        invokedStartFromSktratchCount += 1
        onStartFromSktratch?()
    }

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

    // MARK: - popToRootViewController
    var invokedPopToRootViewController = false

    func popToRootViewController(animated: Bool) {
        invokedPopToRootViewController = true
    }

    // MARK: - open(deeplink:)
    var invokedOpen = false
    var invokedOpenParameters: (deeplink: Deeplink, Void)?

    func open(deeplink: Deeplink) {
        invokedOpen = true
        invokedOpenParameters = (deeplink, ())
    }

    // MARK: - selectTab
    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        return nil
    }
}
