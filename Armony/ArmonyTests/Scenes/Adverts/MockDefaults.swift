//
//  MockDefaults.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 17.08.26.
//

@testable import Armony

final class MockDefaults: DefaultsProviding {

    var stubbedBoolValues: [DefaultsKeys: Bool] = [:]

    subscript(key: DefaultsKeys) -> Bool {
        return stubbedBoolValues[key] ?? false
    }
}
