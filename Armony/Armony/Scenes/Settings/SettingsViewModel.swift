//
//  SettingsViewModel.swift
//  Armony
//
//  Created by Koray Yildiz on 27.05.22.
//

import Foundation

final class SettingsViewModel: ViewModel {

    var coordinator: SettingsCoordinator!

    private weak var view: SettingsViewDelegate?
    private let authenticator: AuthenticationService

    var numberOfRowsInSection: Int {
        return presentation.items.count
    }

    private var presentation: SettingsPresentation = .empty {
        didSet {
            view?.reloadData()
        }
    }

    init(view: SettingsViewDelegate,
         authenticator: AuthenticationService = .shared) {
        self.view = view
        self.authenticator = authenticator
        super.init()
    }

    func setting(at indexPath: IndexPath) -> SettingPresentation {
        return presentation.items.element(at: indexPath.row).ifNil(.empty)
    }

    func didSelectSetting(at indexPath: IndexPath) {
        let deeplink = setting(at: indexPath).deeplink
        coordinator.open(deeplink: deeplink)
    }

    func fetchSettingsData() {
        let jsonString: String = RemoteConfigService.shared[.settingsData]
        do {
            let response = try service.load(from: jsonString, type: RestArrayResponse<Setting>.self)
            presentation = SettingsPresentation(settings: response.data.filter { $0.isVisible })
        }
        catch {
            presentation = .empty
        }
    }
}
