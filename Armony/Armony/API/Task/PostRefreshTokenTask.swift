//
//  PostRefreshTokenTask.swift
//  Armony
//
//  Created by Koray Yildiz on 02.08.22.
//

import Foundation
import Alamofire

extension HTTPMethod: @retroactive @unchecked Sendable {

}

struct PostRefreshTokenTask: HTTPTask {
    let method: HTTPMethod = .post
    let path: String = "/auth/refresh"
    let body: Parameters?

    init(request: RefreshTokenRequest) {
        body = request.body()
    }
}

// MARK: - RefreshTokenRequest
struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

// MARK: - RefreshTokenResponse
struct RefreshTokenResponse: Decodable {
    let access: String
    let refresh: String

    enum CodingKeys: String, CodingKey {
        case access = "accessToken"
        case refresh = "refreshToken"
    }
}
