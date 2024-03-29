//
//  AvatarView.swift
//  Armony
//
//  Created by Koray Yıldız on 28.08.2021.
//

import UIKit

final class AvatarView: UIView, NibLoadable {

    @IBOutlet private weak var borderImageView: UIImageView!
    @IBOutlet weak var borderImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromNib()
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initFromNib()
        configure()
    }

    private func configure() {
        imageView.contentMode = .scaleAspectFill
        borderImageView.contentMode = .scaleAspectFill
        borderImageView.bringSubviewToFront(self)
        imageView.image = .avatarPlaceholder
        DispatchQueue.main.async {
            self.imageView.circled()
        }
    }

    func configure(with presentation: AvatarPresentation) {
        if borderImageViewWidthConstraint.constant != presentation.size.width {
            borderImageViewWidthConstraint.constant = presentation.size.width
        }
        imageView.setImage(source: presentation.source) { [weak self] _ in
            DispatchQueue.main.async {
                self?.imageView.circled()
            }
        }
    }
}
