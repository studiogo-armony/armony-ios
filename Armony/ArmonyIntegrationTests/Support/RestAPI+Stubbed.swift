//
//  RestAPI+Stubbed.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import Foundation
import KeychainAccess

extension RestAPI {

    /// Real `RestAPI` + `RestAPIMiddleware` stack whose requests are answered by `StubURLProtocol`.
    /// - Parameter keychain: Backs the middleware's `AuthenticationService`, so auth headers come from the test keychain.
    static func stubbed(keychain: Keychain = TestKeychain.make()) -> RestAPI {
        let authenticator = AuthenticationService(keychain: keychain, notifier: NotificationCenter())
        return RestAPI(interceptor: RestAPIMiddleware(authenticator: authenticator), configuration: .stubbed())
    }
}
