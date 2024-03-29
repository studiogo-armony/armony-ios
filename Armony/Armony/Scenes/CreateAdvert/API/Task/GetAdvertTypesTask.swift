//
//  GetAdvertTypesTask.swift
//  Armony
//
//  Created by Koray Yıldız on 05.10.22.
//

import Alamofire
import Foundation

struct GetAdvertTypesTask: HTTPTask {
    var method: HTTPMethod = .get
    var path: String = "/adtypes"
}
