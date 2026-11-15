//
//  UITestLaunchConfiguration.swift
//  Armony
//

import UIKit

/// Puts the app into a known, hermetic state when UI tests launch it with `UITestLaunchArgument.enabled`.
///
/// - No splash / remote config fetch: the app starts on the tab bar.
/// - Signed out, onboarding already seen, animations off.
/// - Every request goes to a host that can never resolve, so UI tests never reach a real backend.
///
/// Only available in Debug builds; Release builds ignore the launch argument.
enum UITestLaunchConfiguration {

    static var isEnabled: Bool {
        #if DEBUG
        return CommandLine.arguments.contains(UITestLaunchArgument.enabled)
        #else
        return false
        #endif
    }

    #if DEBUG
    /// Makes sessions created while UI testing answer from the stubs the test passed in, instead of the network.
    static func installStubs(on configuration: URLSessionConfiguration) {
        guard isEnabled else { return }
        configuration.protocolClasses = [UITestStubURLProtocol.self]
    }

    static var deeplink: Deeplink? {
        guard let path = ProcessInfo.processInfo.environment[UITestLaunchEnvironment.deeplink] else { return nil }
        return Deeplink(stringLiteral: path)
    }

    static func apply() {
        APIEnvironmentProvider.current = UITestAPIEnvironment()
        if CommandLine.arguments.contains(UITestLaunchArgument.signedIn) {
            AuthenticationService.shared.authenticate(
                accessToken: UITestSession.accessToken,
                refreshToken: UITestSession.refreshToken,
                userID: UITestSession.userID
            )
        }
        else {
            AuthenticationService.shared.unauthenticate()
        }
        Defaults.shared[.isFirtRun] = true
        Defaults.shared[.onboardingHasSeen] = true
        UIView.setAnimationsEnabled(false)
    }
    #endif
}

#if DEBUG
/// `.invalid` is reserved (RFC 2606) and guaranteed never to resolve.
private struct UITestAPIEnvironment: APIEnvironment {
    let scheme = "https"
    let host = "ui-tests.armony.invalid"
    let version = "v1"
}
#endif
