//
//  SplashViewModel.swift
//  Armony
//
//  Created by Koray Yıldız on 11.02.2022.
//

import Foundation

final class SplashViewModel: ViewModel {

    var coordinator: (any SplashCoordinating)!
    private let remoteConfigService: RemoteConfigProviding
    private let forceUpdateHandler: ForceUpdateHandling

    init(
        remoteConfigService: RemoteConfigProviding = RemoteConfigService.shared,
        forceUpdateHandler: ForceUpdateHandling = ForceUpdateHandler()
    ) {
        self.remoteConfigService = remoteConfigService
        self.forceUpdateHandler = forceUpdateHandler
        super.init()
    }
}

// MARK: - ViewModelLifeCycle
extension SplashViewModel: ViewModelLifeCycle {
    func viewDidLoad() {
        Task {
            do {
                let _ = try await remoteConfigService.start()

                if remoteConfigService["FORCE_UPDATE"] {
                    let shouldUpdate = try await forceUpdateHandler.shouldUpdate()
                    guard shouldUpdate else {
                        safeSync {
                            coordinator.armony()
                        }
                        return
                    }

                    await AlertService.show(
                        title: "Armony'i Güncelle",
                        message: "Uygulamayı tüm güncel özellikleri ile kullanabilmeniz için son versiyonu yüklemeniz gerekmektedir.",
                        actions: [.okay(action: { [weak self] in
                            safeSync {
                                self?.coordinator.open(urlString: "itms-apps://itunes.apple.com/app/id1662284112")
                            }
                        })]
                    )
                }
                else {
                    safeSync {
                        coordinator.armony()
                    }
                }
            }
            catch {
                await AlertService.show(message: "Tekrar Dene", actions: [.okay(action: { [weak self] in
                    self?.viewWillAppear()
                })])
            }
        }
    }
}
