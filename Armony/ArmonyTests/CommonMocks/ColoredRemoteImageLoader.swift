//
//  ColoredRemoteImageLoader.swift
//  ArmonyTests
//

import UIKit
@testable import Armony

/// Replaces network image loading with a solid color image picked from the URL.
///
/// The color looks random across URLs but is stable for the same URL (no `hashValue`,
/// which is seeded per process), so snapshots stay deterministic.
struct ColoredRemoteImageLoader: RemoteImageLoading {

    private static let palette: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen,
        .systemTeal, .systemBlue, .systemIndigo, .systemPink
    ]

    func setImage(on imageView: UIImageView, url: URL?, placeholder: UIImage?, completion: Callback<UIImage?>?) {
        guard let url = url else {
            imageView.image = placeholder
            return
        }

        let image = Self.image(for: url)
        imageView.image = image
        completion?(image)
    }

    static func color(for url: URL) -> UIColor {
        // djb2
        let hash = url.absoluteString.utf8.reduce(UInt64(5381)) { ($0 &<< 5) &+ $0 &+ UInt64($1) }
        return palette[Int(hash % UInt64(palette.count))]
    }

    private static func image(for url: URL) -> UIImage {
        let color = color(for: url).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
}
