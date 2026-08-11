//
//  MockRegistrationView.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 12.08.26.
//

import UIKit
@testable import Armony

final class MockRegistrationView: RegistrationViewDelegate {

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

    // MARK: - startOkButtonActivityIndicatorView
    var invokedStartOkButtonActivityIndicator = false
    var invokedStartOkButtonActivityIndicatorCount = 0

    func startOkButtonActivityIndicatorView() {
        invokedStartOkButtonActivityIndicator = true
        invokedStartOkButtonActivityIndicatorCount += 1
    }

    // MARK: - stopOkButtonActivityIndicatorView
    var invokedStopOkButtonActivityIndicator = false
    var invokedStopOkButtonActivityIndicatorCount = 0
    var onStopOkButtonActivityIndicator: VoidCallback?

    func stopOkButtonActivityIndicatorView() {
        invokedStopOkButtonActivityIndicator = true
        invokedStopOkButtonActivityIndicatorCount += 1
        onStopOkButtonActivityIndicator?()
    }
}
