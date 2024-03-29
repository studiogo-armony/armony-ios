//
//  CreateAdvertRequest.swift
//  Armony
//
//  Created by Koray Yıldız on 06.10.22.
//

import Foundation

struct CreateAdvertRequest: Encodable {
    var advertTypeID: Int
    var skills: [Skill]?
    var location: Location?
    var genres: [MusicGenre]?
    var description: String?

    init(advertTypeID: Int,
         city: Location,
         genres: [MusicGenre],
         skills: [Skill],
         description: String?) {
        self.advertTypeID = advertTypeID
        self.location = city
        self.genres = genres
        self.skills = skills
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case advertTypeID = "adTypeId"
        case location = "city"
        case skills, genres, description
    }

    // MARK: - EMPTY
    static let empty = CreateAdvertRequest(
        advertTypeID: .invalid,
        city: .empty,
        genres: .empty,
        skills: .empty,
        description: nil
    )
}
