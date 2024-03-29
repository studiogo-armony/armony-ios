//
//  CreateAdvertNotificationService.swift
//  Armony
//
//  Created by Koray Yıldız on 23.12.2023.
//

import Foundation

final class CreateAdvertNotificationService {
    static let shared = CreateAdvertNotificationService()

    private var newAdvertCreateNotificationToken: NotificationToken? = nil
    private unowned let notifier: NotificationCenter = .default

    var isNewAdvertCreated = false

    public func addNewAdvertCreateHandler(_ handler: @escaping Callback<Notification>) {
        newAdvertCreateNotificationToken = notifier.observe(name: .newAdvertDidCreate, using: { [unowned self] notification in
            handler(notification)
            self.notifier.removeObserver(self.newAdvertCreateNotificationToken as Any)
        })
    }
}

