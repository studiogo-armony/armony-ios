//
//  SplashCoordinating.swift
//  Armony
//
//  Created by Koray Yildiz on 16.08.26.
//

import Foundation

protocol SplashCoordinating: CoordinatorInterface {
    func armony()
    func open(urlString: String)
}

protocol RemoteConfigProviding {
    func start() async throws
    subscript(key: HashableKey) -> Bool { get }
}

protocol ForceUpdateHandling {
    func shouldUpdate() async throws -> Bool
}

extension RemoteConfigService: RemoteConfigProviding {}
extension ForceUpdateHandler: ForceUpdateHandling {}
