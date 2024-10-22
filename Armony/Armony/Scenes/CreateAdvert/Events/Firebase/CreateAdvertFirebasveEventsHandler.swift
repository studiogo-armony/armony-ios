//
//  CreateAdvertFirebasveEventsHandler.swift
//  Armony
//
//  Created by Koray Yıldız on 23.12.2023.
//

import Foundation

final class CreateAdvertFirebasveEventsHandler {
    static func track(request: CreateAdvertRequest) {

        if let type = AdvertTypes(rawValue: request.advertTypeID) {

            let skills = request.skills?.compactMap {
                $0.title
            }.joined(separator: .comma)

            let musicGenres = request.genres?.compactMap {
                $0.name
            }.joined(separator: .comma)

            let location = request.location?.title

            CreateAdvertFirebaseEvents(
                advertType: type,
                skills: skills.emptyIfNil,
                musicGenres: musicGenres.emptyIfNil,
                location: location.emptyIfNil,
                explanation: request.description.emptyIfNil
            ).send()
        }
    }
}
