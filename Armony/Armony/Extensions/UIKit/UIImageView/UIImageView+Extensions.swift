//
//  UIImageView+Extensions.swift
//  Armony
//
//  Created by Koray Yıldız on 29.08.2021.
//

import UIKit
import AlamofireImage

public enum ImageSource {
    case url(placeholder: UIImage? = nil, URL?)
    case `static`(UIImage?)
}

public extension UIImageView {

    func setImage(source: ImageSource, completion: Callback<UIImage?>? = nil) {
        switch source {
        case .static(let image):
            self.image = image
            completion?(image)

        case .url(let placeholder, let url):
            RemoteImageLoaderProvider.current.setImage(
                on: self,
                url: url,
                placeholder: placeholder,
                completion: completion
            )
        }
    }
}

// MARK: - RemoteImageLoading

/// Loads `ImageSource.url` images into an image view.
protocol RemoteImageLoading {
    func setImage(on imageView: UIImageView, url: URL?, placeholder: UIImage?, completion: Callback<UIImage?>?)
}

/// Production source: downloads and caches images with AlamofireImage.
struct AlamofireRemoteImageLoader: RemoteImageLoading {

    func setImage(on imageView: UIImageView, url: URL?, placeholder: UIImage?, completion: Callback<UIImage?>?) {
        if let url = url {
            imageView.af.setImage(withURL: url,
                                  placeholderImage: placeholder,
                                  imageTransition: .crossDissolve(0.25),
                                  completion: { response in
                completion?(response.value)
            })
        }
        else {
            imageView.af.cancelImageRequest()
            imageView.image = placeholder
        }
    }
}

/// Snapshot tests swap `current` for a stub so URL images render without the network.
enum RemoteImageLoaderProvider {
    static var current: RemoteImageLoading = AlamofireRemoteImageLoader()
}
