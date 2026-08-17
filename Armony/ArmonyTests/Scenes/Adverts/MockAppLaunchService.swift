//
//  MockAppLaunchService.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 17.08.26.
//

@testable import Armony

final class MockAppLaunchService: AppLaunchHandling {

    var isLaunchedClosedStateWithNotification: Bool = false
    var deeplink: Deeplink? = nil

    var invokedReset = false
    var invokedResetCount = 0

    func reset() {
        invokedReset = true
        invokedResetCount += 1
    }
}
