//
//  MusicGenresSwiftUIView.swift
//  Armony
//
//  Created by KORAY YILDIZ on 19.07.2025.
//

import SwiftUI

///MusicGenresPresentation
typealias MusicGenresSwiftUIPresentation = MusicGenresPresentation

struct MusicGenresSwiftUIView: View {

    private let presentation: MusicGenresPresentation

    init(presentation: MusicGenresPresentation) {
        self.presentation = presentation
    }

    var body: some View {
        VStack(distance: .eight) {

            VStack(alignment: .leading, distance: .four) {
                Text(presentation.title.attributed)
                GradientSwiftUIView(presentation: presentation.separatorPresentation)
                    .frame(height: 1.0)
            }

            TagLayout(items: presentation.items) { item in
                MusicGenreItemSwiftUIView(
                    presentation: MusicGenreSwiftUIItemPresentation(
                        borderColor: presentation.cellBorderColor,
                        borderWidth: .default,
                        item: item
                    )
                )
            }
        }
    }
}

#Preview {
    let genres = [
        MusicGenre(id: 1, name: "Koray"),
        MusicGenre(id: 2, name: "Koray dasfas"),
        MusicGenre(id: 3, name: "Korayfasd"),
        MusicGenre(id: 4, name: "Korafsa"),
        MusicGenre(id: 5, name: "Korayfsadfsafsa"),
        MusicGenre(id: 6, name: "Jazz"),
    ]

    let genreItemTitleStyle = TextAppearancePresentation(color: .white, font: .lightBody)
    let genreItems: [MusicGenreItemPresentation] = genres.lazy.map {
        MusicGenreItemPresentation(genre: $0, titleStyle: genreItemTitleStyle)
    }

    MusicGenresSwiftUIView(
        presentation: MusicGenresPresentation(
            cellBorderColor: .armonyBlue,
            separator: .separator,
            items: genreItems,
            shouldAdjustCellHeight: false
        )
    )
    .background(.armonyDarkBlue)
}
