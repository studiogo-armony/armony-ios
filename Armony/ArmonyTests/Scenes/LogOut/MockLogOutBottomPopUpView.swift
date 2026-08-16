//
//  MockLogOutBottomPopUpView.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

@testable import Armony

final class MockLogOutBottomPopUpView: LogOutBottomPopUpViewDelegate {

    // MARK: - startLogoutButtonActivityIndicatorView
    var invokedStartLogoutButtonActivityIndicatorView = false
    var invokedStartLogoutButtonActivityIndicatorViewCount = 0

    func startLogoutButtonActivityIndicatorView() {
        invokedStartLogoutButtonActivityIndicatorView = true
        invokedStartLogoutButtonActivityIndicatorViewCount += 1
    }

    // MARK: - stopLogoutButtonActivityIndicatorView
    var invokedStopLogoutButtonActivityIndicatorView = false
    var invokedStopLogoutButtonActivityIndicatorViewCount = 0
    var onStopLogoutButtonActivityIndicatorView: VoidCallback?

    func stopLogoutButtonActivityIndicatorView() {
        invokedStopLogoutButtonActivityIndicatorView = true
        invokedStopLogoutButtonActivityIndicatorViewCount += 1
        onStopLogoutButtonActivityIndicatorView?()
    }
}
