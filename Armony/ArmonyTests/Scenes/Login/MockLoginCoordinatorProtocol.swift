//
//  MockLoginCoordinatorProtocol.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 13.08.26.
//

import UIKit
@testable import Armony

final class MockLoginCoordinatorProtocol: LoginCoordinating {

    // MARK: - showForgotPasswordView
    var invokedShowForgotPasswordView = false
    var invokedShowForgotPasswordViewCount = 0
    var invokedShowForgotPasswordViewParameters: (email: String, actionButtonTapped: Callback<String>?)?
    var stubbedActionButtonTappedEmail: String?

    func showForgotPasswordView(email: String, actionButtonTapped: Callback<String>?) {
        invokedShowForgotPasswordView = true
        invokedShowForgotPasswordViewCount += 1
        invokedShowForgotPasswordViewParameters = (email, actionButtonTapped)
        if let stubbedEmail = stubbedActionButtonTappedEmail {
            actionButtonTapped?(stubbedEmail)
        }
    }

    // MARK: - registration
    var invokedRegistration = false
    var invokedRegistrationCount = 0
    var invokedRegistrationParameters: (registrationCompletion: VoidCallback?, loginCompletion: VoidCallback?)?

    func registration(registrationCompletion: VoidCallback?, loginCompletion: VoidCallback?) {
        invokedRegistration = true
        invokedRegistrationCount += 1
        invokedRegistrationParameters = (registrationCompletion, loginCompletion)
    }

    // MARK: - dismiss
    var invokedDismiss = false
    var invokedDismissCount = 0
    var invokedDismissParameters: (animated: Bool, completion: VoidCallback?)?
    var onDismiss: VoidCallback?

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        invokedDismissCount += 1
        invokedDismissParameters = (animated, completion)
        onDismiss?()
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

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? {
        invokedSelectTab = true
        invokedSelectTabCount += 1
        invokedSelectTabParameters = (tab, shouldPopToRoot)
        return stubbedSelectTabResult
    }
}
