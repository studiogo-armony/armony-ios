//
//  PlaceAdvertForm.swift
//  Armony
//

import Foundation

/// Describes which inputs the place advert form shows for an advert type.
struct PlaceAdvertForm {
    let validator: PlaceAdvertViewController.Validators
    let skillDropdown: DropdownPresentation
    /// `nil` keeps the music genre dropdown as it is.
    let musicGenreDropdown: DropdownPresentation?
    let isMusicGenresHidden: Bool
    let isInstructionTypeHidden: Bool

    func apply(to view: PlaceAdvertViewDelegate?) {
        view?.updateValidators(validator: validator)
        view?.configureSkillDropdownView(presentation: skillDropdown)
        if let musicGenreDropdown {
            view?.configureMusicGenreDropdownView(presentation: musicGenreDropdown)
        }
        view?.setMusicGenresDropdownViewVisibility(isHidden: isMusicGenresHidden)
        view?.setInstructionTypeDropdownViewVisibility(isHidden: isInstructionTypeHidden)
    }
}

// MARK: - Factory
extension PlaceAdvertForm {

    private static let formsByAdvertTypeID: [Int: PlaceAdvertForm] = [
        1: .musician,
        3: .event,
        4: .instructor,
        5: .event
    ]

    init(advertTypeID: Int) {
        self = Self.formsByAdvertTypeID[advertTypeID, default: .brand]
    }
}

// MARK: - Forms
extension PlaceAdvertForm {

    static let musician = PlaceAdvertForm(
        validator: .musician,
        skillDropdown: .skill,
        musicGenreDropdown: .musicGenres,
        isMusicGenresHidden: false,
        isInstructionTypeHidden: true
    )

    static let event = PlaceAdvertForm(
        validator: .event,
        skillDropdown: .services,
        musicGenreDropdown: nil,
        isMusicGenresHidden: true,
        isInstructionTypeHidden: true
    )

    static let instructor = PlaceAdvertForm(
        validator: .instructor,
        skillDropdown: .instruction,
        musicGenreDropdown: nil,
        isMusicGenresHidden: true,
        isInstructionTypeHidden: false
    )

    static let brand = PlaceAdvertForm(
        validator: .brand,
        skillDropdown: .skill,
        musicGenreDropdown: .musicGenres,
        isMusicGenresHidden: false,
        isInstructionTypeHidden: true
    )
}
