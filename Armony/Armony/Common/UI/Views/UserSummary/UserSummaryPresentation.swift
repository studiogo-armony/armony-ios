//
//  UserSummary.swift
//  Armony
//
//  Created by Koray Yıldız on 8.09.2021.
//

import UIKit

public struct UserSummaryPresentation {

    let avatarPresentation: AvatarPresentation
    let shouldShowDotsButton: Bool
    let location: NSAttributedString?
    let name: NSAttributedString
    let title: NSAttributedString?

    init(avatarPresentation: AvatarPresentation,
         shouldShowDotsButton: Bool = false,
         name: NSAttributedString,
         title: NSAttributedString? = nil,
         location: NSAttributedString?) {
        self.avatarPresentation = avatarPresentation
        self.shouldShowDotsButton = shouldShowDotsButton
        self.name = name
        self.title = title
        self.location = location
    }

    static func empty(avatarSize: AvatarPresentation.Size = .medium) -> UserSummaryPresentation {
        return UserSummaryPresentation(
            avatarPresentation: .empty,
            name: .empty,
            title: .empty,
            location: .empty
        )
    }
}
