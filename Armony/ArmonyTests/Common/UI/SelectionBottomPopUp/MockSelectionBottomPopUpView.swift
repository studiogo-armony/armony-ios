//
//  MockSelectionBottomPopUpView.swift
//  ArmonyTests
//

import UIKit
@testable import Armony

final class MockSelectionBottomPopUpView: SelectionBottomPopUpViewDelegate {

    var invokedConfigureUI = false
    var invokedConfigureUICount = 0

    func configureUI() {
        invokedConfigureUI = true
        invokedConfigureUICount += 1
    }

    var invokedConfigureTableView = false
    var invokedConfigureTableViewCount = 0
    var invokedConfigureTableViewParameters: (isMultipleSelectionAllowed: Bool, Void)?

    func configureTableView(isMultipleSelectionAllowed: Bool) {
        invokedConfigureTableView = true
        invokedConfigureTableViewCount += 1
        invokedConfigureTableViewParameters = (isMultipleSelectionAllowed, ())
    }

    var invokedSelectRow = false
    var invokedSelectRowCount = 0
    var invokedSelectRowParameters: (indexPath: IndexPath, Void)?
    var invokedSelectRowParametersList = [(indexPath: IndexPath, Void)]()

    func selectRow(at indexPath: IndexPath) {
        invokedSelectRow = true
        invokedSelectRowCount += 1
        invokedSelectRowParameters = (indexPath, ())
        invokedSelectRowParametersList.append((indexPath, ()))
    }

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
