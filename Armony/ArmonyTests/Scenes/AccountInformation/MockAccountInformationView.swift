//
//  MockAccountInformationView.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.08.26.
//

import UIKit
@testable import Armony

final class MockAccountInformationView: AccountInformationViewDelegate {

    var name: String? = nil

    // MARK: - configureUI
    var invokedConfigureUI = false
    var invokedConfigureUICount = 0

    func configureUI() {
        invokedConfigureUI = true
        invokedConfigureUICount += 1
    }

    // MARK: - configureNameTextField
    var invokedConfigureNameTextField = false
    var invokedConfigureNameTextFieldCount = 0
    var invokedConfigureNameTextFieldParameters: (name: String?, Void)?
    var onConfigureNameTextField: VoidCallback?

    func configureNameTextField(name: String?) {
        invokedConfigureNameTextField = true
        invokedConfigureNameTextFieldCount += 1
        invokedConfigureNameTextFieldParameters = (name, ())
        onConfigureNameTextField?()
    }

    // MARK: - configureEmailTextField
    var invokedConfigureEmailTextField = false
    var invokedConfigureEmailTextFieldCount = 0
    var invokedConfigureEmailTextFieldParameters: (email: String?, Void)?
    var onConfigureEmailTextField: VoidCallback?

    func configureEmailTextField(email: String?) {
        invokedConfigureEmailTextField = true
        invokedConfigureEmailTextFieldCount += 1
        invokedConfigureEmailTextFieldParameters = (email, ())
        onConfigureEmailTextField?()
    }

    // MARK: - setContainerViewVisibility
    var invokedSetContainerViewVisibility = false
    var invokedSetContainerViewVisibilityCount = 0
    var invokedSetContainerViewVisibilityParameters: (isHidden: Bool, Void)?

    func setContainerViewVisibility(isHidden: Bool) {
        invokedSetContainerViewVisibility = true
        invokedSetContainerViewVisibilityCount += 1
        invokedSetContainerViewVisibilityParameters = (isHidden, ())
    }

    // MARK: - startActivityIndicatorView
    var invokedStartActivityIndicatorView = false
    var invokedStartActivityIndicatorViewCount = 0

    func startActivityIndicatorView() {
        invokedStartActivityIndicatorView = true
        invokedStartActivityIndicatorViewCount += 1
    }

    // MARK: - stopActivityIndicatorView
    var invokedStopActivityIndicatorView = false
    var invokedStopActivityIndicatorViewCount = 0
    var onStopActivityIndicatorView: VoidCallback?

    func stopActivityIndicatorView() {
        invokedStopActivityIndicatorView = true
        invokedStopActivityIndicatorViewCount += 1
        onStopActivityIndicatorView?()
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

    // MARK: - startDeleteAccountButtonActivityIndicatorView
    var invokedStartDeleteAccountButtonActivityIndicatorView = false
    var invokedStartDeleteAccountButtonActivityIndicatorViewCount = 0

    func startDeleteAccountButtonActivityIndicatorView() {
        invokedStartDeleteAccountButtonActivityIndicatorView = true
        invokedStartDeleteAccountButtonActivityIndicatorViewCount += 1
    }

    // MARK: - stopDeleteAccountButtonActivityIndicatorView
    var invokedStopDeleteAccountButtonActivityIndicatorView = false
    var invokedStopDeleteAccountButtonActivityIndicatorViewCount = 0
    var onStopDeleteAccountButtonActivityIndicatorView: VoidCallback?

    func stopDeleteAccountButtonActivityIndicatorView() {
        invokedStopDeleteAccountButtonActivityIndicatorView = true
        invokedStopDeleteAccountButtonActivityIndicatorViewCount += 1
        onStopDeleteAccountButtonActivityIndicatorView?()
    }
}
