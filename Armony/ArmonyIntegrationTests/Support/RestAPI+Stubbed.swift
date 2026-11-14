//
//  RestAPI+Stubbed.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

@testable import Armony
import Foundation

extension RestAPI {

    /// Real `RestAPI` stack whose requests are answered by `StubURLProtocol`.
    static func stubbed(middleware: RestAPIMiddleware = .stubbed()) -> RestAPI {
        return RestAPI(interceptor: middleware, configuration: .stubbed())
    }
}

extension RestAPIMiddleware {

    /// Real middleware logic with test collaborators. The `/auth/refresh` call also goes through `StubURLProtocol`.
    /// - Parameter sessionExpiredHandler: Defaults to continuing immediately instead of presenting login.
    static func stubbed(
        authenticator: AuthenticationProviding = AuthenticationService(keychain: TestKeychain.make(), notifier: NotificationCenter()),
        defaults: Defaults = TestDefaults.make(),
        logger: ErrorLogging = MockErrorLogger(),
        sessionExpiredHandler: @escaping SessionExpiredHandler = { $0() }
    ) -> RestAPIMiddleware {
        let tokenServiceFactory = {
            RestService(
                backend: RestAPI(interceptor: RestAPIMiddleware(authenticator: authenticator, defaults: defaults, logger: logger),
                                 configuration: .stubbed()),
                internetConnectionService: MockInternetConnectionChecker(),
                logger: MockErrorLogger()
            )
        }
        return RestAPIMiddleware(authenticator: authenticator,
                                 defaults: defaults,
                                 logger: logger,
                                 tokenServiceFactory: tokenServiceFactory,
                                 sessionExpiredHandler: sessionExpiredHandler)
    }
}
