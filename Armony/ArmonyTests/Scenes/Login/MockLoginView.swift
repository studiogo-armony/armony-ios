//
//  MockLoginView.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 13.08.26.
//

import UIKit
@testable import Armony

final class MockLoginView: LoginViewDelegate {

    // MARK: - NavigationBarCustomizing (unused in tests)
    func makeNavigationBarTransparent() {}
    func setNavigationBarBackgroundColor(color: UIColor) {}
    func setNavigationBarBackgroundColor(color: AppTheme.Color) {}
    func setNavigationBarTitleAttributes(_ attributes: [NSAttributedString.Key: Any]) {}
    func setNavigationItemTitle(_ title: String) {}
    func setTitle(_ title: String) {}
    func setDismissButton(completion: VoidCallback?) {}
    func addNotch() {}

    // MARK: - configureUI
    var invokedConfigureUI = false
    var invokedConfigureUICount = 0

    func configureUI() {
        invokedConfigureUI = true
        invokedConfigureUICount += 1
    }

    // MARK: - startLoginButtonActivityIndicatorView
    var invokedStartLoginButtonActivityIndicator = false
    var invokedStartLoginButtonActivityIndicatorCount = 0

    func startLoginButtonActivityIndicatorView() {
        invokedStartLoginButtonActivityIndicator = true
        invokedStartLoginButtonActivityIndicatorCount += 1
    }

    // MARK: - stopLoginButtonActivityIndicatorView
    var invokedStopLoginButtonActivityIndicator = false
    var invokedStopLoginButtonActivityIndicatorCount = 0
    var onStopLoginButtonActivityIndicator: VoidCallback?

    func stopLoginButtonActivityIndicatorView() {
        invokedStopLoginButtonActivityIndicator = true
        invokedStopLoginButtonActivityIndicatorCount += 1
        onStopLoginButtonActivityIndicator?()
    }
}
