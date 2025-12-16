//
//  MockFilterView.swift
//  ArmonyTests
//
//  Created by Claude Code
//

import UIKit
@testable import Armony

final class MockFilterView: FilterViewDelegate {
    func makeNavigationBarTransparent() {

    }
    
    func setNavigationBarBackgroundColor(color: UIColor) {

    }
    
    func setNavigationBarBackgroundColor(color: Armony.AppTheme.Color) {

    }
    
    func setNavigationBarTitleAttributes(_ attributes: [NSAttributedString.Key : Any]) {

    }
    
    func setNavigationItemTitle(_ title: String) {

    }
    
    func setTitle(_ title: String) {

    }
    
    func setDismissButton(completion: Armony.VoidCallback?) {

    }
    
    func addNotch() {

    }
    

    // MARK: - updateAdvertType
    var invokedUpdateAdvertType = false
    var invokedUpdateAdvertTypeCount = 0
    var invokedUpdateAdvertTypeParameters: (title: String?, Void)?
    var invokedUpdateAdvertTypeParametersList = [(title: String?, Void)]()

    func updateAdvertType(title: String?) {
        invokedUpdateAdvertType = true
        invokedUpdateAdvertTypeCount += 1
        invokedUpdateAdvertTypeParameters = (title, ())
        invokedUpdateAdvertTypeParametersList.append((title, ()))
    }

    // MARK: - updateLocation
    var invokedUpdateLocation = false
    var invokedUpdateLocationCount = 0
    var invokedUpdateLocationParameters: (title: String?, Void)?
    var invokedUpdateLocationParametersList = [(title: String?, Void)]()

    func updateLocation(title: String?) {
        invokedUpdateLocation = true
        invokedUpdateLocationCount += 1
        invokedUpdateLocationParameters = (title, ())
        invokedUpdateLocationParametersList.append((title, ()))
    }

    // MARK: - Activity Indicators - Advert Type
    var invokedStartAdvertTypeActivityIndicator = false
    var invokedStartAdvertTypeActivityIndicatorCount = 0

    func startAdvertTypeDropdownViewActivityIndicatorView() {
        invokedStartAdvertTypeActivityIndicator = true
        invokedStartAdvertTypeActivityIndicatorCount += 1
    }

    var invokedStopAdvertTypeActivityIndicator = false
    var invokedStopAdvertTypeActivityIndicatorCount = 0

    func stopAdvertTypeDropdownViewActivityIndicatorView() {
        invokedStopAdvertTypeActivityIndicator = true
        invokedStopAdvertTypeActivityIndicatorCount += 1
    }

    // MARK: - Activity Indicators - Location
    var invokedStartLocationActivityIndicator = false
    var invokedStartLocationActivityIndicatorCount = 0

    func startLocationDropdownViewActivityIndicatorView() {
        invokedStartLocationActivityIndicator = true
        invokedStartLocationActivityIndicatorCount += 1
    }

    var invokedStopLocationActivityIndicator = false
    var invokedStopLocationActivityIndicatorCount = 0

    func stopLocationDropdownViewActivityIndicatorView() {
        invokedStopLocationActivityIndicator = true
        invokedStopLocationActivityIndicatorCount += 1
    }
}
