//
//  MockAdvertsCoordinator.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 17.08.26.
//

import UIKit
@testable import Armony

final class MockAdvertsCoordinator: AdvertsCoordinating {

    // MARK: - advert
    var invokedAdvert = false
    var invokedAdvertCount = 0
    var invokedAdvertParameters: (id: Int, colorCode: String)?

    func advert(with id: Int, colorCode: String, dismiss completion: Callback<Bool>?) {
        invokedAdvert = true
        invokedAdvertCount += 1
        invokedAdvertParameters = (id, colorCode)
    }

    // MARK: - onboarding
    var invokedOnboarding = false
    var invokedOnboardingCount = 0

    func onboarding() {
        invokedOnboarding = true
        invokedOnboardingCount += 1
    }

    // MARK: - filter
    var invokedFilter = false
    var invokedFilterCount = 0

    func filter(delegate: FilterViewModelDelegate, selectedFilters: FilterViewModel.Filters) {
        invokedFilter = true
        invokedFilterCount += 1
    }

    // MARK: - CoordinatorInterface
    func pop(animated: Bool) {}
    func popToRootViewController(animated: Bool) {}

    var invokedOpen = false
    var invokedOpenParameters: (deeplink: Deeplink, Void)?

    func open(deeplink: Deeplink) {
        invokedOpen = true
        invokedOpenParameters = (deeplink, ())
    }

    func dismiss(animated: Bool, completion: VoidCallback?) {
        completion?()
    }

    @discardableResult
    func selectTab(tab: Common.Tab, shouldPopToRoot: Bool) -> UIViewController? { return nil }
}
