//
//  MockVisitedAccountView.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.08.26.
//

import UIKit
@testable import Armony

final class MockVisitedAccountView: VisitedAccountViewDelegate {

    // MARK: - NavigationBarCustomizing
    var invokedMakeNavigationBarTransparent = false
    var invokedMakeNavigationBarTransparentCount = 0

    func makeNavigationBarTransparent() {
        invokedMakeNavigationBarTransparent = true
        invokedMakeNavigationBarTransparentCount += 1
    }

    func setNavigationBarBackgroundColor(color: UIColor) {}
    func setNavigationBarBackgroundColor(color: AppTheme.Color) {}
    func setNavigationBarTitleAttributes(_ attributes: [NSAttributedString.Key: Any]) {}
    func setNavigationItemTitle(_ title: String) {}
    func setTitle(_ title: String) {}
    func setDismissButton(completion: VoidCallback?) {}
    func addNotch() {}

    // MARK: - NavigationBarActivityIndicatorShowing
    var invokedStartRightBarButtonItemActivityIndicatorView = false

    func startRightBarButtonItemActivityIndicatorView() {
        invokedStartRightBarButtonItemActivityIndicatorView = true
    }

    var invokedStopRightBarButtonItemActivityIndicatorView = false

    func stopRightBarButtonItemActivityIndicatorView() {
        invokedStopRightBarButtonItemActivityIndicatorView = true
    }

    // MARK: - configurePager
    var invokedConfigurePager = false
    var invokedConfigurePagerCount = 0
    var invokedConfigurePagerParameters: (skills: SkillsPresentation, musicGenres: MusicGenresPresentation, userID: String)?
    var onConfigurePager: VoidCallback?

    func configurePager(skills: SkillsPresentation, musicGenres: MusicGenresPresentation, userID: String) {
        invokedConfigurePager = true
        invokedConfigurePagerCount += 1
        invokedConfigurePagerParameters = (skills, musicGenres, userID)
        onConfigurePager?()
    }

    // MARK: - configureUserSummaryView
    var invokedConfigureUserSummaryView = false
    var invokedConfigureUserSummaryViewCount = 0
    var invokedConfigureUserSummaryViewParameters: (presentation: UserSummaryPresentation, Void)?
    var onConfigureUserSummaryView: VoidCallback?

    func configureUserSummaryView(with presentation: UserSummaryPresentation) {
        invokedConfigureUserSummaryView = true
        invokedConfigureUserSummaryViewCount += 1
        invokedConfigureUserSummaryViewParameters = (presentation, ())
        onConfigureUserSummaryView?()
    }

    // MARK: - setBioLabelText
    var invokedSetBioLabelText = false
    var invokedSetBioLabelTextCount = 0
    var invokedSetBioLabelTextParameters: (bio: String?, Void)?
    var onSetBioLabelText: VoidCallback?

    func setBioLabelText(_ bio: String?) {
        invokedSetBioLabelText = true
        invokedSetBioLabelTextCount += 1
        invokedSetBioLabelTextParameters = (bio, ())
        onSetBioLabelText?()
    }
}
