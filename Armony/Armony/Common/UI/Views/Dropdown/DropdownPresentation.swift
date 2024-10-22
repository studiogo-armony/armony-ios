//
//  DropdownPresentation.swift
//  Armony
//
//  Created by Koray Yıldız on 05.10.22.
//

import Foundation

struct DropdownPresentation {
    let title: String
    let placeholder: String

    init(title: String, placeholder: String) {
        self.title = title
        self.placeholder = placeholder
    }

    init(title: String) {
        self.init(title: title, placeholder: title)
    }

    // MARK: - EMPTY
    static let empty = DropdownPresentation(title: .empty, placeholder: .empty)

    static let title = DropdownPresentation(title: "Profil Türü")
    static let skill = DropdownPresentation(title: "Çaldığım Enstrümanlar")
    static let musicGenres = DropdownPresentation(title: "Müzik Tarzım")
    static let location = DropdownPresentation(title: "Konum")

    static let feedback = DropdownPresentation(
        title: Localization.CommonUI.Dropdown.feedbackTitle.localized,
        placeholder: Localization.CommonUI.Dropdown.feedbackPlaceholder.localized
    )
    static let advertType = DropdownPresentation(title: "İlan Türü")

    static let services = DropdownPresentation(title: "Verilen Hizmetler")
    static let instruction = DropdownPresentation(title: "Verilen Eğitimler")
    static let instructionType = DropdownPresentation(title: "Eğitim Şekli")
}
