//
//  MockSessionExpiredHandler.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import Foundation

/// Stands in for `RestAPIMiddleware.presentLogin`; pass `handle` as the middleware's `sessionExpiredHandler`.
/// Thread-safe: the middleware calls it on the main queue while tests read it from their own task.
final class MockSessionExpiredHandler {

    private let lock = NSLock()
    private var handleCount = 0

    var invokedHandle: Bool {
        return invokedHandleCount > 0
    }

    var invokedHandleCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return handleCount
    }

    var stubbedShouldCallCompletion = true

    func handle(completion: @escaping VoidCallback) {
        lock.lock()
        handleCount += 1
        let shouldCallCompletion = stubbedShouldCallCompletion
        lock.unlock()

        if shouldCallCompletion {
            completion()
        }
    }
}
