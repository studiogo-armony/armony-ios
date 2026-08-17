//
//  MockMessageCountSocketHandler.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 17.08.26.
//

@testable import Armony

final class MockMessageCountSocketHandler: MessageCountSocketHandling {

    var invokedStart = false
    var invokedStartCount = 0

    func start() {
        invokedStart = true
        invokedStartCount += 1
    }
}
