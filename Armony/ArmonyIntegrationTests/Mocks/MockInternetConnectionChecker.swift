//
//  MockInternetConnectionChecker.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony

final class MockInternetConnectionChecker: InternetConnectionChecking {

    var invokedIsConnectedGetter = false
    var invokedIsConnectedGetterCount = 0
    var stubbedIsConnected: Bool = true

    var isConnected: Bool {
        invokedIsConnectedGetter = true
        invokedIsConnectedGetterCount += 1
        return stubbedIsConnected
    }
}
