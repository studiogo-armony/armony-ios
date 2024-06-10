//
//  CardPresentation.swift
//  Armony
//
//  Created by Koray Yildiz on 23.12.22.
//

import Foundation

public struct CardPresentation {

    public let id: Int
    public let colorCode: String
    public let isActive: Bool
    public let status: Advert.Status
    public let userSummaryPresentation : UserSummaryPresentation
    public let skillsPresentation: SkillsPresentation

    public init(id: Int,
                colorCode: String,
                isActive: Bool,
                status: Advert.Status,
                userSummaryPresentation: UserSummaryPresentation,
                skillsPresentation: SkillsPresentation) {
        self.id = id
        self.colorCode = colorCode
        self.isActive = isActive
        self.status = status
        self.userSummaryPresentation = userSummaryPresentation
        self.skillsPresentation = skillsPresentation
    }

    public init(advert: Advert) {
        id = advert.id
        colorCode = advert.type.colorCode
        isActive = advert.isActive
        status = advert.status

        let avatarPresentation = AvatarPresentation(
            kind: .custom(.init(size: .custom(72), radius: .medium)),
            source: .url(advert.user.avatarURL)
        )
        userSummaryPresentation = UserSummaryPresentation(
            avatarPresentation: avatarPresentation,
            name: advert.user.name.attributed(color: .white, font: .regularBody),
            location: advert.location.title.attributed(color: .white, font: .regularBody), 
            cardTitle: advert.type.title.attributed(.armonyWhite, font: .semiboldHeading), 
            updateDate: advert.updateDate.attributed(color: .white, font: .regularBody)
        )

        skillsPresentation = SkillsPresentation(
            type: .adverts(imageViewContainerBackgroundColor: colorCode.colorFromHEX),
            title: advert.type.skillTitle.attributed(color: .white, font: .lightBody),
            skillTitleStyle: TextAppearancePresentation(color: .white, font: .regularBody),
            skills: advert.skills
        )
    }

    // MARK: - EMPTY
    static let empty = CardPresentation(id: .invalid,
                                        colorCode: .empty,
                                        isActive: false, 
                                        status: .inactive,
                                        userSummaryPresentation: .empty(),
                                        skillsPresentation: .empty)
}
