//
//  DeleteAccountFeedbackSelection.swift
//  Armony
//
//  Created by Koray Yıldız on 9.12.2023.
//

import Foundation

protocol DeleteAccountFeedbackSelectionDelegate: AnyObject {
    func deleteAccountFeedbackDidSelect(output: DeleteAccountFeedbackSelectionInput?)
}

struct DeleteAccountFeedbackSelection: SelectionPresentation {
    typealias Input = DeleteAccountFeedbackSelectionInput
    typealias Output = SingleSelectionOutput<DeleteAccountFeedbackSelectionInput>

    var items: [DeleteAccountFeedbackSelectionInput]
    var headerTitle: String = "Hesabınızı neden kalıcı olarak silmek istiyorsunuz?"
    var isMultipleSelectionAllowed: Bool = false
    weak var delegate: DeleteAccountFeedbackSelectionDelegate?

    func continueButtonTapped() {
        delegate?.deleteAccountFeedbackDidSelect(output: output.output)
    }
}

final class DeleteAccountFeedbackSelectionInput: SelectionInput {
    var id: Int
    var isSelected: Bool
    var title: String

    init(id: Int, isSelected: Bool, title: String) {
        self.id = id
        self.isSelected = isSelected
        self.title = title
    }
}
