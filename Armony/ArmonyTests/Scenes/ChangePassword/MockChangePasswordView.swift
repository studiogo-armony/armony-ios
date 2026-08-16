//
//  MockChangePasswordView.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 16.08.26.
//

@testable import Armony

final class MockChangePasswordView: ChangePasswordViewDelegate {

    // MARK: - configureUI
    var invokedConfigureUI = false
    var invokedConfigureUICount = 0

    func configureUI() {
        invokedConfigureUI = true
        invokedConfigureUICount += 1
    }

    // MARK: - startSaveButtonActivityIndicatorView
    var invokedStartSaveButtonActivityIndicatorView = false
    var invokedStartSaveButtonActivityIndicatorViewCount = 0

    func startSaveButtonActivityIndicatorView() {
        invokedStartSaveButtonActivityIndicatorView = true
        invokedStartSaveButtonActivityIndicatorViewCount += 1
    }

    // MARK: - stopSaveButtonActivityIndicatorView
    var invokedStopSaveButtonActivityIndicatorView = false
    var invokedStopSaveButtonActivityIndicatorViewCount = 0
    var onStopSaveButtonActivityIndicatorView: VoidCallback?

    func stopSaveButtonActivityIndicatorView() {
        invokedStopSaveButtonActivityIndicatorView = true
        invokedStopSaveButtonActivityIndicatorViewCount += 1
        onStopSaveButtonActivityIndicatorView?()
    }
}
