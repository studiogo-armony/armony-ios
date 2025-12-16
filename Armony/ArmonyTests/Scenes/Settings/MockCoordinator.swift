//
//  MockSettingsCoordinator.swift
//  ArmonyTests
//
//  Created by Claude Code
//

import UIKit
@testable import Armony

final class MockUIViewController: UIViewController, ViewController {
    static var storyboardName: UIStoryboard.Name = .none
}

final class MockCoordinator: Coordinator {

    typealias Controller = MockUIViewController


    var invokedNavigatorGetter = false
    var invokedNavigatorGetterCount = 0
    var stubbedNavigator: Navigator!

    var navigator: Navigator? {
        invokedNavigatorGetter = true
        invokedNavigatorGetterCount += 1
        return stubbedNavigator
    }

    var invokedCreateViewController = false
    var invokedCreateViewControllerCount = 0
    var stubbedCreateViewControllerResult: Controller!

    func createViewController() -> Controller {
        invokedCreateViewController = true
        invokedCreateViewControllerCount += 1
        return stubbedCreateViewControllerResult
    }

    var invokedCreateNavigatorWithRootViewController = false
    var invokedCreateNavigatorWithRootViewControllerCount = 0
    var stubbedCreateNavigatorWithRootViewControllerResult: (navigator: Navigator, view: Controller)!

    func createNavigatorWithRootViewController() -> (navigator: Navigator, view: Controller) {
        invokedCreateNavigatorWithRootViewController = true
        invokedCreateNavigatorWithRootViewControllerCount += 1
        return stubbedCreateNavigatorWithRootViewControllerResult
    }

    var invokedDismiss = false
    var invokedDismissCount = 0
    var invokedDismissParameters: (animated: Bool, completion: VoidCallback?)?
    var invokedDismissParametersList = [(animated: Bool, completion: VoidCallback?)]()
    var stubbedDismissCompletionResult: VoidCallback?

    func dismiss(animated: Bool, completion: VoidCallback?) {
        invokedDismiss = true
        invokedDismissCount += 1
        invokedDismissParameters = (animated, completion)
        invokedDismissParametersList.append((animated, completion))
        stubbedDismissCompletionResult = completion
        completion?()
    }

    var invokedPop = false
    var invokedPopCount = 0
    var invokedPopParameters: (animated: Bool, Void)?
    var invokedPopParametersList = [(animated: Bool, Void)]()

    func pop(animated: Bool) {
        invokedPop = true
        invokedPopCount += 1
        invokedPopParameters = (animated, ())
        invokedPopParametersList.append((animated, ()))
    }

    var invokedPopToRootViewController = false
    var invokedPopToRootViewControllerCount = 0
    var invokedPopToRootViewControllerParameters: (animated: Bool, Void)?
    var invokedPopToRootViewControllerParametersList = [(animated: Bool, Void)]()

    func popToRootViewController(animated: Bool) {
        invokedPopToRootViewController = true
        invokedPopToRootViewControllerCount += 1
        invokedPopToRootViewControllerParameters = (animated, ())
        invokedPopToRootViewControllerParametersList.append((animated, ()))
    }

    var invokedOpen = false
    var invokedOpenCount = 0
    var invokedOpenParameters: (deeplink: Deeplink, Void)?
    var invokedOpenParametersList = [(deeplink: Deeplink, Void)]()

    func open(deeplink: Deeplink) {
        invokedOpen = true
        invokedOpenCount += 1
        invokedOpenParameters = (deeplink, ())
        invokedOpenParametersList.append((deeplink, ()))
    }
}
