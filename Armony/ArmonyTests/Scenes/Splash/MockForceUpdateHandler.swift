//
//  MockForceUpdateHandler.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

@testable import Armony

final class MockForceUpdateHandler: ForceUpdateHandling {

    var invokedShouldUpdate = false
    var invokedShouldUpdateCount = 0
    var stubbedShouldUpdateResult: Bool = false
    var stubbedShouldUpdateError: Error?
    var onShouldUpdate: VoidCallback?

    func shouldUpdate() async throws -> Bool {
        invokedShouldUpdate = true
        invokedShouldUpdateCount += 1
        onShouldUpdate?()
        if let error = stubbedShouldUpdateError {
            throw error
        }
        return stubbedShouldUpdateResult
    }
}
