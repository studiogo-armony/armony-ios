//
//  MockPlaceAdvertView.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 11.08.26.
//

import UIKit
@testable import Armony

final class MockPlaceAdvertView: PlaceAdvertViewDelegate {

    // MARK: - NavigationBarCustomizing (unused in tests)
    func makeNavigationBarTransparent() {}
    func setNavigationBarBackgroundColor(color: UIColor) {}
    func setNavigationBarBackgroundColor(color: AppTheme.Color) {}
    func setNavigationBarTitleAttributes(_ attributes: [NSAttributedString.Key: Any]) {}
    func setNavigationItemTitle(_ title: String) {}
    func setTitle(_ title: String) {}
    func setDismissButton(completion: VoidCallback?) {}
    func addNotch() {}

    // MARK: - configureMusicGenreDropdownView
    var invokedConfigureMusicGenreDropdownView = false
    var invokedConfigureMusicGenreDropdownViewCount = 0
    var invokedConfigureMusicGenreDropdownViewParameters: (presentation: DropdownPresentation, Void)?

    func configureMusicGenreDropdownView(presentation: DropdownPresentation) {
        invokedConfigureMusicGenreDropdownView = true
        invokedConfigureMusicGenreDropdownViewCount += 1
        invokedConfigureMusicGenreDropdownViewParameters = (presentation, ())
    }

    // MARK: - configureSkillDropdownView
    var invokedConfigureSkillDropdownView = false
    var invokedConfigureSkillDropdownViewCount = 0
    var invokedConfigureSkillDropdownViewParameters: (presentation: DropdownPresentation, Void)?

    func configureSkillDropdownView(presentation: DropdownPresentation) {
        invokedConfigureSkillDropdownView = true
        invokedConfigureSkillDropdownViewCount += 1
        invokedConfigureSkillDropdownViewParameters = (presentation, ())
    }

    // MARK: - updateAdvertType
    var invokedUpdateAdvertType = false
    var invokedUpdateAdvertTypeCount = 0
    var invokedUpdateAdvertTypeParameters: (title: String?, Void)?

    func updateAdvertType(title: String?) {
        invokedUpdateAdvertType = true
        invokedUpdateAdvertTypeCount += 1
        invokedUpdateAdvertTypeParameters = (title, ())
    }

    // MARK: - updateSkills
    var invokedUpdateSkills = false
    var invokedUpdateSkillsCount = 0
    var invokedUpdateSkillsParameters: (title: String?, Void)?

    func updateSkills(title: String?) {
        invokedUpdateSkills = true
        invokedUpdateSkillsCount += 1
        invokedUpdateSkillsParameters = (title, ())
    }

    // MARK: - updateLocation
    var invokedUpdateLocation = false
    var invokedUpdateLocationCount = 0
    var invokedUpdateLocationParameters: (title: String?, Void)?

    func updateLocation(title: String?) {
        invokedUpdateLocation = true
        invokedUpdateLocationCount += 1
        invokedUpdateLocationParameters = (title, ())
    }

    // MARK: - updateMusicGenres
    var invokedUpdateMusicGenres = false
    var invokedUpdateMusicGenresCount = 0
    var invokedUpdateMusicGenresParameters: (title: String?, Void)?

    func updateMusicGenres(title: String?) {
        invokedUpdateMusicGenres = true
        invokedUpdateMusicGenresCount += 1
        invokedUpdateMusicGenresParameters = (title, ())
    }

    // MARK: - updateInstructionType
    var invokedUpdateInstructionType = false
    var invokedUpdateInstructionTypeCount = 0
    var invokedUpdateInstructionTypeParameters: (title: String?, Void)?

    func updateInstructionType(title: String?) {
        invokedUpdateInstructionType = true
        invokedUpdateInstructionTypeCount += 1
        invokedUpdateInstructionTypeParameters = (title, ())
    }

    // MARK: - setInformationsStackViewVisibility
    var invokedSetInformationsStackViewVisibility = false
    var invokedSetInformationsStackViewVisibilityCount = 0
    var invokedSetInformationsStackViewVisibilityParameters: (isHidden: Bool, Void)?

    func setInformationsStackViewVisibility(isHidden: Bool) {
        invokedSetInformationsStackViewVisibility = true
        invokedSetInformationsStackViewVisibilityCount += 1
        invokedSetInformationsStackViewVisibilityParameters = (isHidden, ())
    }

    // MARK: - Advert Type Activity Indicator
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

    // MARK: - Skills Activity Indicator
    var invokedStartSkillsActivityIndicator = false
    var invokedStartSkillsActivityIndicatorCount = 0

    func startSkillsDropdownViewActivityIndicatorView() {
        invokedStartSkillsActivityIndicator = true
        invokedStartSkillsActivityIndicatorCount += 1
    }

    var invokedStopSkillsActivityIndicator = false
    var invokedStopSkillsActivityIndicatorCount = 0

    func stopSkillsDropdownViewActivityIndicatorView() {
        invokedStopSkillsActivityIndicator = true
        invokedStopSkillsActivityIndicatorCount += 1
    }

    // MARK: - Music Genres Activity Indicator
    var invokedStartMusicGenresActivityIndicator = false
    var invokedStartMusicGenresActivityIndicatorCount = 0

    func startMusicGenresDropdownViewActivityIndicatorView() {
        invokedStartMusicGenresActivityIndicator = true
        invokedStartMusicGenresActivityIndicatorCount += 1
    }

    var invokedStopMusicGenresActivityIndicator = false
    var invokedStopMusicGenresActivityIndicatorCount = 0

    func stopMusicGenresDropdownViewActivityIndicatorView() {
        invokedStopMusicGenresActivityIndicator = true
        invokedStopMusicGenresActivityIndicatorCount += 1
    }

    // MARK: - setMusicGenresDropdownViewVisibility
    var invokedSetMusicGenresDropdownViewVisibility = false
    var invokedSetMusicGenresDropdownViewVisibilityCount = 0
    var invokedSetMusicGenresDropdownViewVisibilityParameters: (isHidden: Bool, Void)?

    func setMusicGenresDropdownViewVisibility(isHidden: Bool) {
        invokedSetMusicGenresDropdownViewVisibility = true
        invokedSetMusicGenresDropdownViewVisibilityCount += 1
        invokedSetMusicGenresDropdownViewVisibilityParameters = (isHidden, ())
    }

    // MARK: - Location Activity Indicator
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

    // MARK: - Instruction Type Activity Indicator
    var invokedStartInstructionTypeActivityIndicator = false
    var invokedStartInstructionTypeActivityIndicatorCount = 0

    func startInstructionTypeDropdownViewActivityIndicatorView() {
        invokedStartInstructionTypeActivityIndicator = true
        invokedStartInstructionTypeActivityIndicatorCount += 1
    }

    var invokedStopInstructionTypeActivityIndicator = false
    var invokedStopInstructionTypeActivityIndicatorCount = 0

    func stopInstructionTypeDropdownViewActivityIndicatorView() {
        invokedStopInstructionTypeActivityIndicator = true
        invokedStopInstructionTypeActivityIndicatorCount += 1
    }

    // MARK: - setInstructionTypeDropdownViewVisibility
    var invokedSetInstructionTypeDropdownViewVisibility = false
    var invokedSetInstructionTypeDropdownViewVisibilityCount = 0
    var invokedSetInstructionTypeDropdownViewVisibilityParameters: (isHidden: Bool, Void)?

    func setInstructionTypeDropdownViewVisibility(isHidden: Bool) {
        invokedSetInstructionTypeDropdownViewVisibility = true
        invokedSetInstructionTypeDropdownViewVisibilityCount += 1
        invokedSetInstructionTypeDropdownViewVisibilityParameters = (isHidden, ())
    }

    // MARK: - Submit Button Activity Indicator
    var invokedStartSubmitButtonActivityIndicator = false
    var invokedStartSubmitButtonActivityIndicatorCount = 0

    func startSubmitButtonActivityIndicatorView() {
        invokedStartSubmitButtonActivityIndicator = true
        invokedStartSubmitButtonActivityIndicatorCount += 1
    }

    var invokedStopSubmitButtonActivityIndicator = false
    var invokedStopSubmitButtonActivityIndicatorCount = 0
    var onStopSubmitButtonActivityIndicator: VoidCallback?

    func stopSubmitButtonActivityIndicatorView() {
        invokedStopSubmitButtonActivityIndicator = true
        invokedStopSubmitButtonActivityIndicatorCount += 1
        onStopSubmitButtonActivityIndicator?()
    }

    // MARK: - updateValidators
    var invokedUpdateValidators = false
    var invokedUpdateValidatorsCount = 0
    var invokedUpdateValidatorsParameters: (validator: PlaceAdvertViewController.Validators, Void)?

    func updateValidators(validator: PlaceAdvertViewController.Validators) {
        invokedUpdateValidators = true
        invokedUpdateValidatorsCount += 1
        invokedUpdateValidatorsParameters = (validator, ())
    }

    // MARK: - showPaywall
    var invokedShowPaywall = false
    var invokedShowPaywallCount = 0
    var onShowPaywall: VoidCallback?

    func showPaywall() {
        invokedShowPaywall = true
        invokedShowPaywallCount += 1
        onShowPaywall?()
    }

    // MARK: - resetTextView
    var invokedResetTextView = false
    var invokedResetTextViewCount = 0
    var onResetTextView: VoidCallback?

    func resetTextView() {
        invokedResetTextView = true
        invokedResetTextViewCount += 1
        onResetTextView?()
    }

}
