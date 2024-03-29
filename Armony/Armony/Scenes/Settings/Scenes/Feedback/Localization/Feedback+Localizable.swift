//
//  Localization+d.swift
//  Armony
//
//  Created by Koray Yildiz on 08.12.22.
//

import Foundation

extension Localization {
    enum Feedback: String, Localizable {
        case subjectSelectionHeaderTitle = "Feedback.SubjectSelection.Header.Title"
        case submitButtonTitle = "Feedback.SubmitButton.Title"
        case submissionSuccesMessage = "Feedback.Submission.Succes.Title"
        case title = "Feedback.Title"

        var fileName: String {
            return "Feedback+Localizable"
        }
    }
}
