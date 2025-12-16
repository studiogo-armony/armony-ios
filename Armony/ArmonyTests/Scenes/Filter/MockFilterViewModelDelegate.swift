//
//  MockFilterViewModelDelegate.swift
//  ArmonyTests
//
//  Created by Claude Code
//

import Foundation
@testable import Armony

final class MockFilterViewModelDelegate: FilterViewModelDelegate {

    var invokedApplyButtonTapped = false
    var invokedApplyButtonTappedCount = 0
    var invokedApplyButtonTappedParameters: (filters: FilterViewModel.Filters, Void)?
    var invokedApplyButtonTappedParametersList = [(filters: FilterViewModel.Filters, Void)]()

    func applyButtonTapped(filters: FilterViewModel.Filters) {
        invokedApplyButtonTapped = true
        invokedApplyButtonTappedCount += 1
        invokedApplyButtonTappedParameters = (filters, ())
        invokedApplyButtonTappedParametersList.append((filters, ()))
    }
}
