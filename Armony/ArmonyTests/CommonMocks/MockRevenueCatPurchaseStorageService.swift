//
//  MockRevenueCatPurchaseStorageService.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 11.08.26.
//

@testable import Armony
import Foundation

final class MockRevenueCatPurchaseStorageService: RevenueCatPurchaseStoring {

    var stubbedIdentifiers: [String] = []

    var identifiers: [String] {
        return stubbedIdentifiers
    }

    var invokedStore = false
    var invokedStoreCount = 0
    var invokedStoreParameters: (transactionID: String, Void)?

    func store(transactionID: String) {
        invokedStore = true
        invokedStoreCount += 1
        invokedStoreParameters = (transactionID, ())
        stubbedIdentifiers.append(transactionID)
    }

    var invokedRemove = false
    var invokedRemoveCount = 0
    var invokedRemoveParameters: (transactionID: String, Void)?
    var onRemove: VoidCallback?

    func remove(transactionID: String) {
        invokedRemove = true
        invokedRemoveCount += 1
        invokedRemoveParameters = (transactionID, ())
        stubbedIdentifiers.removeAll { $0 == transactionID }
        onRemove?()
    }
}
