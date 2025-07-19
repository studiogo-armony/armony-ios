//
//  MusicGenreItemSwiftUIView.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

/// MusicGenreCellPresentation
typealias MusicGenreSwiftUIItemPresentation = MusicGenreCellPresentation

struct MusicGenreItemSwiftUIView: View {

    private let presentation: MusicGenreSwiftUIItemPresentation

    init(presentation: MusicGenreSwiftUIItemPresentation) {
        self.presentation = presentation
    }

    var body: some View {
        Text(AttributedString(presentation.item.title))
            .padding(.horizontal, spacing: .sixteen)
            .padding(.vertical, spacing: .four)
            .border(color: presentation.borderColor, radius: .low)
    }
}

#Preview {
    HStack {
        let item1 = MusicGenreItemPresentation(
            genre: MusicGenre(id: 1, name: "Koray Yıldız"),
            titleStyle: .init(.white, font: .lightBody)
        )

        let item2 = MusicGenreItemPresentation(
            genre: MusicGenre(id: 1, name: "Koray Yıldız"),
            titleStyle: .init(.white, font: .lightBody)
        )

        MusicGenreItemSwiftUIView(
            presentation: MusicGenreSwiftUIItemPresentation(
                borderColor: .armonyGreen,
                borderWidth: .default,
                item: item1
            )
        )

        MusicGenreItemSwiftUIView(
            presentation: MusicGenreSwiftUIItemPresentation(
                borderColor: .armonyBlue,
                borderWidth: .default,
                item: item1
            )
        )

        MusicGenreItemSwiftUIView(
            presentation: MusicGenreSwiftUIItemPresentation(
                borderColor: .armonyRed,
                borderWidth: .default,
                item: item1
            )
        )
    }
    .background(Color.armonyDarkBlue)
}
