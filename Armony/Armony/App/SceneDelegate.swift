//
//  SceneDelegate.swift
//  Armony
//
//  Created by Koray Yıldız on 16.11.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Variables
    private let navigation: URLNavigation = URLNavigator.shared

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if AppDelegate.isRunningAsTestHost {
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            return
        }

        #if DEBUG
        if UITestLaunchConfiguration.isEnabled {
            startAsUITestApp(window: window)
            return
        }
        #endif

        if let url = connectionOptions.urlContexts.first?.url {
            AppLaunchService.shared.handleLaunch(url: url)
        }

        AppCoordinator(window: window).start()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        navigation.open(url.deeplink, dismissToRoot: true)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        AppDelegate.shared?.sceneDidBecomeActive()
    }
}

// MARK: - Private Methods
private extension SceneDelegate {
    #if DEBUG
    /// UI tests launch the app in its own process: the real tab bar flow, but without splash, remote config,
    /// permission prompts or analytics (see `UITestLaunchConfiguration`).
    func startAsUITestApp(window: UIWindow) {
        AppCoordinator(window: window).startAsArmony()
        window.makeKeyAndVisible()

        if let deeplink = UITestLaunchConfiguration.deeplink {
            navigation.open(deeplink, dismissToRoot: false)
        }
    }
    #endif
}
