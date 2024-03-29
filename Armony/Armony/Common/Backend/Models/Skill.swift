//
//  Skill.swift
//  Armony
//
//  Created by Koray Yıldız on 8.10.2021.
//

import UIKit

struct Skill: Codable {
    let id: Int
    let iconURL: URL?
    let title: String
    let colorCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case iconURL = "imageUrl"
        case title = "name"
        case colorCode
    }
}

// MARK: - Location
extension RestArrayResponse where T == Location {

    func itemsForSelection(selectedID: Int?) -> [LocationSelectionInput] {
        let items: [LocationSelectionInput] = data.compactMap { location in
            return LocationSelectionInput(
                id: location.id,
                title: location.title,
                isSelected: selectedID == location.id
            )
        }
        return items
    }
}

// MARK: - Skill
extension RestArrayResponse where T == Skill {

    func itemsForSelection(selectedIDs: [Int]) -> [SkillsSelectionInput] {
        let items: [SkillsSelectionInput] = data.compactMap { skill in
            return SkillsSelectionInput(
                id: skill.id,
                title: skill.title,
                isSelected: selectedIDs.contains(skill.id)
            )
        }
        return items
    }
}

// MARK: - AdvertType
extension RestArrayResponse where T == AdvertType {

    func itemsForSelection(selectedID: Int?) -> [AdvertTypeSelectionInput] {
        let items: [AdvertTypeSelectionInput] = data.compactMap { advertType in
            return AdvertTypeSelectionInput(
                id: advertType.id,
                title: advertType.name,
                isSelected: selectedID == advertType.id
            )
        }
        return items
    }
}

// MARK: - MusicGenre
extension RestArrayResponse where T == MusicGenre {

    func itemsForSelection(selectedIDs: [Int]) -> [MusicGenresSelectionInput] {
        let items: [MusicGenresSelectionInput] = data.compactMap { advertType in
            return MusicGenresSelectionInput(
                id: advertType.id,
                title: advertType.name,
                isSelected: selectedIDs.contains(advertType.id)
            )
        }
        return items
    }
}
