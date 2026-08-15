//
//  MockAdvertCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 13.08.26.
//

import UIKit
@testable import Armony

final class MockAdvertCoordinator: AdvertCoordinating {

    // MARK: - visitedAccount
    var invokedVisitedAccount = false
    var invokedVisitedAccountCount = 0
    var invokedVisitedAccountParameters: (userID: String, Void)?

    func visitedAccount(with userID: String) {
        invokedVisitedAccount = true
        invokedVisitedAccountCount += 1
        invokedVisitedAccountParameters = (userID, ())
    }

    // MARK: - liveChat
    var invokedLiveChat = false
    var invokedLiveChatCount = 0
    var invokedLiveChatParameters: (chatID: Int, Void)?
    var onLiveChat: VoidCallback?

    func liveChat(with chatID: Int) {
        invokedLiveChat = true
        invokedLiveChatCount += 1
        invokedLiveChatParameters = (chatID, ())
        onLiveChat?()
    }

    // MARK: - registration
    var invokedRegistration = false
    var invokedRegistrationCount = 0
    var stubbedRegistrationDidRegister = false
    var stubbedRegistrationDidLogin = false

    func registration(didRegister: VoidCallback?, didLogin: VoidCallback?) {
        invokedRegistration = true
        invokedRegistrationCount += 1
        if stubbedRegistrationDidRegister { didRegister?() }
        if stubbedRegistrationDidLogin { didLogin?() }
    }

    // MARK: - selectionBottomPopUp
    var invokedSelectionBottomPopUp = false
    var invokedSelectionBottomPopUpCount = 0
    var onSelectionBottomPopUp: VoidCallback?

    func selectionBottomPopUp(presentation: any SelectionPresentation) {
        invokedSelectionBottomPopUp = true
        invokedSelectionBottomPopUpCount += 1
        onSelectionBottomPopUp?()
    }

    // MARK: - openAtSafariViewController
    var invokedOpenAtSafariViewController = false
    var invokedOpenAtSafariViewControllerParameters: (url: URL, Void)?

    func openAtSafariViewController(url: URL) {
        invokedOpenAtSafariViewController = true
        invokedOpenAtSafariViewControllerParameters = (url, ())
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
