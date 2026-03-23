//
//  MockRestService.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 15.07.22.
//

@testable import Armony
import Foundation
import XCTest

final class MockRestService: RestService {
    static var shared: MockRestService = MockRestService(backend: .factory())
    
    var stubbedResult: APIResponse?
    var error: Error?

    var executeExpectation = XCTestExpectation(description: "executeExpectation")

    override func execute<R>(task operation: RestAPI.Operation, type: R.Type) async throws -> R where R : APIResponse {
        if let error = error {
            throw error
        }
        
        if let result = stubbedResult as? R {
            return result
        }

        defer {
            executeExpectation.fulfill()
        }

        throw APIError.noData
    }

    var uploadExpectation = XCTestExpectation(description: "uploadExpectation")

    override func upload<R>(task operation: RestAPI.UploadOperation, type: R.Type) async throws -> R where R : APIResponse {
        if let error = error {
            throw error
        }
        
        if let result = stubbedResult as? R {
            return result
        }

        defer {
            uploadExpectation.fulfill()
        }

        throw APIError.noData
    }

    var loadExpectation = XCTestExpectation(description: "loadExpectation")

    override func load<R>(from jsonString: String, type: R.Type) throws -> R where R : APIResponse {
        if let error = error {
            throw error
        }
        
        if let result = stubbedResult as? R {
            return result
        }

        defer {
            loadExpectation.fulfill()
        }

        throw APIError.noData
    }

    var loadFromJSONFileExpectation = XCTestExpectation(description: "loadFromJSONFileExpectation")

    override func load<R>(fromJSONFile fileName: String, type: R.Type) -> R where R : APIResponse {
        let bundle = Bundle(for: MockRestService.self)
        let filePath = bundle.url(forResource: fileName, withExtension: ".json")
        let data = try! Data(contentsOf: filePath!, options: .alwaysMapped)
        let decodedObject = try! JSONDecoder().decode(R.self, from: data)

        defer {
            loadFromJSONFileExpectation.fulfill()
        }

        return decodedObject
    }
}


