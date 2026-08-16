//
//  MockRemoteConfigService.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

@testable import Armony

final class MockRemoteConfigService: RemoteConfigProviding {

    // MARK: - start
    var invokedStart = false
    var invokedStartCount = 0
    var stubbedStartError: Error?
    var onStart: VoidCallback?

    func start() async throws {
        invokedStart = true
        invokedStartCount += 1
        onStart?()
        if let error = stubbedStartError {
            throw error
        }
    }

    // MARK: - subscript Bool
    var stubbedBoolValues: [String: Bool] = [:]

    subscript(key: HashableKey) -> Bool {
        return stubbedBoolValues[key.value] ?? false
    }
}
