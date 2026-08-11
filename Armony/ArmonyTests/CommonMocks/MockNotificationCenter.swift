//
//  MockNotificationCenter.swift
//  ArmonyTests
//
//  Created by Koray Yıldız on 12.08.26.
//

@testable import Armony
import Foundation

final class MockNotificationCenter: NotificationPosting {

    var invokedPost = false
    var invokedPostCount = 0
    var invokedPostParameters: (notification: Notification.Name, object: Any?, userInfo: [HashableKey: Any]?)?

    func post(notification: Notification.Name, object: Any?, userInfo: [HashableKey: Any]?) {
        invokedPost = true
        invokedPostCount += 1
        invokedPostParameters = (notification, object, userInfo)
    }
}
