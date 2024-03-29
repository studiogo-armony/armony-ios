//
//  APIError.swift
//  Armony
//
//  Created by Koray Yıldız on 27.08.2021.
//

import Foundation

public struct APIError: Error, Decodable {
    
    public let code: Int?
    public let description: String
    public let status: Int

    public init(code: Int = .zero, description: String) {
        self.code = code
        self.description = description
        self.status = NSNotFound
    }
    

    // TODO: - Localizable
    public static let emptyData = APIError(description: "Beklenmeyen bir hata oluştu")
    public static let noData = APIError(description: "Beklenmeyen bir hata oluştu")
    public static let operationCreate = APIError(description: "Beklenmeyen bir hata oluştu")
    public static let decoding = APIError(description: "Beklenmeyen bir hata oluştu")
    public static let network = APIError(description: "Beklenmeyen bir hata oluştu")
}
