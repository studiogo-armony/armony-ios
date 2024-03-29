//
//  VisitedAccountAdvertsViewModel.swift
//  Armony
//
//  Created by Koray Yildiz on 11.12.22.
//

import Foundation

final class VisitedAccountAdvertsViewModel: ViewModel {

    var coordinator: VisitedAccountAdvertsCoordinator!
    private weak var view: VisitedAccountAdvertsViewDelegate?
    private let userID: String

    var presentation: AdvertsPresentation = .empty {
        didSet {
            view?.reloadCollectionView()
        }
    }

    var numberOfItemsInSection: Int {
        return presentation.cards.count
    }

    init(view: VisitedAccountAdvertsViewDelegate, userID: String) {
        self.view = view
        self.userID = userID
        super.init()
    }

    func card(at indexPath: IndexPath) -> CardPresentation {
        return presentation.cards[indexPath.row]
    }

    func fetchAdverts() {
        Task {
            do {
                let response = try await service.execute(task: GetUserAdvertsTask(userID: userID),
                                                         type: RestArrayResponse<Advert>.self)

                safeSync {
                    view?.stopActivityIndicatorView()
                    presentation = AdvertsPresentation(adverts: response.data)
                    view?.setCollectionViewVisibility(isHidden: false, animated: true)
                    view?.reloadCollectionView()
                }
            }
            catch let error {
                await AlertService.show(error: error.api, actions: [.okay()])
            }
        }
    }

    @objc func refresh() {
        fetchAdverts()
    }
}

// MARK: - ViewModelLifeCycle
extension VisitedAccountAdvertsViewModel: ViewModelLifeCycle {

    func viewDidLoad() {
        view?.startActivityIndicatorView()
        view?.configureCollectionView()
        view?.setCollectionViewVisibility(isHidden: true, animated: false)

        view?.configureUI()
        fetchAdverts()
    }
}
