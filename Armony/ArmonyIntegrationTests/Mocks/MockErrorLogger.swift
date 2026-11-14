//
//  MockErrorLogger.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony

final class MockErrorLogger: ErrorLogging {

    var invokedLogException = false
    var invokedLogExceptionCount = 0
    var invokedLogExceptionParameters: (exception: Exception, Void)?

    func log(exception: Exception) {
        invokedLogException = true
        invokedLogExceptionCount += 1
        invokedLogExceptionParameters = (exception, ())
    }

    var invokedLogError = false
    var invokedLogErrorCount = 0
    var invokedLogErrorParameters: (error: Error?, Void)?

    func log(error: Error?) {
        invokedLogError = true
        invokedLogErrorCount += 1
        invokedLogErrorParameters = (error, ())
    }
}
