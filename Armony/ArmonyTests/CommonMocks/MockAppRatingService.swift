//
//  MockAppRatingService.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 11.08.26.
//

@testable import Armony
import Foundation

final class MockAppRatingService: AppRating {

    var invokedRequestReviewIfNeeded = false
    var invokedRequestReviewIfNeededCount = 0

    func requestReviewIfNeeded() {
        invokedRequestReviewIfNeeded = true
        invokedRequestReviewIfNeededCount += 1
    }
}
