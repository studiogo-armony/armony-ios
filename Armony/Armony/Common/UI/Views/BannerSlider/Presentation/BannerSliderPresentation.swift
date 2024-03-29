//
//  BannerSliderPresentation.swift
//  Armony
//
//  Created by Koray Yıldız on 1.02.2024.
//

import Foundation

struct BannerSliderPresentation {
    let isActive: Bool
    let banners: [BannerSliderItemPresentation]

    init(isActive: Bool, banners: [BannerSlider]) {
        self.isActive = isActive
        self.banners = banners.compactMap {
            return BannerSliderItemPresentation(title: $0.title,
                                                imageURL: $0.image,
                                                deeplink: $0.deeplink,
                                                backgroundColor: $0.backgroundColor)
        }
    }

    static let empty = BannerSliderPresentation(isActive: false, banners: .empty)
}

struct BannerSliderItemPresentation {
    let title: String
    let imageURL: URL
    let deeplink: Deeplink
    let backgroundColor: AppTheme.Color
}
