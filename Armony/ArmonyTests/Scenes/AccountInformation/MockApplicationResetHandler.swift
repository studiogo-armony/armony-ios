//
//  MockApplicationResetHandler.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

@testable import Armony

final class MockApplicationResetHandler: ApplicationResetHandling {

    var invokedReset = false
    var invokedResetCount = 0
    var onReset: VoidCallback?

    func reset() {
        invokedReset = true
        invokedResetCount += 1
        onReset?()
    }
}
