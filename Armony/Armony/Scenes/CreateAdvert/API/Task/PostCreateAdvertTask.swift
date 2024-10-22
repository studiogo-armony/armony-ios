//
//  PostCreateAdvertTask.swift
//  Armony
//
//  Created by Koray Yıldız on 05.10.22.
//

import Foundation
import Alamofire

struct PostCreateAdvertTask: HTTPTask {
    var path: String = "/ads"
    var method: HTTPMethod = .post
    var body: Parameters?

    init(request: CreateAdvertRequest) {
        body = request.body()
    }
}
