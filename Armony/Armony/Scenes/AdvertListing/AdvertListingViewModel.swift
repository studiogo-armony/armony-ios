//
//  AdListingViewModel.swift
//  Armony
//
//  Created by KORAY YILDIZ on 17/09/2024.
//

import Foundation

final class AdvertListingViewModel: ViewModel, ObservableObject {

    @Published var cards: [CardPresentation]
    var coordinator: AdvertListingCoordinator!

    init() {
        self.cards = .empty
        super.init()
    }

    func fetchAdverts() async {
        do {
            let response = try await service.execute(
                task: GetExternalAdvertsTask(),
                type: RestArrayResponse<Advert>.self
            )
            cards = response.data.map { CardPresentation(advert: $0) }
        }
        catch let error {
            error.showAlert()
        }
    }
}
