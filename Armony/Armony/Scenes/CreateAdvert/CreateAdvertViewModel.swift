//
//  CreateAdvertViewModel.swift
//  Armony
//
//  Created by Koray Yıldız on 05.10.22.
//

import Foundation

final class CreateAdvertViewModel: ViewModel {

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

        private mutating func resetSkills() {
            skills = .empty
        }

        // MARK: - EMPTY
        static let empty = SelectedIDStorage(advert: nil, location: nil, musicGenres: .empty, skills: .empty)
    }

    var coordinator: CreateAdvertCoordinator!
    private weak var view: CreateAdvertViewDelegate?
    private let notificationService: CreateAdvertNotificationService = .shared

    private var selectedIDStorage: SelectedIDStorage = .empty
    private var request: CreateAdvertRequest
    private var description: String? = nil {
        didSet {
            self.request.description = description.isNotNilOrEmpty ? description : nil
        }
    }

    private let skillSelectionTitleForGroup = "Aradığın Müzisyenleri Ekle".needLocalization
    private let skillSelectionTitleForSinglePerson = "Çaldığın Enstrümanları Ekle".needLocalization

    init(view: CreateAdvertViewDelegate) {
        self.view = view
        self.request = .empty
        super.init()
    }

    func descriptionTextViewDidChange(description: String?) {
        self.description = description
    }

    func resetInputs() {
        selectedIDStorage = .empty
        description = .empty
        request = .empty

        view?.updateMusicGenres(title: nil)
        view?.updateAdvertType(title: nil)
        view?.updateSkills(title: nil)
        view?.updateLocation(title: nil)
        view?.setInformationsStackViewVisibility(isHidden: selectedIDStorage.advert.isNil)

        view?.resetTextView()
    }

    func advertTypeDropdownTapped() {
        view?.startAdvertTypeDropdownViewActivityIndicatorView()
        Task {
            do {
                let response = try await service.execute(task: GetAdvertTypesTask(),
                                                         type: RestArrayResponse<AdvertType>.self)

                let items = response.itemsForSelection(selectedID: selectedIDStorage.advert)
                let selectionPresentation = AdvertTypeSelectionPresentation(delegate: self, items: items)
                safeSync {
                    view?.stopAdvertTypeDropdownViewActivityIndicatorView()
                    coordinator.profileSelection(presentation: selectionPresentation)
                }
            }
            catch {
                safeSync {
                    view?.stopAdvertTypeDropdownViewActivityIndicatorView()
                }
            }
        }
    }

    func musicGenresDropdownTapped() {

        view?.startMusicGenresDropdownViewActivityIndicatorView()

        Task {
            do {
                let response = try await service.execute(task: GetMusicGenresTask(),
                                                         type: RestArrayResponse<MusicGenre>.self)

                let items = response.itemsForSelection(selectedIDs: selectedIDStorage.musicGenres)
                let selectionPresentation = MusicGenresSelectionPresentation(delegate: self, items: items)

                safeSync {
                    view?.stopMusicGenresDropdownViewActivityIndicatorView()
                    coordinator.profileSelection(presentation: selectionPresentation)
                }
            }
            catch {
                safeSync {
                    view?.stopMusicGenresDropdownViewActivityIndicatorView()
                }
            }
        }
    }

    func skillsDropdownTapped() {
        view?.startSkillsDropdownViewActivityIndicatorView()
        Task {
            do {
                let response = try await service.execute(task: GetSkillsTask(for: selectedIDStorage.advert.ifNil(.zero)),
                                                         type: RestArrayResponse<Skill>.self)

                let items = response.itemsForSelection(selectedIDs: selectedIDStorage.skills)
                var headerTitle: String = .empty

                if selectedIDStorage.advert == 1 {
                    headerTitle = skillSelectionTitleForSinglePerson
                }
                else {
                    headerTitle = skillSelectionTitleForGroup
                }
                let selectionPresentation = SkillsSelectionPresentation(delegate: self,
                                                                        items: items,
                                                                        headerTitle: headerTitle)

                safeSync {
                    view?.stopSkillsDropdownViewActivityIndicatorView()
                    coordinator.profileSelection(presentation: selectionPresentation)
                }
            }
            catch {
                safeSync {
                    view?.stopSkillsDropdownViewActivityIndicatorView()
                }
            }
        }
    }

    func locationDropdownTapped() {
        view?.startLocationDropdownViewActivityIndicatorView()
        Task {
            do {
                let response = try await service.execute(task: GetLocationTask(),
                                                         type: RestArrayResponse<Location>.self)

                let items = response.itemsForSelection(selectedID: selectedIDStorage.location)
                let selectionPresentation = LocationSelectionPresentation(delegate: self, items: items)

                safeSync {
                    view?.stopLocationDropdownViewActivityIndicatorView()
                    coordinator.profileSelection(presentation: selectionPresentation)
                }
            }
            catch {
                safeSync {
                    view?.stopLocationDropdownViewActivityIndicatorView()
                }
            }
        }
    }

    func submitButtonTapped() {
        view?.startSubmitButtonActivityIndicatorView()
        Task { @MainActor in
            do {
                let response = try await service.execute(task: PostCreateAdvertTask(request: request),
                                                         type: RestObjectResponse<Advert>.self)

                CreateAdvertAdjustEventsHandler.track(for: request.advertTypeID)
                CreateAdvertFirebasveEventsHandler.track(request: request)
                view?.stopSubmitButtonActivityIndicatorView()
                resetInputs()

                let view = coordinator.selectTab(tab: .account, shouldPopToRoot: true)

                if let view = view as? AccountViewController {
                    view.viewModel.currentSelectedSegmentIndex = 1
                    if view.isViewLoaded {
                        view.selectSegment(at: 1)
                    }
                }
                NotificationCenter.default.post(
                    notification: .newAdvertDidCreate,
                    userInfo: [.advert: response.data]
                )
            }
            catch let error {
                safeSync {
                    view?.stopSubmitButtonActivityIndicatorView()
                }
                AlertService.show(message: error.api.ifNil(.network).description, actions: [.okay()])
            }
        }
    }
}

// MARK: - AdvertTypeSelectionDelegate
extension CreateAdvertViewModel: AdvertTypeSelectionDelegate {

    func advertTypeDidSelect(advert: SelectionInput?) {
        if selectedIDStorage.advert != advert?.id {
            view?.updateSkills(title: .empty)
            request.skills = .empty
        }

        view?.setInformationsStackViewVisibility(isHidden: advert.isNil)
        if let advert {
            selectedIDStorage.advert = advert.id
            view?.updateAdvertType(title: advert.title)
            request.advertTypeID = advert.id

            if advert.id == 1 {
                view?.configureMusicGenreDropdownView(presentation: .musicGenres)
                view?.configureSkillDropdownView(presentation: .skill)
            } else if advert.id == 3 {
                view?.configureMusicGenreDropdownView(presentation: .musicGenres)
                view?.configureSkillDropdownView(presentation: .init(title: "Çalınan Enstrümanlar"))
            }
            else {
                view?.configureSkillDropdownView(presentation: .init(title: "Aradığın Müzisyenler"))
                view?.configureMusicGenreDropdownView(presentation: .init(title: "Müzik Tarzınız"))
            }
        }
    }
}

// MARK: - AdvertTypeSelectionDelegate
extension CreateAdvertViewModel: LocationSelectionDelegate {

    func locationDidSelect(location: SelectionInput?) {
        selectedIDStorage.location = location?.id
        view?.updateLocation(title: location?.title)
        request.location = location.map { selectedLocation in
            return Location(id: selectedLocation.id, title: selectedLocation.title)
        }
    }
}

// MARK: - SkillsSelectionDelegate
extension CreateAdvertViewModel: SkillsSelectionDelegate {

    func skillsDidSelect(skills: [SelectionInput]?) {
        selectedIDStorage.skills = skills.ifNil(.empty).compactMap { $0.id }
        view?.updateSkills(title: skills?.title)

        request.skills = skills?.compactMap { skill in
            return Skill(id: skill.id, iconURL: nil, title: skill.title, colorCode: nil)
        }
    }
}

// MARK: - MusicGenresSelectionDelegate
extension CreateAdvertViewModel: MusicGenresSelectionDelegate {

    func musicGenresDidSelect(genres: [SelectionInput]?) {
        selectedIDStorage.musicGenres = genres.ifNil(.empty).compactMap { $0.id }
        view?.updateMusicGenres(title: genres?.title)

        request.genres = genres?.compactMap { genre in
            return MusicGenre(id: genre.id, name: genre.title)
        }
    }
}
