//
//  ApplicationResetHandler.swift
//  Armony
//
//  Created by Koray Yildiz on 04.02.23.
//

import Foundation

protocol ApplicationResetHandling {
    func reset()
}

public protocol ResetHandling {
    func reset()
}

public class ApplicationResetHandler: ApplicationResetHandling {

    public static let shared = ApplicationResetHandler()

    private(set) var services: [any ResetHandling] = [
        AuthenticationService.shared,
        Defaults.shared,
        AppLaunchService.shared,
        MessageCountSocketHandler.shared
    ]

    func reset() {
        services.forEach {
            $0.reset()
        }
    }
}
