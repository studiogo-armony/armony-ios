//
//  TestAPIEnvironment.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony

/// Fixed API environment so request URLs never depend on remote config fetched on the simulator.
struct TestAPIEnvironment: APIEnvironment {
    var scheme: String = "https"
    var host: String = "test.armony.local"
    var version: String = "v1"
}
