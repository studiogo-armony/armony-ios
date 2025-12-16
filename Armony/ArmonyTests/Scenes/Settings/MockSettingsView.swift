//
//  MockSettingsView.swift
//  ArmonyTests
//
//  Created by Claude Code
//

import UIKit
@testable import Armony

final class MockSettingsView: SettingsViewDelegate {

    var invokedReloadData = false
    var invokedReloadDataCount = 0

    func reloadData() {
        invokedReloadData = true
        invokedReloadDataCount += 1
    }

    var invokedStartActivityIndicatorView = false
    var invokedStartActivityIndicatorViewCount = 0

    func startActivityIndicatorView() {
        invokedStartActivityIndicatorView = true
        invokedStartActivityIndicatorViewCount += 1
    }

    var invokedStopActivityIndicatorView = false
    var invokedStopActivityIndicatorViewCount = 0

    func stopActivityIndicatorView() {
        invokedStopActivityIndicatorView = true
        invokedStopActivityIndicatorViewCount += 1
    }
}
