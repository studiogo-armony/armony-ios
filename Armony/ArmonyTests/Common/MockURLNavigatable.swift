//
//  MockURLNavigatable.swift
//  Armony
//
//  Created by KORAY YILDIZ on 29.10.2025.
//

@testable import Armony

class MockURLNavigatable: URLNavigatable {
    var isAuthenticationRequired: Bool = false

    static var instance: URLNavigatable {
        return MockURLNavigatable()
    }

    static func register(navigator: URLNavigation) {

    }
}
