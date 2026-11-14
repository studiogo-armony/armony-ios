//
//  PlaceAdvertViewModel.swift
//  Armony
//
//  Created by Koray Yıldız on 05.10.22.
//

import Foundation

final class PlaceAdvertViewModel: ViewModel {

    // MARK: - Storage
    private struct SelectedIDStorage {
        var advert: Int? {
            didSet {
                if  advert != oldValue {
                    resetSkills()
                }
            }
        }
        var location: Int?
        var musicGenres: [Int]
        var skills: [Int]
        var services: [Int]

        private mutating func resetSkills() {
            skills = .empty
        }

        // MARK: - EMPTY
        static let empty = SelectedIDStorage(
            advert: nil,
            location: nil,
            musicGenres: .empty,
            skills: .empty,
            services: .empty
        )
    }

    var coordinator: (any PlaceAdvertCoordinating)!
    private weak var view: PlaceAdvertViewDelegate?
    private let notificationService: PlaceAdvertNotificationService = .shared
    private let authenticator: any AuthenticationProviding
    private let purchaseStorage: any RevenueCatPurchaseStoring
    private let appRating: any AppRating

    private var selectedIDStorage: SelectedIDStorage = .empty
    private var request: PlaceAdvertRequest
    private var advertsResponse: [Advert.Properties] = .empty
    private(set) var hasUserAdverts: Bool = false
    private(set) var userAdsCountRequestError: Error?
    private var description: String? = nil {
        didSet {
            self.request.description = description.isNotNilOrEmpty ? description : nil
        }
    }

    init(
        view: PlaceAdvertViewDelegate,
        authenticator: any AuthenticationProviding = AuthenticationService.shared,
        purchaseStorage: any RevenueCatPurchaseStoring = RevenueCatPurchaseStorageService.shared,
        appRating: any AppRating = AppRatingService.shared,
        service: RestService = RestService(backend: .factory())
    ) {
        self.view = view
        self.authenticator = authenticator
        self.purchaseStorage = purchaseStorage
        self.appRating = appRating
        self.request = .empty
        super.init(service: service)
    }

    func descriptionTextViewDidChange(description: String?) {
        self.description = description
    }

    func resetInputs() {
        selectedIDStorage = .empty
        description = .empty
        request = .empty

        resetSelectionTitles()
        view?.updateAdvertType(title: nil)
        view?.setInformationsStackViewVisibility(isHidden: selectedIDStorage.advert.isNil)

        view?.resetTextView()
    }

    func advertTypeDropdownTapped() {
        presentSelection(
            task: GetAdvertTypesTask(),
            type: RestArrayResponse<Advert.Properties>.self,
            activity: .advertType
        ) { [unowned self] response in
            advertsResponse = response.data
            let items = response.itemsForSelection(selectedID: selectedIDStorage.advert)
            return AdvertTypeSelectionPresentation(delegate: self, items: items)
        }
    }

    func musicGenresDropdownTapped() {
        presentSelection(
            task: GetMusicGenresTask(),
            type: RestArrayResponse<MusicGenre>.self,
            activity: .musicGenres
        ) { [unowned self] response in
            let items = response.itemsForSelection(selectedIDs: selectedIDStorage.musicGenres)
            return MusicGenresSelectionPresentation(delegate: self, items: items)
        }
    }

    func skillsDropdownTapped() {
        presentSelection(
            task: GetSkillsTask(for: selectedIDStorage.advert.ifNil(.zero)),
            type: RestArrayResponse<Skill>.self,
            activity: .skills
        ) { [unowned self] response in
            let items = response.itemsForSelection(selectedIDs: selectedIDStorage.skills)
            return SkillsSelectionPresentation(delegate: self, items: items)
        }
    }

    func locationDropdownTapped() {
        presentSelection(
            task: GetLocationTask(),
            type: RestArrayResponse<Location>.self,
            activity: .location
        ) { [unowned self] response in
            let items = response.itemsForSelection(selectedID: selectedIDStorage.location)
            return LocationSelectionPresentation(delegate: self, items: items)
        }
    }

    func instructionTypeDropdownView() {
        guard let selectedAdvertID = selectedIDStorage.advert else {
            // Services depend on the advert type; the indicator starts but nothing is requested.
            DropdownActivity.instructionType.start(view)
            return
        }
        presentSelection(
            task: GetServicesTask(adTypeID: selectedAdvertID),
            type: RestArrayResponse<ServiceResponse>.self,
            activity: .instructionType
        ) { [unowned self] response in
            let items = response.itemsForSelection(selectedIDs: selectedIDStorage.services)
            return ServiceSelectionPresentation(delegate: self, items: items)
        }
    }

    func submitButtonTapped() {
        view?.startSubmitButtonActivityIndicatorView()

        Task { @MainActor in
            do {
                let hasUserAds = try await hasUserAds()
                view?.stopSubmitButtonActivityIndicatorView()
                guard requiresPurchase(hasUserAds: hasUserAds) else {
                    createAd(transactionID: nil)
                    return
                }
                view?.showPaywall()
            }
            catch let error {
                showSubmitFailure(error)
            }
        }
    }

    func createAd(transactionID: String?) {
        view?.startSubmitButtonActivityIndicatorView()
        Task { @MainActor in
            do {
                let response = try await service.execute(task: PostPlaceAdvertTask(request: request),
                                                         type: RestObjectResponse<Advert>.self)

                trackPlacedAdvert()

                view?.stopSubmitButtonActivityIndicatorView()
                resetInputs()

                coordinator.showUserAdverts()
                NotificationCenter.default.post(
                    notification: .newAdvertDidPlace,
                    userInfo: [.advert: response.data]
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.appRating.requestReviewIfNeeded()
                }

                if let transactionID {
                    purchaseStorage.remove(transactionID: transactionID)
                }
            }
            catch let error {
                showSubmitFailure(error)
            }
        }
    }

    func hasUserAds() async throws -> Bool {
        let response = try await service.execute(
            task: GetUserAdvertsTask(userID: authenticator.userID),
            type: RestArrayResponse<Advert>.self
        )
        return !response.data.isEmpty
    }
}

// MARK: - Helpers
private extension PlaceAdvertViewModel {

    /// Activity indicator of the dropdown that triggered a selection request.
    struct DropdownActivity {
        let start: (PlaceAdvertViewDelegate?) -> Void
        let stop: (PlaceAdvertViewDelegate?) -> Void

        static let advertType = DropdownActivity(
            start: { $0?.startAdvertTypeDropdownViewActivityIndicatorView() },
            stop: { $0?.stopAdvertTypeDropdownViewActivityIndicatorView() }
        )
        static let musicGenres = DropdownActivity(
            start: { $0?.startMusicGenresDropdownViewActivityIndicatorView() },
            stop: { $0?.stopMusicGenresDropdownViewActivityIndicatorView() }
        )
        static let skills = DropdownActivity(
            start: { $0?.startSkillsDropdownViewActivityIndicatorView() },
            stop: { $0?.stopSkillsDropdownViewActivityIndicatorView() }
        )
        static let location = DropdownActivity(
            start: { $0?.startLocationDropdownViewActivityIndicatorView() },
            stop: { $0?.stopLocationDropdownViewActivityIndicatorView() }
        )
        static let instructionType = DropdownActivity(
            start: { $0?.startInstructionTypeDropdownViewActivityIndicatorView() },
            stop: { $0?.stopInstructionTypeDropdownViewActivityIndicatorView() }
        )
    }

    func presentSelection<Response: APIResponse>(
        task: RestAPI.Operation,
        type: Response.Type,
        activity: DropdownActivity,
        makePresentation: @escaping (Response) -> any SelectionPresentation
    ) {
        activity.start(view)
        Task {
            do {
                let response = try await service.execute(task: task, type: type)
                let presentation = makePresentation(response)
                safeSync {
                    activity.stop(view)
                    coordinator.profileSelection(presentation: presentation)
                }
            }
            catch {
                safeSync {
                    activity.stop(view)
                }
            }
        }
    }

    func resetSelectionTitles() {
        view?.updateSkills(title: nil)
        view?.updateLocation(title: nil)
        view?.updateMusicGenres(title: nil)
        view?.updateInstructionType(title: nil)
    }

    func requiresPurchase(hasUserAds: Bool) -> Bool {
        return hasUserAds && purchaseStorage.identifiers.isEmpty
    }

    func trackPlacedAdvert() {
        PlaceAdvertAdjustEventsHandler.track(for: request.advertTypeID)

        let adTitle = advertsResponse.first { $0.id == request.advertTypeID }?.title
        PlaceAdvertFirebaseEvents(
            label: adTitle.emptyIfNil,
            parameters: request.eventParameters()
        ).send()
    }

    func showSubmitFailure(_ error: Error) {
        view?.stopSubmitButtonActivityIndicatorView()
        AlertService.show(message: error.api.ifNil(.network).description, actions: [.okay()])
    }
}

// MARK: - AdvertTypeSelectionDelegate
extension PlaceAdvertViewModel: AdvertTypeSelectionDelegate {

    func advertTypeDidSelect(advert: SelectionInput?) {
        selectedIDStorage = .empty
        request = .empty

        resetSelectionTitles()
        view?.setInformationsStackViewVisibility(isHidden: advert.isNil)

        guard let advert else { return }

        selectedIDStorage.advert = advert.id
        request.advertTypeID = advert.id
        view?.updateAdvertType(title: advert.title)
        PlaceAdvertForm(advertTypeID: advert.id).apply(to: view)
    }
}

// MARK: - LocationSelectionDelegate
extension PlaceAdvertViewModel: LocationSelectionDelegate {

    func locationDidSelect(location: SelectionInput?) {
        selectedIDStorage.location = location?.id
        view?.updateLocation(title: location?.title)
        request.location = location.map { selectedLocation in
            return Location(id: selectedLocation.id, title: selectedLocation.title)
        }
    }
}

// MARK: - SkillsSelectionDelegate
extension PlaceAdvertViewModel: SkillsSelectionDelegate {

    func skillsDidSelect(skills: [SelectionInput]?) {
        selectedIDStorage.skills = skills.ifNil(.empty).compactMap { $0.id }
        view?.updateSkills(title: skills?.title)

        request.skills = skills?.compactMap { skill in
            return Skill(id: skill.id, iconURL: nil, title: skill.title, colorCode: nil)
        }
    }
}

// MARK: - MusicGenresSelectionDelegate
extension PlaceAdvertViewModel: MusicGenresSelectionDelegate {

    func musicGenresDidSelect(genres: [SelectionInput]?) {
        selectedIDStorage.musicGenres = genres.ifNil(.empty).compactMap { $0.id }
        view?.updateMusicGenres(title: genres?.title)

        request.genres = genres?.compactMap { genre in
            return MusicGenre(id: genre.id, name: genre.title)
        }
    }
}

// MARK: - ServiceSelectionDelegate
extension PlaceAdvertViewModel: ServiceSelectionDelegate {

    func serviceDidSelect(services: [any SelectionInput]?) {
        selectedIDStorage.services = services.ifNil(.empty).compactMap { $0.id }
        view?.updateInstructionType(title: services?.title)

        request.serviceTypes = services?.compactMap { service in
            return ServiceResponse(id: service.id, title: service.title)
        }
    }
}
