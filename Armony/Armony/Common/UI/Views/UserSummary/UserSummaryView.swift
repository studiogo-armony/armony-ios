//
//  UserSummaryView.swift
//  Armony
//
//  Created by Koray Yıldız on 1.09.2021.
//

import UIKit

protocol UserSummaryViewDelegate: AnyObject {
    func didTapInfoDotsButton(_ userSummaryView: UserSummaryView)
}

final class UserSummaryView: UIView, NibLoadable {

    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var locationImageView: UIImageView!
    @IBOutlet private(set) weak var infoDotButton: UIButton!

    var didTapAvatarView: Callback<UIImage?>? = nil
    var didTapNameLabel: VoidCallback? = nil

    weak var delegate: UserSummaryViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromNib()
        addTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initFromNib()
        addTapGesture()

        infoDotButton.touchUpInsideAction = { [unowned self] _ in
            self.delegate?.didTapInfoDotsButton(self)
        }
    }

    private func addTapGesture() {
        avatarView.addTapGestureRecognizer(action: { [weak self] _ in
            self?.didTapAvatarView?(self?.avatarView.imageView.image)
        })

        nameLabel.addTapGestureRecognizer(action: { [weak self] _ in
            self?.didTapNameLabel?()
        })
    }

    func configure(with presentation: UserSummaryPresentation) {
        avatarView.configure(with: presentation.avatarPresentation)
        nameLabel.hidableAttributedText = presentation.name
        titleLabel.hidableAttributedText = presentation.title
        infoDotButton.isHidden = !presentation.shouldShowDotsButton
        statusLabel.isHidden = true
        locationLabel.hidableAttributedText = presentation.location
        locationImageView.isHidden = presentation.location.ifNil(.empty).string.isEmpty
    }

    func prepareForReuse() {
        avatarView.imageView.image = nil
    }
}
