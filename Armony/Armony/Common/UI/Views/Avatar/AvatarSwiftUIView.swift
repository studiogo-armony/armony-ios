//
//  AvatarSwiftUIView.swift
//  Armony
//
//  Created by KORAY YILDIZ on 17.07.2025.
//

import SwiftUI

struct AvatarSwiftUIView: View {
    private let presentation: AvatarPresentation

    init(presentation: AvatarPresentation) {
        self.presentation = presentation
    }

    var body: some View {
        switch presentation.kind {
        case .circled:
            makeImage(source: presentation.source)
                .clipShape(.circle)

        case .custom(let configuration):
            makeImage(source: presentation.source)
                .cornerRadius(configuration.radius.ifNil(.medium))
        }
    }

    @ViewBuilder
    private func makeImage(source: ImageSource) -> some View {
        ZStack {
            switch source {
            case .url(let placeholder, let url):
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    if let placeholder {
                        Image(uiImage: placeholder)
                    }
                }

            case .static(let image):
                if let image {
                    Image(uiImage: image)
                        .resizable()
                }
            }
        }
        .frame(size: presentation.kind.size)
    }
}

#Preview {
    let url = URL.randomImage(size: 80)

    VStack {
        AvatarSwiftUIView(
            presentation: .init(kind: .custom(.init(size: .small, radius: .low)), source: .url(placeholder: .avatarPlaceholder, url))
        )
        AvatarSwiftUIView(
            presentation: .init(kind: .custom(.init(size: .medium, radius: .high)), source: .url(placeholder: .avatarPlaceholder, url))
        )
        AvatarSwiftUIView(
            presentation: .init(kind: .custom(.init(size: .medium, radius: .low)), source: .url(placeholder: .avatarPlaceholder, url))
        )
        AvatarSwiftUIView(
            presentation: .init(kind: .circled(.init(size: .medium)), source: .url(placeholder: .avatarPlaceholder, url))
        )
        AvatarSwiftUIView(
            presentation: .init(kind: .circled(.init(size: .small)), source: .url(placeholder: .avatarPlaceholder, url))
        )

        AvatarSwiftUIView(
            presentation: .init(kind: .custom(.init(size: .medium)), source: .static(.avatarPlaceholder))
        )
    }
}

extension View {
    func cornerRadius(_ radius: AppTheme.Radius) -> some View {
        clipShape(.rect(cornerRadius: radius.rawValue))
    }

    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.width)
    }
}
