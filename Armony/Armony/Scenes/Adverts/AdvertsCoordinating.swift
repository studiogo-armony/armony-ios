//
//  AdvertsCoordinating.swift
//  Armony
//
//  Created by Koray Yildiz on 17.08.26.
//

import Foundation

protocol AdvertsCoordinating: CoordinatorInterface {
    func advert(with id: Int, colorCode: String, dismiss completion: Callback<Bool>?)
    func onboarding()
    func filter(delegate: FilterViewModelDelegate, selectedFilters: FilterViewModel.Filters)
}

protocol MessageCountSocketHandling {
    func start()
}

protocol DefaultsProviding {
    subscript(key: DefaultsKeys) -> Bool { get }
}

extension MessageCountSocketHandler: MessageCountSocketHandling {}
extension Defaults: DefaultsProviding {}
