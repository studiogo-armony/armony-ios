//
//  LogOutBottomViewModel.swift
//  Armony
//
//  Created by Koray Yildiz on 10.07.22.
//

import Foundation

final class LogOutBottomPopUpViewModel: ViewModel {

    var coordinator: (any LogOutBottomPopUpCoordinating)!

    private weak var view: LogOutBottomPopUpViewDelegate?
    private let authenticator: AuthenticationProviding
    private let notifier: NotificationPosting

    init(
        view: LogOutBottomPopUpViewDelegate,
        authenticator: AuthenticationProviding = AuthenticationService.shared,
        notifier: NotificationPosting = NotificationCenter.default,
        service: RestService = RestService(backend: .factory())
    ) {
        self.view = view
        self.authenticator = authenticator
        self.notifier = notifier
        super.init(service: service)
    }

    func logOut() {
        view?.startLogoutButtonActivityIndicatorView()
        Task {
            do {
                let _ = try await service.execute(
                    task: PostLogoutTask(),
                    type: RestObjectResponse<EmptyResponse>.self
                )

                authenticator.unauthenticate()
                notifier.post(notification: .userLoggedOut, object: nil, userInfo: nil)

                AdjustLogOutEvet().send()

                safeSync {
                    view?.stopLogoutButtonActivityIndicatorView()
                    coordinator.dismiss(animated: true) { [weak self] in
                        self?.coordinator.popToRootViewController(animated: false)
                        self?.coordinator.selectTab(tab: .home, shouldPopToRoot: true)
                    }
                }
            }
            catch {
                safeSync {
                    view?.stopLogoutButtonActivityIndicatorView()
                }
            }
        }
    }
}

struct AdjustLogOutEvet: AdjustEvent {
    var token: String = "6rjyuv"
}
