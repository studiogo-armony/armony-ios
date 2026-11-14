//
//  SnapshotTestCase.swift
//  ArmonyTests
//

import XCTest

/// Base class for snapshot tests.
///
/// Rendering depends on the simulator (screen scale, layout margins, iOS font rendering),
/// so reference images are only comparable on the device they were recorded on.
/// Running on any other simulator fails with an explicit message instead of pixel diffs.
class SnapshotTestCase: XCTestCase {

    static let referenceModelIdentifier = "iPhone17,3"
    static let referenceDeviceName = "iPhone 16"
    static let referenceSystemVersion = "18.6"

    override func setUpWithError() throws {
        try super.setUpWithError()

        let environment = ProcessInfo.processInfo.environment
        let modelIdentifier = environment["SIMULATOR_MODEL_IDENTIFIER"]
        let systemVersion = UIDevice.current.systemVersion

        guard modelIdentifier == Self.referenceModelIdentifier, systemVersion == Self.referenceSystemVersion else {
            throw SnapshotEnvironmentError(
                description: """
                Snapshot tests must run on \(Self.referenceDeviceName) (iOS \(Self.referenceSystemVersion)) simulator. \
                Current: \(environment["SIMULATOR_DEVICE_NAME"] ?? "unknown device") \
                (\(modelIdentifier ?? "unknown model"), iOS \(systemVersion)).
                """
            )
        }
    }
}

private struct SnapshotEnvironmentError: Error, CustomStringConvertible {
    let description: String
}
