//
//  File.swift
//  Armony
//
//  Created by Koray Yıldız on 24.01.2022.
//

import UIKit

struct MusicGenreCellPresentation {
    let borderColor: UIColor
    let borderWidth: CGFloat
    let item: MusicGenreItemPresentation

    init(borderColor: UIColor, borderWidth: AppTheme.Border, item: MusicGenreItemPresentation) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth.rawValue
        self.item = item
    }
}

// MARK: - MusicGenreItemPresentation
struct MusicGenreItemPresentation: Hashable {
    let id: Int
    let title: NSAttributedString

    init(genre: MusicGenre, titleStyle: TextAppearancePresentation) {
        self.id = genre.id
        self.title = genre.name.attributed(titleStyle.color, font: titleStyle.font)
    }

    init(genre: ServiceResponse, titleStyle: TextAppearancePresentation) {
        self.id = genre.id
        self.title = genre.title.attributed(titleStyle.color, font: titleStyle.font)
    }

    init(genre: Skill, titleStyle: TextAppearancePresentation) {
        self.id = genre.id
        self.title = genre.title.attributed(titleStyle.color, font: titleStyle.font)
    }
}
