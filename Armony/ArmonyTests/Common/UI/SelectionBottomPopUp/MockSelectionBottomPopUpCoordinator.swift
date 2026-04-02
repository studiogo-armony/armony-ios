//
//  MockSelectionBottomPopUpCoordinator.swift
//  ArmonyTests
//

import UIKit
@testable import Armony

final class MockSelectionBottomPopUpCoordinator: SelectionBottomPopUpCoordinating {

    var invokedDismiss = false
    var invokedDismissCount = 0
    var invokedDismissParameters: (animated: Bool, completion: VoidCallback?)?
    var shouldCallDismissCompletion = true

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        invokedDismissCount += 1
        invokedDismissParameters = (animated, completion)
        if shouldCallDismissCompletion {
            completion?()
        }
    }
}
