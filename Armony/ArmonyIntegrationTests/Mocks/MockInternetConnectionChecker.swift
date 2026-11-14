//
//  MockInternetConnectionChecker.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import Foundation

/// Thread-safe: `RestService` reads `isConnected` from concurrent tasks.
final class MockInternetConnectionChecker: InternetConnectionChecking {

    private let lock = NSLock()
    private var getterCount = 0

    var invokedIsConnectedGetter: Bool {
        return invokedIsConnectedGetterCount > 0
    }

    var invokedIsConnectedGetterCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return getterCount
    }

    var stubbedIsConnected: Bool = true

    var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }
        getterCount += 1
        return stubbedIsConnected
    }
}
