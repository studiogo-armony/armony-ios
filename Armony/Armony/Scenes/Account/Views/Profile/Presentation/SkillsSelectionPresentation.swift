//
//  SkillsSelectionPresentation.swift
//  Armony
//
//  Created by Koray Yildiz on 23.07.22.
//

import Foundation

protocol SkillsSelectionDelegate: AnyObject {
    func skillsDidSelect(skills: [SelectionInput]?)
}

struct SkillsSelectionPresentation: SelectionPresentation {

    typealias Input = SkillsSelectionInput
    typealias Output = MultipleSelectionOutput<SkillsSelectionInput>

    weak var delegate: SkillsSelectionDelegate?
    var items: [SkillsSelectionInput]

    var headerTitle: String = "Çaldığın Enstrümanları Ekle"
    var isMultipleSelectionAllowed: Bool = true

    init(delegate: SkillsSelectionDelegate? = nil,
         items: [SkillsSelectionInput],
         headerTitle: String = "Çaldığın Enstrümanları Ekle",
         isMultipleSelectionAllowed: Bool = true) {
        self.delegate = delegate
        self.items = items
        self.headerTitle = headerTitle
        self.isMultipleSelectionAllowed = isMultipleSelectionAllowed
    }

    func continueButtonTapped() {
        delegate?.skillsDidSelect(skills: output.output)
    }
}

// MARK: - SkillsSelectionInput
final class SkillsSelectionInput: SelectionInput {
    var id: Int
    var title: String
    var isSelected: Bool

    init(id: Int, title: String, isSelected: Bool) {
        self.id = id
        self.title = title
        self.isSelected = isSelected
    }
}
