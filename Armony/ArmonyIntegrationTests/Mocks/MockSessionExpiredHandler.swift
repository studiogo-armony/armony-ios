//
//  MockSessionExpiredHandler.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony

/// Stands in for `RestAPIMiddleware.presentLogin`; pass `handle` as the middleware's `sessionExpiredHandler`.
final class MockSessionExpiredHandler {

    var invokedHandle = false
    var invokedHandleCount = 0
    var stubbedShouldCallCompletion = true

    func handle(completion: @escaping VoidCallback) {
        invokedHandle = true
        invokedHandleCount += 1
        if stubbedShouldCallCompletion {
            completion()
        }
    }
}
