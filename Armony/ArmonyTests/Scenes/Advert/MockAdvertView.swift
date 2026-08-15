//
//  MockAdvertView.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 13.08.26.
//

import UIKit
@testable import Armony

final class MockAdvertView: AdvertViewDelegate {

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

    // MARK: - setTitle
    var invokedSetTitle = false
    var invokedSetTitleCount = 0
    var invokedSetTitleParameters: (title: String, Void)?

    func setTitle(_ title: String) {
        invokedSetTitle = true
        invokedSetTitleCount += 1
        invokedSetTitleParameters = (title, ())
    }

    // MARK: - makeNavigationBarTransparent
    func makeNavigationBarTransparent() {}

    // MARK: - setNavigationBarBackgroundColor
    var invokedSetNavigationBarBackgroundColor = false
    var invokedSetNavigationBarBackgroundColorCount = 0

    func setNavigationBarBackgroundColor(color: UIColor) {
        invokedSetNavigationBarBackgroundColor = true
        invokedSetNavigationBarBackgroundColorCount += 1
    }

    func setNavigationBarBackgroundColor(color: AppTheme.Color) {
        invokedSetNavigationBarBackgroundColor = true
        invokedSetNavigationBarBackgroundColorCount += 1
    }

    // MARK: - setNavigationItemTitle
    func setNavigationItemTitle(_ title: String) {}

    // MARK: - addNotch
    func addNotch() {}

    // MARK: - setNavigationBarTitleAttributes
    var invokedSetNavigationBarTitleAttributes = false

    func setNavigationBarTitleAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        invokedSetNavigationBarTitleAttributes = true
    }

    // MARK: - setDismissButton
    var invokedSetDismissButton = false

    func setDismissButton(completion: VoidCallback?) {
        invokedSetDismissButton = true
    }

    // MARK: - configureUserSummaryView
    var invokedConfigureUserSummaryView = false
    var invokedConfigureUserSummaryViewCount = 0
    var invokedConfigureUserSummaryViewParameters: (presentation: UserSummaryPresentation, Void)?

    func configureUserSummaryView(with presentation: UserSummaryPresentation) {
        invokedConfigureUserSummaryView = true
        invokedConfigureUserSummaryViewCount += 1
        invokedConfigureUserSummaryViewParameters = (presentation, ())
    }

    // MARK: - configureSkillsView
    var invokedConfigureSkillsView = false
    var invokedConfigureSkillsViewCount = 0

    func configureSkillsView(with presentation: SkillsPresentation) {
        invokedConfigureSkillsView = true
        invokedConfigureSkillsViewCount += 1
    }

    // MARK: - configureGenresView
    var invokedConfigureGenresView = false
    var invokedConfigureGenresViewCount = 0
    var onConfigureGenresView: VoidCallback?

    func configureGenresView(with presentation: MusicGenresPresentation) {
        invokedConfigureGenresView = true
        invokedConfigureGenresViewCount += 1
        onConfigureGenresView?()
    }

    // MARK: - configureInstructionTypesView
    var invokedConfigureInstructionTypesView = false
    var onConfigureInstructionTypesView: VoidCallback?

    func configureInstructionTypesView(with presentation: MusicGenresPresentation) {
        invokedConfigureInstructionTypesView = true
        onConfigureInstructionTypesView?()
    }

    // MARK: - setDescriptionLabel
    var invokedSetDescriptionLabel = false
    var invokedSetDescriptionLabelParameters: (description: String, Void)?
    var onSetDescriptionLabel: VoidCallback?

    func setDescriptionLabel(description: String) {
        invokedSetDescriptionLabel = true
        invokedSetDescriptionLabelParameters = (description, ())
        onSetDescriptionLabel?()
    }

    // MARK: - setRemoveAdvertsButtonVisibility
    var invokedSetRemoveAdvertsButtonVisibility = false
    var invokedSetRemoveAdvertsButtonVisibilityCount = 0
    var invokedSetRemoveAdvertsButtonVisibilityParameters: (isHidden: Bool, Void)?

    func setRemoveAdvertsButtonVisibility(isHidden: Bool) {
        invokedSetRemoveAdvertsButtonVisibility = true
        invokedSetRemoveAdvertsButtonVisibilityCount += 1
        invokedSetRemoveAdvertsButtonVisibilityParameters = (isHidden, ())
    }

    // MARK: - setApplyButtonButtonVisibility
    var invokedSetApplyButtonButtonVisibility = false
    var invokedSetApplyButtonButtonVisibilityCount = 0
    var invokedSetApplyButtonButtonVisibilityParameters: (isHidden: Bool, Void)?
    var onSetApplyButtonButtonVisibility: VoidCallback?

    func setApplyButtonButtonVisibility(isHidden: Bool) {
        invokedSetApplyButtonButtonVisibility = true
        invokedSetApplyButtonButtonVisibilityCount += 1
        invokedSetApplyButtonButtonVisibilityParameters = (isHidden, ())
        onSetApplyButtonButtonVisibility?()
    }

    // MARK: - setContentStackViewVisibility
    var invokedSetContentStackViewVisibility = false
    var invokedSetContentStackViewVisibilityCount = 0
    var invokedSetContentStackViewVisibilityParameters: (isHidden: Bool, animated: Bool)?

    func setContentStackViewVisibility(isHidden: Bool, animated: Bool) {
        invokedSetContentStackViewVisibility = true
        invokedSetContentStackViewVisibilityCount += 1
        invokedSetContentStackViewVisibilityParameters = (isHidden, animated)
    }

    // MARK: - startSendMessageButtonActivityIndicatorView
    var invokedStartSendMessageButtonActivityIndicatorView = false
    var invokedStartSendMessageButtonActivityIndicatorViewCount = 0

    func startSendMessageButtonActivityIndicatorView() {
        invokedStartSendMessageButtonActivityIndicatorView = true
        invokedStartSendMessageButtonActivityIndicatorViewCount += 1
    }

    // MARK: - stopSendMessageButtonActivityIndicatorView
    var invokedStopSendMessageButtonActivityIndicatorView = false
    var invokedStopSendMessageButtonActivityIndicatorViewCount = 0
    var onStopSendMessageButtonActivityIndicatorView: VoidCallback?

    func stopSendMessageButtonActivityIndicatorView() {
        invokedStopSendMessageButtonActivityIndicatorView = true
        invokedStopSendMessageButtonActivityIndicatorViewCount += 1
        onStopSendMessageButtonActivityIndicatorView?()
    }

    // MARK: - startDeleteButtonActivityIndicatorView
    var invokedStartDeleteButtonActivityIndicatorView = false
    var invokedStartDeleteButtonActivityIndicatorViewCount = 0
    var onStartDeleteButtonActivityIndicatorView: VoidCallback?

    func startDeleteButtonActivityIndicatorView() {
        invokedStartDeleteButtonActivityIndicatorView = true
        invokedStartDeleteButtonActivityIndicatorViewCount += 1
        onStartDeleteButtonActivityIndicatorView?()
    }

    // MARK: - stopDeleteButtonActivityIndicatorView
    var invokedStopDeleteButtonActivityIndicatorView = false
    var invokedStopDeleteButtonActivityIndicatorViewCount = 0
    var onStopDeleteButtonActivityIndicatorView: VoidCallback?

    func stopDeleteButtonActivityIndicatorView() {
        invokedStopDeleteButtonActivityIndicatorView = true
        invokedStopDeleteButtonActivityIndicatorViewCount += 1
        onStopDeleteButtonActivityIndicatorView?()
    }

    // MARK: - startUserSummaryViewDotsButtonActivityIndicatorView
    var invokedStartUserSummaryViewDotsButtonActivityIndicatorView = false

    func startUserSummaryViewDotsButtonActivityIndicatorView() {
        invokedStartUserSummaryViewDotsButtonActivityIndicatorView = true
    }

    // MARK: - stopUserSummaryViewDotsButtonActivityIndicatorView
    var invokedStopUserSummaryViewDotsButtonActivityIndicatorView = false
    var onStopUserSummaryViewDotsButtonActivityIndicatorView: VoidCallback?

    func stopUserSummaryViewDotsButtonActivityIndicatorView() {
        invokedStopUserSummaryViewDotsButtonActivityIndicatorView = true
        onStopUserSummaryViewDotsButtonActivityIndicatorView?()
    }

    // MARK: - startActivateAdvertButtonActivityIndicatorView
    var invokedStartActivateAdvertButtonActivityIndicatorView = false
    var invokedStartActivateAdvertButtonActivityIndicatorViewCount = 0

    func startActivateAdvertButtonActivityIndicatorView() {
        invokedStartActivateAdvertButtonActivityIndicatorView = true
        invokedStartActivateAdvertButtonActivityIndicatorViewCount += 1
    }

    // MARK: - stopActivateAdvertButtonActivityIndicatorView
    var invokedStopActivateAdvertButtonActivityIndicatorView = false
    var invokedStopActivateAdvertButtonActivityIndicatorViewCount = 0
    var onStopActivateAdvertButtonActivityIndicatorView: VoidCallback?

    func stopActivateAdvertButtonActivityIndicatorView() {
        invokedStopActivateAdvertButtonActivityIndicatorView = true
        invokedStopActivateAdvertButtonActivityIndicatorViewCount += 1
        onStopActivateAdvertButtonActivityIndicatorView?()
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
}
