//
//  AvatarPresentation.swift
//  Armony
//
//  Created by Koray Yıldız on 8.09.2021.
//

import UIKit

struct AvatarPresentation {

    enum Size {
        /// 52.0
        case small

        /// 80.0
        case medium

        /// Custom size
        case custom(CGFloat)

        var size: CGSize {
            switch self {
            case .small:
                return CGSize(size: 52.0)

            case .medium:
                return CGSize(size: 80.0)

            case .custom(let width):
                return CGSize(size: width)
            }
        }

        var width: CGFloat {
            return size.width
        }
    }

    private(set) var size: AvatarPresentation.Size
    private(set) var source: ImageSource

    init(size: AvatarPresentation.Size, source: ImageSource) {
        self.size = size

        switch source {
        case .static(let image):
            self.source = .static(image)

        case .url(let placeholder, let url):
            self.source = .url(placeholder: placeholder ?? .avatarPlaceholder, url)
        }
    }

    // MARK: - EMPTY
    static let empty = AvatarPresentation(size: .small, source: .static(.avatarPlaceholder))
}
