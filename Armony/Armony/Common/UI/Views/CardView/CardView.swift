//
//  CardView.swift
//  Armony
//
//  Created by Koray Yildiz on 23.12.22.
//

import UIKit

public final class CardView: UIView, NibLoadable {

    @IBOutlet private weak var titleContainerView: UIView!
    @IBOutlet private weak var titleAccessoryView: TitleAccessoryView!
    @IBOutlet private weak var userSummaryView: UserSummaryView!
    @IBOutlet private weak var skillsView: SkillsView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initFromNib()
    }

    public func configure(presentation: CardPresentation) {
        titleContainerView.backgroundColor = presentation.colorCode.colorFromHEX
        titleAccessoryView.configure(with: presentation.titleAccessoryPresentation)
        userSummaryView.configure(with: presentation.userSummaryPresentation)
        skillsView.configure(with: presentation.skillsPresentation)
    }

    func prepareForReuse() {
        userSummaryView.prepareForReuse()
    }
}
