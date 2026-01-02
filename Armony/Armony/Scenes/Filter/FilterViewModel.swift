//
//  FilterViewModel.swift
//  Armony
//
//  Created by Koray Yildiz on 08.06.23.
//

import Foundation

protocol FilterViewModelDelegate: AnyObject {
    func applyButtonTapped(filters: FilterViewModel.Filters)
}

final class FilterViewModel: ViewModel {

    struct Filter {
        let id: Int?
        let title: String?

        init(id: Int?, title: String?) {
            self.id = id
            self.title = title
        }

        static let empty = Filter(id: nil, title: nil)
    }
    
    struct Filters {
        var advert: Filter?
        var location: Filter?

        static let empty = Filters(advert: nil, location: nil)

        var isEmpty: Bool {
            return advert.isNil && location.isNil
        }
    }

    var filterDidUpdate: Callback<FilterViewModel.Filters>? = nil

    private let isEmptyFilters: Bool

    private weak var view: (any FilterViewDelegate)?
    weak var delegate: (any FilterViewModelDelegate)?
    var coordinator: (any Coordinator)!

    var filters: Filters = .empty {
        didSet {
            filterDidUpdate?(filters)
        }
    }

    init(view: (any FilterViewDelegate)?,
         selectedFilters: Filters = .empty,
         service: RestService = .init(backend: .factory())) {
        self.view = view
        self.isEmptyFilters = selectedFilters.isEmpty
        self.filters = selectedFilters
        super.init(service: service)
    }

    func advertTypeDropdownTapped() {
        view?.startAdvertTypeDropdownViewActivityIndicatorView()
        Task {
            do {
                let response = try await service.execute(task: GetAdvertTypesTask(),
                                                         type: RestArrayResponse<Advert.Properties>.self)

                let items = response.itemsForSelection(selectedID: filters.advert?.id)
                let selectionPresentation = AdvertTypeSelectionPresentation(delegate: self, items: items)
                safeSync {
                    view?.stopAdvertTypeDropdownViewActivityIndicatorView()
                    SelectionBottomPopUpCoordinator(navigator: coordinator.navigator).start(presentation: selectionPresentation)
                }
            }
            catch {
                safeSync {
                    view?.stopAdvertTypeDropdownViewActivityIndicatorView()
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

                let items = response.itemsForSelection(selectedID: filters.location?.id)
                let selectionPresentation = LocationSelectionPresentation(delegate: self, items: items)

                safeSync {
                    view?.stopLocationDropdownViewActivityIndicatorView()
                    SelectionBottomPopUpCoordinator(navigator: coordinator.navigator).start(presentation: selectionPresentation)
                }
            }
            catch {
                safeSync {
                    view?.stopLocationDropdownViewActivityIndicatorView()
                }
            }
        }
    }

    func applyButtonTapped() {
        handleEvents()
        coordinator.dismiss(animated: true) { [weak self] in
            self?.delegate?.applyButtonTapped(filters: self?.filters ?? .empty)
        }
    }

    private func handleEvents() {
        if filters.isEmpty, !isEmptyFilters {
            ClearFilterFirebaseEvent().send()
        }

        if !filters.isEmpty {
            let params = [
                "ad_type": filters.advert?.title ?? .empty,
                "location": filters.location?.title ?? .empty
            ]
            ApplyFilterFirebaseEvent(parameters: params).send()
        }
    }
}

// MARK: - AdvertTypeSelectionDelegate
extension FilterViewModel: AdvertTypeSelectionDelegate {

    func advertTypeDidSelect(advert: (any SelectionInput)?) {
        if let advert {
            filters.advert = Filter(id: advert.id, title: advert.title)
        }
        else {
            filters.advert = nil
        }
        view?.updateAdvertType(title: advert?.title)
    }
}

// MARK: - AdvertTypeSelectionDelegate
extension FilterViewModel: LocationSelectionDelegate {

    func locationDidSelect(location: (any SelectionInput)?) {
        if let location {
            filters.location = Filter(id: location.id, title: location.title)
        }
        else {
            filters.location = nil
        }
        view?.updateLocation(title: location?.title)
    }
}

struct ApplyFilterFirebaseEvent: FirebaseEvent {
    var name: String = "apply_filter"
    var category: String = "Filter"
    var action: String = "Apply"
    var parameters: Payload
}

struct ClearFilterFirebaseEvent: FirebaseEvent {
    var name: String = "clear_filter"
    var category: String = "Filter"
    var action: String = "Clear"
}

