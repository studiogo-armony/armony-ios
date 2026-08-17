//
//  MainViewModel.swift
//  Armony
//
//  Created by Koray Yıldız on 28.08.2021.
//

import Foundation

fileprivate typealias HomeData = (bannerResponse: RestObjectResponse<BannerSliderResponse>,
                                  advertsResponse: RestArrayResponse<Advert>)

final class AdvertsViewModel: ViewModel {

    var coordinator: (any AdvertsCoordinating)!
    private weak var view: AdvertsViewDelegate?

    private let messageCountSocketHandler: MessageCountSocketHandling
    private let authenticator: AuthenticationProviding
    private let defaults: DefaultsProviding
    private let appLaunchService: AppLaunchHandling

    private let bannerService: RestService

    private var advertDidDeleteNotificationToken: NotificationToken? = nil
    private var deletedAdvertIDs: [Int] = .empty

    private var advertDidNewCreateNotificationToken: NotificationToken? = nil
    private var newCreatedAdvertPresentations: [CardPresentation] = .empty

    var filtersDidUpdate: Callback<FilterViewModel.Filters>? = nil

    private var paginator: Paginator

    private(set) var sliderPresentation: BannerSliderPresentation = .empty

    private(set) var filters: FilterViewModel.Filters = .empty {
        didSet {
            let task = GetAdvertsTask(
                userID: authenticator.userID,
                adTypeIDs: filters.advert?.id?.string,
                cityIDs: filters.location?.id?.string
            )
            self.paginator = Paginator(task: task)
            filtersDidUpdate?(filters)
        }
    }

    var presentation: AdvertsPresentation = .empty {
        didSet {
            toggleEmptyStateView()
        }
    }

    var numberOfItemsInSection: Int {
        return presentation.cards.count
    }

    init(
        view: AdvertsViewDelegate,
        messageCountSocketHandler: MessageCountSocketHandling = MessageCountSocketHandler.shared,
        authenticator: AuthenticationProviding = AuthenticationService.shared,
        defaults: DefaultsProviding = Defaults.shared,
        appLaunchService: AppLaunchHandling = AppLaunchService.shared,
        bannerService: RestService = .init(backend: .factory()),
        service: RestService = .init(backend: .factory())
    ) {
        self.view = view
        self.messageCountSocketHandler = messageCountSocketHandler
        self.authenticator = authenticator
        self.defaults = defaults
        self.appLaunchService = appLaunchService
        self.bannerService = bannerService
        self.paginator = Paginator(task: GetAdvertsTask(userID: authenticator.userID))
        super.init(service: service)
    }

    func card(at indexPath: IndexPath) -> CardPresentation {
        return presentation.cards[indexPath.row]
    }

    func toggleEmptyStateView() {
        if presentation.cards.isEmpty {
            view?.showEmptyStateView(with: .noContent, action: { [weak self] _ in
                self?.filter(by: .empty)
            })
        }
        else {
            view?.hideEmptyStateView(animated: false)
        }
    }

    @objc func refresh() {
        RefreshAdvertsFirebaseEvent().send()
        fetchAdverts()
    }

    private func next() {
        Task {
            do {
                let response = try await paginator.next(service: service, type: RestArrayResponse<Advert>.self)
                safeSync {
                    let newPresentation = AdvertsPresentation(adverts: response.data)
                    presentation.cards.append(contentsOf: newPresentation.cards)
                    view?.reloadCollectionView()
                }
            }
            catch let error {
                await AlertService.show(error: error.api, actions: [.okay()])
            }
        }
    }

    func willDisplayItem(at indexPath: IndexPath) {
        if numberOfItemsInSection - 2 == indexPath.row, paginator.hasNext {
            next()
        }
    }

    private func homeData() async throws -> HomeData {
        async let banners = bannerService.execute(
            task: GetBannersTask(),
            type: RestObjectResponse<BannerSliderResponse>.self
        )
        async let adverts = paginator.execute(
            service: service,
            type: RestArrayResponse<Advert>.self
        )
        return try await (banners, adverts)
    }

    func fetchAdverts() {
        Task {
            do {
                var response = try await homeData()

                if Locale.current.regionCode != "TR" {
                    response.bannerResponse.data.banners.removeFirst()
                }

                safeSync {
                    sliderPresentation = BannerSliderPresentation(
                        isActive: response.bannerResponse.data.isActive,
                        banners: response.bannerResponse.data.banners
                    )
                    presentation = AdvertsPresentation(adverts: response.advertsResponse.data)

                    view?.setCollectionViewVisibility(isHidden: false, animated: true)
                    view?.stopActivityIndicatorView()
                    view?.endRefreshing()
                    view?.reloadCollectionView()
                }
            }
            catch let error {
                safeSync {
                    toggleEmptyStateView()
                    view?.setCollectionViewVisibility(isHidden: false, animated: false)
                    view?.endRefreshing()
                    view?.stopActivityIndicatorView()
                }
                await AlertService.show(error: error.api, actions: [.okay()])
            }
        }
    }

    func chatsRightButtonTapped() {
        coordinator.open(deeplink: .chats)
    }

    func filter(by filter: FilterViewModel.Filters) {
        view?.setCollectionViewVisibility(isHidden: true, animated: false)
        presentation = .empty
        view?.reloadCollectionView()
        view?.startActivityIndicatorView()
        self.filters = filter
        fetchAdverts()
    }

    // MARK: - Remove Advert
    private func addDidRemoveAdvertNotificationToken() {
        advertDidDeleteNotificationToken = NotificationCenter.default.observe(name: .advertDidRemove,
                                                                              using: { [unowned self] notification in

            if let advertID: Int = notification[.advertID] {
                self.deletedAdvertIDs.insert(advertID, at: .zero)
                self.newCreatedAdvertPresentations.removeAll(where: { $0.id == advertID })
            }
            NotificationCenter.default.removeObserver(advertDidDeleteNotificationToken as Any)
        })
    }

    private func handleDeletedAdvert() {
        if !deletedAdvertIDs.isEmpty {
            var indexPaths: [IndexPath] = .empty

            for advertID in deletedAdvertIDs {

                guard let indexOfDeletedAdvert = presentation.cards.firstIndex(where: { $0.id == advertID }) else {
                    deletedAdvertIDs.removeAll(where: { $0 == advertID })
                    return
                }

                self.presentation.cards.remove(at: indexOfDeletedAdvert)
                let indexPathOfDeletedAdvert = IndexPath(item: indexOfDeletedAdvert, section: .zero)

                indexPaths.insert(indexPathOfDeletedAdvert, at: .zero)
            }


            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.view?.deleteItems(indexPaths: indexPaths) { [weak self] result in
                    if result {
                        self?.deletedAdvertIDs.removeAll()
                    }
                }
            }
        }
    }

    // MARK: - Place Advert
    private func addDidPlaceAdvertNotificationToken() {
        advertDidNewCreateNotificationToken = NotificationCenter.default.observe(name: .newAdvertDidPlace,
                                                                              using: { [unowned self] notification in

            if let advert: Advert = notification[.advert] {
                let newAd = CardPresentation(advert: advert)
                newCreatedAdvertPresentations.insert(newAd, at: .zero)
            }
            NotificationCenter.default.removeObserver(advertDidNewCreateNotificationToken as Any)
        })
    }

    private func handleAdvertDidCreate() {
        if !newCreatedAdvertPresentations.isEmpty, filters.isEmpty {
            var counter: Int = .zero
            var indexPaths: [IndexPath] = .empty

            for _ in newCreatedAdvertPresentations {
                let indexPath = IndexPath(item: counter, section: .zero)
                indexPaths.append(indexPath)
                counter = counter + 1
            }

            presentation.cards.insert(contentsOf: newCreatedAdvertPresentations, at: .zero)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.view?.insertItems(indexPaths: indexPaths) { [weak self] result in
                    if result {
                        self?.newCreatedAdvertPresentations.removeAll()
                    }
                }
            }
        }
    }

    private func handleDeeplinkAndOnboarding() {
        if !defaults[.onboardingHasSeen] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: coordinator.onboarding)
        }

        if appLaunchService.isLaunchedClosedStateWithNotification,
           let deeplink = appLaunchService.deeplink {
            coordinator.open(deeplink: deeplink)
            appLaunchService.reset()
        }
    }
}

// MARK: - ViewModelLifeCycle
extension AdvertsViewModel: ViewModelLifeCycle {

    func viewDidLoad() {
        view?.configureCollectionView()
        view?.startActivityIndicatorView()
        view?.configureNavigationBar()
        view?.setCollectionViewVisibility(isHidden: true, animated: false)

        view?.addRefresher(self, color: .armonyBlue, selector: #selector(refresh))
        view?.configureUI()
        fetchAdverts()

        addDidRemoveAdvertNotificationToken()
        addDidPlaceAdvertNotificationToken()

        messageCountSocketHandler.start()
    }

    func viewDidAppear() {
        handleDeeplinkAndOnboarding()
        handleDeletedAdvert()
        handleAdvertDidCreate()

        MixPanelScreenViewEvent(
            parameters: [
                "screen": "Adverts - HomePage",
            ]
        ).send()
    }
}

// MARK: - EmptyStatePresentation
private extension EmptyStatePresentation {
    static var noContent: EmptyStatePresentation = {
        let title = String("Adverts.EmptyState.Title", table: .home).emptyStateTitleAttributed
        let buttonTitle = String("Adverts.EmptyState.Button.Title", table: .home).emptyStateButtonAttributed
        let presentation = EmptyStatePresentation(image: .advertsEmptystateIcon,
                                                  title: title,
                                                  buttonTitle: buttonTitle)
        return presentation
    }()
}

struct BannerSliderResponse: Decodable {
    let isActive: Bool
    var banners: [BannerSlider]
}

struct BannerSlider: Decodable {
    let title: String
    let image: URL
    let backgroundColor: AppTheme.Color
    let deeplink: Deeplink
}

struct RefreshAdvertsFirebaseEvent: FirebaseEvent {
    var name: String = "refresh_home"
    var category: String = "Home"
    var action: String = "Refresh"
}
