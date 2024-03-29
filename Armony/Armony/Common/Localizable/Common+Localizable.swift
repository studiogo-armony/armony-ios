//
//  Common+Localizable.swift
//  Armony
//
//  Created by Koray Yıldız on 12.10.22.
//

extension Localization {
    enum Common: String, Localizable {
        case cancel = "Common.Cancel"
        case ok = "Common.OK"
        case save = "Common.Save"
        
        var fileName: String {
            return "Common+Localizable"
        }
    }
}
